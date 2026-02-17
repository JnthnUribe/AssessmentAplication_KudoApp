using KudoApi.Core.Domain.Entities;

namespace KudoApi.Core.Domain.Interfaces
{
    public interface IReviewRepository
    {
        Task<List<Review>> GetByProjectIdAsync(string projectId);
        Task<Review?> GetByIdAsync(string id);
        Task CreateAsync(Review review);
        Task DeleteAsync(string id);
    }
}
