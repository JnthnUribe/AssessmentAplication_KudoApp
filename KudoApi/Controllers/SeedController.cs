using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using KudoApi.Core.Domain.Entities;

namespace KudoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SeedController : ControllerBase
{
    private readonly IMongoCollection<Project> _projectsCollection;

    public SeedController(IMongoDatabase database)
    {
        _projectsCollection = database.GetCollection<Project>("projects");
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
                Identity = new ProjectIdentity { Title = "EcoTracker", Category = "Medio Ambiente", Platform = "Mobile" },
                Narrative = new ProjectNarrative { Problem = "Aplicación móvil para rastrear y reducir tu huella de carbono diaria mediante gamificación y retos comunitarios." },
                Status = "active"
            },
            new Project
            {
                Identity = new ProjectIdentity { Title = "MediConnect", Category = "Salud", Platform = "Web" },
                Narrative = new ProjectNarrative { Problem = "Plataforma que conecta pacientes rurales con especialistas médicos mediante telemedicina y seguimiento de tratamientos." },
                Status = "active"
            },
            new Project
            {
                Identity = new ProjectIdentity { Title = "SmartFarm AI", Category = "Agricultura", Platform = "IoT" },
                Narrative = new ProjectNarrative { Problem = "Sistema de monitoreo agrícola con sensores IoT e inteligencia artificial para optimizar riego y detección temprana de plagas." },
                Status = "active"
            },
            new Project
            {
                Identity = new ProjectIdentity { Title = "ReciclaYA", Category = "Medio Ambiente", Platform = "Mobile" },
                Narrative = new ProjectNarrative { Problem = "App que identifica materiales reciclables con la cámara del celular y muestra puntos de reciclaje cercanos en tu ciudad." },
                Status = "active"
            },
            new Project
            {
                Identity = new ProjectIdentity { Title = "EduCode Kids", Category = "Educación", Platform = "Web" },
                Narrative = new ProjectNarrative { Problem = "Plataforma interactiva de programación para niños de 6-12 años con bloques visuales, historias y personajes animados." },
                Status = "active"
            }
        };

        await _projectsCollection.InsertManyAsync(projects);

        return Ok(new { message = $"Se insertaron {projects.Count} proyectos de prueba exitosamente.", count = projects.Count });
    }
}
