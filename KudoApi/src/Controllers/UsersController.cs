using KudoApi.Core.Application.DTOs;
using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace KudoApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly UserService _userService;

        public UsersController(UserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<ActionResult<List<User>>> GetAll() => await _userService.GetAllAsync();

        [HttpGet("{id}")]
        public async Task<ActionResult<User>> Get(string id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null) return NotFound();
            return user;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                var user = await _userService.RegisterAsync(request);
                return CreatedAtAction(nameof(Get), new { id = user.Id }, user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create(User user)
        {
            await _userService.CreateAsync(user);
            return CreatedAtAction(nameof(Get), new { id = user.Id }, user);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, User user)
        {
            var existingUser = await _userService.GetByIdAsync(id);
            if (existingUser == null) return NotFound();
            await _userService.UpdateAsync(id, user);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null) return NotFound();
            await _userService.DeleteAsync(id);
            return NoContent();
        }
        [HttpPost("login")]
        public async Task<ActionResult<User>> Login([FromBody] KudoApi.Core.Application.DTOs.LoginRequest request)
        {
            var user = await _userService.GetByEmailAsync(request.Email);
            
            if (user == null)
            {
                return Unauthorized("Invalid email or password"); // Security best practice: generic message
            }

            // Simple string comparison as requested. In production, use hashing!
            if (user.PasswordHash != request.Password)
            {
                return Unauthorized("Invalid email or password");
            }

            return Ok(user);
        }
    }
}
