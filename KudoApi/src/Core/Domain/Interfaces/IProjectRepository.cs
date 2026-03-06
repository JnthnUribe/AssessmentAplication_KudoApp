using KudoApi.Core.Domain.Entities;

namespace KudoApi.Core.Domain.Interfaces
{
    public interface IProjectRepository
    {
        Task<List<Project>> GetAllAsync();
        Task<Project?> GetByIdAsync(string id);
        Task<List<Project>> GetByCreatorIdAsync(string creatorId);
        Task<Project?> GetByQrTokenAsync(string qrToken);
        Task CreateAsync(Project project);
        Task UpdateAsync(string id, Project project);
        Task DeleteAsync(string id);
        Task DeleteByCreatorIdAsync(string creatorId);
    }
}
