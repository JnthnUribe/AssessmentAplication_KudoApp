using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class VoteService
    {
        private readonly IVoteRepository _voteRepository;
        private readonly IProjectRepository _projectRepository;

        public VoteService(IVoteRepository voteRepository, IProjectRepository projectRepository)
        {
            _voteRepository = voteRepository;
            _projectRepository = projectRepository;
        }

        /// <summary>
        /// Registra un voto. Retorna (success, message, alreadyVoted)
        /// </summary>
        public async Task<(bool success, string message, bool alreadyVoted)> SubmitVoteAsync(Vote vote)
        {
            // Check for duplicate vote
            var existing = await _voteRepository.GetByProjectAndVoterAsync(vote.ProjectId, vote.VoterId);
            if (existing != null)
            {
                return (false, "Ya has votado por este proyecto", true);
            }

            // Validate score
            if (vote.Score < 1 || vote.Score > 5)
            {
                return (false, "La calificación debe ser entre 1 y 5", false);
            }

            // Validate project exists
            var project = await _projectRepository.GetByIdAsync(vote.ProjectId);
            if (project == null)
            {
                return (false, "Proyecto no encontrado", false);
            }

            // Save vote
            vote.CreatedAt = DateTime.UtcNow;
            await _voteRepository.CreateAsync(vote);

            // Recalculate totalVotes and averageRating
            var allVotes = await _voteRepository.GetByProjectIdAsync(vote.ProjectId);
            project.TotalVotes = allVotes.Count;
            project.AverageRating = allVotes.Count > 0
                ? Math.Round(allVotes.Average(v => v.Score), 2)
                : 0;
            project.UpdatedAt = DateTime.UtcNow;
            await _projectRepository.UpdateAsync(project.Id!, project);

            return (true, "¡Voto registrado exitosamente!", false);
        }

        /// <summary>
        /// Verifica si un voterId ya votó por un proyecto
        /// </summary>
        public async Task<(bool hasVoted, int score, string comment, List<string> tags)> CheckVoteAsync(string projectId, string voterId)
        {
            var vote = await _voteRepository.GetByProjectAndVoterAsync(projectId, voterId);
            if (vote != null)
            {
                return (true, vote.Score, vote.Comment, vote.Tags);
            }
            return (false, 0, "", new List<string>());
        }
    }
}
