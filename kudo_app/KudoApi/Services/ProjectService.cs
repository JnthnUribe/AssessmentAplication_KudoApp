using MongoDB.Driver;
using KudoApi.Models;

namespace KudoApi.Services;

public class ProjectService
{
    private readonly IMongoCollection<Project> _projects;
    private readonly IMongoCollection<Vote> _votes;

    public ProjectService(IMongoDatabase database)
    {
        _projects = database.GetCollection<Project>("projects");
        _votes = database.GetCollection<Vote>("votes");
        
        // Create text index for search
        var indexKeys = Builders<Project>.IndexKeys.Text(p => p.Name).Text(p => p.Description).Text(p => p.Category);
        _projects.Indexes.CreateOne(new CreateIndexModel<Project>(indexKeys));
    }

    public async Task<List<Project>> GetAllAsync(string? search = null)
    {
        if (string.IsNullOrWhiteSpace(search))
        {
            return await _projects.Find(_ => true).SortByDescending(p => p.AverageScore).ToListAsync();
        }

        var filter = Builders<Project>.Filter.Or(
            Builders<Project>.Filter.Regex(p => p.Name, new MongoDB.Bson.BsonRegularExpression(search, "i")),
            Builders<Project>.Filter.Regex(p => p.Description, new MongoDB.Bson.BsonRegularExpression(search, "i")),
            Builders<Project>.Filter.Regex(p => p.Category, new MongoDB.Bson.BsonRegularExpression(search, "i"))
        );
        
        return await _projects.Find(filter).SortByDescending(p => p.AverageScore).ToListAsync();
    }

    public async Task<Project?> GetByIdAsync(string id)
    {
        return await _projects.Find(p => p.Id == id).FirstOrDefaultAsync();
    }

    public async Task<List<Project>> GetRankingAsync()
    {
        return await _projects.Find(_ => true)
            .SortByDescending(p => p.AverageScore)
            .ThenByDescending(p => p.TotalVotes)
            .ToListAsync();
    }

    public async Task<bool> VoteAsync(string projectId, VoteRequest request)
    {
        // Check if project exists
        var project = await _projects.Find(p => p.Id == projectId).FirstOrDefaultAsync();
        if (project == null) return false;

        // Validate score
        if (request.Score < 1 || request.Score > 5) return false;

        // Check if user already voted for this project
        var existingVote = await _votes.Find(v => v.ProjectId == projectId && v.UserId == request.UserId).FirstOrDefaultAsync();
        if (existingVote != null)
        {
            // Update existing vote - need to recalculate average
            var oldScore = existingVote.Score;
            existingVote.Score = request.Score;
            existingVote.Comment = request.Comment;
            existingVote.Timestamp = DateTime.UtcNow;
            
            await _votes.ReplaceOneAsync(v => v.Id == existingVote.Id, existingVote);
            
            // Recalculate average (remove old, add new)
            if (project.TotalVotes > 0)
            {
                var totalScore = project.AverageScore * project.TotalVotes;
                totalScore = totalScore - oldScore + request.Score;
                project.AverageScore = totalScore / project.TotalVotes;
            }
        }
        else
        {
            // New vote
            var vote = new Vote
            {
                ProjectId = projectId,
                UserId = request.UserId,
                Score = request.Score,
                Comment = request.Comment
            };
            await _votes.InsertOneAsync(vote);

            // Atomic update of project stats
            var totalScore = project.AverageScore * project.TotalVotes + request.Score;
            project.TotalVotes++;
            project.AverageScore = totalScore / project.TotalVotes;
        }

        // Update project
        var update = Builders<Project>.Update
            .Set(p => p.TotalVotes, project.TotalVotes)
            .Set(p => p.AverageScore, Math.Round(project.AverageScore, 2));

        await _projects.UpdateOneAsync(p => p.Id == projectId, update);
        return true;
    }
}
