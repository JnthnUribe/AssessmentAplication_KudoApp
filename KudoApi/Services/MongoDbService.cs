using MongoDB.Driver;
using KudoApi.Models;

namespace KudoApi.Services;

/// <summary>
/// Servicio para conexión y operaciones con MongoDB
/// </summary>
public class MongoDbService
{
    private readonly IMongoDatabase _database;
    private readonly IMongoCollection<Project> _projects;

    public MongoDbService(IConfiguration configuration)
    {
        var connectionString = configuration["MongoDB:ConnectionString"] 
            ?? "mongodb://localhost:27017";
        var databaseName = configuration["MongoDB:DatabaseName"] 
            ?? "KudoDb";

        var client = new MongoClient(connectionString);
        _database = client.GetDatabase(databaseName);
        _projects = _database.GetCollection<Project>("projects");
    }

    /// <summary>
    /// Obtiene todos los proyectos de la base de datos
    /// </summary>
    public async Task<List<Project>> GetAllProjectsAsync()
    {
        return await _projects.Find(_ => true).ToListAsync();
    }

    /// <summary>
    /// Obtiene un proyecto por su ID
    /// </summary>
    public async Task<Project?> GetProjectByIdAsync(string id)
    {
        return await _projects.Find(p => p.Id == id).FirstOrDefaultAsync();
    }

    /// <summary>
    /// Acceso a la colección de proyectos (para operaciones avanzadas)
    /// </summary>
    public IMongoCollection<Project> Projects => _projects;
}
