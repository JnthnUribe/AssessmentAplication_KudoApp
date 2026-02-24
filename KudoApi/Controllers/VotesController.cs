using Microsoft.AspNetCore.Mvc;
using MongoDB.Driver;
using KudoApi.Core.Domain.Entities;
using KudoApi.Models;

namespace KudoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VotesController : ControllerBase
{
    private readonly IMongoCollection<Vote> _votesCollection;
    private readonly IMongoCollection<Project> _projectsCollection;

    public VotesController(IMongoDatabase database)
    {
        _votesCollection = database.GetCollection<Vote>("Votes");
        _projectsCollection = database.GetCollection<Project>("projects");
    }

    /// <summary>
    /// Registra un voto. Un voterId solo puede votar 1 vez por proyecto.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SubmitVote([FromBody] VoteRequest request)
    {
        // Validaciones básicas
        if (string.IsNullOrEmpty(request.ProjectId) || string.IsNullOrEmpty(request.VoterId))
            return BadRequest(new { message = "projectId y voterId son requeridos." });

        if (request.Score < 1 || request.Score > 5)
            return BadRequest(new { message = "El score debe ser entre 1 y 5." });

        // Verificar que el proyecto existe
        var projectFilter = Builders<Project>.Filter.Eq(p => p.Id, request.ProjectId);
        var project = await _projectsCollection.Find(projectFilter).FirstOrDefaultAsync();
        if (project == null)
            return NotFound(new { message = "Proyecto no encontrado." });

        // Verificar si ya votó este dispositivo por este proyecto
        var existingVote = await _votesCollection.Find(v =>
            v.VoterId == request.VoterId && v.ProjectId == request.ProjectId
        ).FirstOrDefaultAsync();

        if (existingVote != null)
            return Conflict(new { message = "Ya votaste por este proyecto.", alreadyVoted = true });

        // Crear el voto
        var vote = new Vote
        {
            ProjectId = request.ProjectId,
            VoterId = request.VoterId,
            Score = request.Score,
            VotedAt = DateTime.UtcNow
        };

        await _votesCollection.InsertOneAsync(vote);

        return Ok(new { message = "¡Voto registrado exitosamente!", voteId = vote.Id });
    }

    /// <summary>
    /// Verifica si un voterId ya votó por un proyecto específico.
    /// </summary>
    [HttpGet("check")]
    public async Task<IActionResult> CheckVote([FromQuery] string projectId, [FromQuery] string voterId)
    {
        var existingVote = await _votesCollection.Find(v =>
            v.VoterId == voterId && v.ProjectId == projectId
        ).FirstOrDefaultAsync();

        return Ok(new { hasVoted = existingVote != null, score = existingVote?.Score ?? 0 });
    }
}

/// <summary>
/// Request body para enviar un voto
/// </summary>
public class VoteRequest
{
    public string ProjectId { get; set; } = string.Empty;
    public string VoterId { get; set; } = string.Empty;
    public int Score { get; set; }
}
