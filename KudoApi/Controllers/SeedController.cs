using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using KudoApi.Models;

namespace KudoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SeedController : ControllerBase
{
    private readonly IMongoCollection<Project> _projectsCollection;

    public SeedController(IMongoDatabase database)
    {
        _projectsCollection = database.GetCollection<Project>("Projects");
    }

    /// <summary>
    /// Inserta proyectos de prueba en la base de datos.
    /// Solo funciona si la colección está vacía.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SeedProjects()
    {
        var existingCount = await _projectsCollection.CountDocumentsAsync(_ => true);
        if (existingCount > 0)
        {
            return Ok(new { message = $"La base de datos ya tiene {existingCount} proyectos. No se insertaron datos." });
        }

        var projects = new List<Project>
        {
            new Project
            {
                Title = "EcoTracker",
                Category = "Medio Ambiente",
                Description = "Aplicación móvil para rastrear y reducir tu huella de carbono diaria mediante gamificación y retos comunitarios.",
                ImageUrl = "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800",
                TotalVotes = 142
            },
            new Project
            {
                Title = "MediConnect",
                Category = "Salud",
                Description = "Plataforma que conecta pacientes rurales con especialistas médicos mediante telemedicina y seguimiento de tratamientos.",
                ImageUrl = "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800",
                TotalVotes = 98
            },
            new Project
            {
                Title = "SmartFarm AI",
                Category = "Agricultura",
                Description = "Sistema de monitoreo agrícola con sensores IoT e inteligencia artificial para optimizar riego y detección temprana de plagas.",
                ImageUrl = "https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800",
                TotalVotes = 215
            },
            new Project
            {
                Title = "ReciclaYA",
                Category = "Medio Ambiente",
                Description = "App que identifica materiales reciclables con la cámara del celular y muestra puntos de reciclaje cercanos en tu ciudad.",
                ImageUrl = "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800",
                TotalVotes = 76
            },
            new Project
            {
                Title = "EduCode Kids",
                Category = "Educación",
                Description = "Plataforma interactiva de programación para niños de 6-12 años con bloques visuales, historias y personajes animados.",
                ImageUrl = "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800",
                TotalVotes = 183
            }
        };

        await _projectsCollection.InsertManyAsync(projects);

        return Ok(new { message = $"Se insertaron {projects.Count} proyectos de prueba exitosamente.", count = projects.Count });
    }
}
