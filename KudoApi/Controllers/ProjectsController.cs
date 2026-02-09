using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using KudoApi.Models;

namespace KudoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProjectsController : ControllerBase
{
    private readonly IMongoCollection<Project> _projectsCollection;

    public ProjectsController(IMongoDatabase database)
    {
        // Conectamos directo a la colección "Projects" que creaste en Compass
        _projectsCollection = database.GetCollection<Project>("Projects");
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        // Busca todos los documentos y los devuelve como JSON limpio
        var projects = await _projectsCollection.Find(_ => true).ToListAsync();
        return Ok(projects);
    }
}