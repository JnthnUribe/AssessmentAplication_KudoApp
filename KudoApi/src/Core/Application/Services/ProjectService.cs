using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class ProjectService
    {
        private readonly IProjectRepository _projectRepository;

        public ProjectService(IProjectRepository projectRepository)
        {
            _projectRepository = projectRepository;
        }

        public async Task<List<Project>> GetAllAsync() => await _projectRepository.GetAllAsync();
        public async Task<Project?> GetByIdAsync(string id) => await _projectRepository.GetByIdAsync(id);
        public async Task<List<Project>> GetByCreatorIdAsync(string creatorId) => await _projectRepository.GetByCreatorIdAsync(creatorId);
        public async Task<Project?> GetByQrTokenAsync(string qrToken) => await _projectRepository.GetByQrTokenAsync(qrToken);

        public async Task CreateAsync(Project project)
        {
            project.CreatedAt = DateTime.UtcNow;
            project.UpdatedAt = DateTime.UtcNow;
            await _projectRepository.CreateAsync(project);
        }

        public async Task UpdateAsync(string id, Project project)
        {
            var existingProject = await _projectRepository.GetByIdAsync(id);
            if (existingProject != null)
            {
                project.CreatedAt = existingProject.CreatedAt;
            }

            project.Id = id;
            project.UpdatedAt = DateTime.UtcNow;
            await _projectRepository.UpdateAsync(id, project);
        }

        public async Task DeleteAsync(string id) => await _projectRepository.DeleteAsync(id);
    }
}
