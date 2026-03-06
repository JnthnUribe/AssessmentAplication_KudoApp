using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace KudoApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VotesController : ControllerBase
    {
        private readonly VoteService _voteService;

        public VotesController(VoteService voteService)
        {
            _voteService = voteService;
        }

        /// <summary>
        /// POST /api/votes — Registrar un voto
        /// Body: { projectId, voterId, score }
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Submit(Vote vote)
        {
            var (success, message, alreadyVoted) = await _voteService.SubmitVoteAsync(vote);

            if (alreadyVoted)
            {
                return Conflict(new { message, alreadyVoted = true });
            }

            if (!success)
            {
                return BadRequest(new { message });
            }

            return Ok(new { message });
        }

        /// <summary>
        /// GET /api/votes/check?projectId=xxx&amp;voterId=yyy
        /// </summary>
        [HttpGet("check")]
        public async Task<IActionResult> Check(
            [FromQuery] string projectId,
            [FromQuery] string voterId)
        {
            var (hasVoted, score, comment, tags) = await _voteService.CheckVoteAsync(projectId, voterId);
            return Ok(new { hasVoted, score, comment, tags });
        }
    }
}
