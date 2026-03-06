using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class ProjectService
    {
        private readonly IProjectRepository _projectRepository;
        private readonly CloudinaryService _cloudinaryService;

        public ProjectService(IProjectRepository projectRepository, CloudinaryService cloudinaryService)
        {
            _projectRepository = projectRepository;
            _cloudinaryService = cloudinaryService;
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

        public async Task DeleteAsync(string id)
        {
            var project = await _projectRepository.GetByIdAsync(id);
            if (project != null && project.Media != null && project.Media.Images != null)
            {
                foreach (var image in project.Media.Images)
                {
                    if (!string.IsNullOrEmpty(image.DeleteToken))
                    {
                        await _cloudinaryService.DeleteImageByTokenAsync(image.DeleteToken);
                    }
                }
            }
            await _projectRepository.DeleteAsync(id);
        }

        public async Task DeleteByCreatorIdAsync(string creatorId)
        {
            var projects = await _projectRepository.GetByCreatorIdAsync(creatorId);
            foreach (var project in projects)
            {
                if (project.Id != null)
                {
                    await DeleteAsync(project.Id);
                }
            }
        }
    }
}
