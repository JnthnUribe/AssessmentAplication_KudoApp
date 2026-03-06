using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using MongoDB.Driver;

namespace KudoApi.Infrastructure.Repositories
{
    public class VoteRepository : IVoteRepository
    {
        private readonly MongoDbContext _context;

        public VoteRepository(MongoDbContext context)
        {
            _context = context;
        }

        public async Task<Vote?> GetByProjectAndVoterAsync(string projectId, string voterId)
        {
            return await _context.Votes
                .Find(v => v.ProjectId == projectId && v.VoterId == voterId)
                .FirstOrDefaultAsync();
        }

        public async Task<List<Vote>> GetByProjectIdAsync(string projectId)
        {
            return await _context.Votes
                .Find(v => v.ProjectId == projectId)
                .ToListAsync();
        }

        public async Task CreateAsync(Vote vote)
        {
            await _context.Votes.InsertOneAsync(vote);
        }
    }
}
