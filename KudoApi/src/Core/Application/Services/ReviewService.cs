using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class ReviewService
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IUserRepository _userRepository;

        public ReviewService(IReviewRepository reviewRepository, IUserRepository userRepository)
        {
            _reviewRepository = reviewRepository;
            _userRepository = userRepository;
        }

        public async Task<List<Review>> GetByProjectIdAsync(string projectId) => await _reviewRepository.GetByProjectIdAsync(projectId);
        public async Task<Review?> GetByIdAsync(string id) => await _reviewRepository.GetByIdAsync(id);

        public async Task CreateAsync(Review review)
        {
            // 1. Validate Judge
            var judge = await _userRepository.GetByIdAsync(review.JudgeId);
            if (judge == null)
            {
                throw new Exception("Judge not found."); // In a real app, use specific exceptions or Result pattern
            }

            if (!string.Equals(judge.Role, "judge", StringComparison.OrdinalIgnoreCase) && 
                !string.Equals(judge.Role, "juez", StringComparison.OrdinalIgnoreCase)) // Allowing both for flexibility based on user prompt
            {
                throw new Exception("User is not a judge.");
            }

            // 2. Auto-populate Snapshot
            review.JudgeFullNameSnap = $"{judge.FirstName} {judge.FirstSurname}".Trim();

            // 3. Set Dates
            review.CreatedAt = DateTime.UtcNow;

            await _reviewRepository.CreateAsync(review);
        }

        public async Task DeleteAsync(string id) => await _reviewRepository.DeleteAsync(id);
    }
}
