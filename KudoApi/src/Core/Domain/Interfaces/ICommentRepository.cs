using KudoApi.Core.Domain.Entities;

namespace KudoApi.Core.Domain.Interfaces
{
    public interface ICommentRepository
    {
        Task<List<Comment>> GetByProjectIdAsync(string projectId);
        Task CreateAsync(Comment comment);
        Task DeleteAsync(string id);
    }
}
