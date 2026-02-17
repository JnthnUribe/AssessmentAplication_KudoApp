using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using MongoDB.Driver;

namespace KudoApi.Infrastructure.Repositories
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly MongoDbContext _context;

        public ReviewRepository(MongoDbContext context)
        {
            _context = context;
        }

        public async Task<List<Review>> GetByProjectIdAsync(string projectId)
        {
            return await _context.Reviews.Find(r => r.ProjectId == projectId).ToListAsync();
        }

        public async Task<Review?> GetByIdAsync(string id)
        {
            return await _context.Reviews.Find(r => r.Id == id).FirstOrDefaultAsync();
        }

        public async Task CreateAsync(Review review)
        {
            await _context.Reviews.InsertOneAsync(review);
        }

        public async Task DeleteAsync(string id)
        {
            await _context.Reviews.DeleteOneAsync(r => r.Id == id);
        }
    }
}
