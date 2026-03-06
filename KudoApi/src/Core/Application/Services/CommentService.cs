using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class CommentService
    {
        private readonly ICommentRepository _commentRepository;

        public CommentService(ICommentRepository commentRepository)
        {
            _commentRepository = commentRepository;
        }

        public async Task<List<Comment>> GetByProjectIdAsync(string projectId)
            => await _commentRepository.GetByProjectIdAsync(projectId);

        public async Task CreateAsync(Comment comment)
        {
            comment.CreatedAt = DateTime.UtcNow;
            await _commentRepository.CreateAsync(comment);
        }

        public async Task DeleteAsync(string id)
            => await _commentRepository.DeleteAsync(id);
    }
}
