using Microsoft.AspNetCore.Mvc;
using KudoApi.Models;
using KudoApi.Services;

namespace KudoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private readonly MongoDbService _mongoService;

    public ProjectsController(MongoDbService mongoService)
    {
        _mongoService = mongoService;
    }

    /// <summary>
    /// GET /api/projects
    /// Retorna la lista de todos los proyectos
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<Project>>> GetProjects()
    {
        var projects = await _mongoService.GetAllProjectsAsync();
        return Ok(projects);
    }

    /// <summary>
    /// GET /api/projects/{id}
    /// Retorna un proyecto específico por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Project>> GetProject(string id)
    {
        var project = await _mongoService.GetProjectByIdAsync(id);
        
        if (project == null)
        {
            return NotFound(new { message = "Proyecto no encontrado" });
        }
        
        return Ok(project);
    }
}
