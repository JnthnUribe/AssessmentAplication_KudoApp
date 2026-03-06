using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace KudoApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProjectsController : ControllerBase
    {
        private readonly ProjectService _projectService;

        public ProjectsController(ProjectService projectService)
        {
            _projectService = projectService;
        }

        [HttpGet]
        public async Task<ActionResult<List<Project>>> GetAll() => await _projectService.GetAllAsync();

        [HttpGet("{id}")]
        public async Task<ActionResult<Project>> Get(string id)
        {
            var project = await _projectService.GetByIdAsync(id);
            if (project == null) return NotFound();
            return project;
        }

        [HttpGet("creator/{creatorId}")]
        public async Task<ActionResult<List<Project>>> GetByCreator(string creatorId)
        {
            return await _projectService.GetByCreatorIdAsync(creatorId);
        }

        [HttpGet("qr/{token}")]
        public async Task<ActionResult<Project>> GetByQrToken(string token)
        {
            var project = await _projectService.GetByQrTokenAsync(token);
            if (project == null) return NotFound(new { message = "Proyecto no encontrado con ese QR" });
            return project;
        }

        [HttpPost]
        public async Task<IActionResult> Create(Project project)
        {
            await _projectService.CreateAsync(project);
            return CreatedAtAction(nameof(Get), new { id = project.Id }, project);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, Project project)
        {
            var existingProject = await _projectService.GetByIdAsync(id);
            if (existingProject == null) return NotFound();
            await _projectService.UpdateAsync(id, project);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var project = await _projectService.GetByIdAsync(id);
            if (project == null) return NotFound();
            await _projectService.DeleteAsync(id);
            return NoContent();
        }
    }
}
