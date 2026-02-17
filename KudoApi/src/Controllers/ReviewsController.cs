using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace KudoApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly ReviewService _reviewService;

        public ReviewsController(ReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        [HttpGet("project/{projectId}")]
        public async Task<ActionResult<List<Review>>> GetByProject(string projectId)
        {
            return await _reviewService.GetByProjectIdAsync(projectId);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Review>> Get(string id)
        {
            var review = await _reviewService.GetByIdAsync(id);
            if (review == null) return NotFound();
            return review;
        }

        [HttpPost]
        public async Task<IActionResult> Create(Review review)
        {
            await _reviewService.CreateAsync(review);
            return CreatedAtAction(nameof(Get), new { id = review.Id }, review);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var review = await _reviewService.GetByIdAsync(id);
            if (review == null) return NotFound();
            await _reviewService.DeleteAsync(id);
            return NoContent();
        }
    }
}
