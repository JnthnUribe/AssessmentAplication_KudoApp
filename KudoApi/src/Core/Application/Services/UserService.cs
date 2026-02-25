using KudoApi.Core.Application.DTOs;
using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;

namespace KudoApi.Core.Application.Services
{
    public class UserService
    {
        private readonly IUserRepository _userRepository;

        public UserService(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<List<User>> GetAllAsync() => await _userRepository.GetAllAsync();
        public async Task<User?> GetByIdAsync(string id) => await _userRepository.GetByIdAsync(id);
        public async Task<User?> GetByEmailAsync(string email) => await _userRepository.GetByEmailAsync(email);
        
        public async Task CreateAsync(User user)
        {
            user.CreatedAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;
            await _userRepository.CreateAsync(user);
        }

        public async Task<User> RegisterAsync(RegisterRequest request)
        {
            // Sanitization: Trim and Lowercase
            var email = request.Email.Trim().ToLower();
            var firstName = request.FirstName.Trim();
            var firstSurname = request.FirstSurname.Trim();

            // Uniqueness check
            var existingUser = await _userRepository.GetByEmailAsync(email);
            if (existingUser != null)
            {
                throw new Exception("El correo electrónico ya está registrado.");
            }

            var user = new User
            {
                FirstName = firstName,
                FirstSurname = firstSurname,
                Email = email,
                PasswordHash = request.Password, // In production, hash this!
                Role = "User", // Default role
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _userRepository.CreateAsync(user);
            return user;
        }

        public async Task UpdateAsync(string id, User user)
        {
            var existingUser = await _userRepository.GetByIdAsync(id);
            if (existingUser != null)
            {
                user.CreatedAt = existingUser.CreatedAt;
            }
            
            user.Id = id;
            user.UpdatedAt = DateTime.UtcNow;
            await _userRepository.UpdateAsync(id, user);
        }

        public async Task DeleteAsync(string id) => await _userRepository.DeleteAsync(id);
    }
}
