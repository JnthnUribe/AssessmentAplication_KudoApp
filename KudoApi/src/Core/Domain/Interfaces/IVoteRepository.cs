using KudoApi.Core.Domain.Entities;

namespace KudoApi.Core.Domain.Interfaces
{
    public interface IVoteRepository
    {
        Task<Vote?> GetByProjectAndVoterAsync(string projectId, string voterId);
        Task<List<Vote>> GetByProjectIdAsync(string projectId);
        Task CreateAsync(Vote vote);
    }
}
