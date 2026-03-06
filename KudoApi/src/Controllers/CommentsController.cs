using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace KudoApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CommentsController : ControllerBase
    {
        private readonly CommentService _commentService;

        public CommentsController(CommentService commentService)
        {
            _commentService = commentService;
        }

        /// <summary>
        /// GET /api/comments/project/{projectId}
        /// </summary>
        [HttpGet("project/{projectId}")]
        public async Task<ActionResult<List<Comment>>> GetByProject(string projectId)
        {
            return await _commentService.GetByProjectIdAsync(projectId);
        }

        /// <summary>
        /// POST /api/comments
        /// Body: { projectId, authorName, text, tags }
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create(Comment comment)
        {
            if (string.IsNullOrWhiteSpace(comment.Text))
                return BadRequest(new { message = "El comentario no puede estar vacío" });

            if (string.IsNullOrWhiteSpace(comment.AuthorName))
                comment.AuthorName = "Anónimo";

            await _commentService.CreateAsync(comment);
            return Ok(new { message = "Comentario publicado", id = comment.Id });
        }

        /// <summary>
        /// DELETE /api/comments/{id}
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _commentService.DeleteAsync(id);
            return NoContent();
        }
    }
}
