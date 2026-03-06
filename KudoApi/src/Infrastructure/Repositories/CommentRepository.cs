using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using MongoDB.Driver;

namespace KudoApi.Infrastructure.Repositories
{
    public class CommentRepository : ICommentRepository
    {
        private readonly MongoDbContext _context;

        public CommentRepository(MongoDbContext context)
        {
            _context = context;
        }

        public async Task<List<Comment>> GetByProjectIdAsync(string projectId)
        {
            return await _context.Comments
                .Find(c => c.ProjectId == projectId)
                .SortByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task CreateAsync(Comment comment)
        {
            await _context.Comments.InsertOneAsync(comment);
        }

        public async Task DeleteAsync(string id)
        {
            await _context.Comments.DeleteOneAsync(c => c.Id == id);
        }
    }
}
