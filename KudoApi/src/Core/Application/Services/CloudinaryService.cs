using System.Net.Http.Json;

namespace KudoApi.Core.Application.Services
{
    public class CloudinaryService
    {
        private readonly HttpClient _httpClient;
        private readonly string _cloudName;

        public CloudinaryService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            // Get from Env or Config
            _cloudName = Environment.GetEnvironmentVariable("CLOUDINARY_CLOUD_NAME") 
                         ?? configuration["Cloudinary:CloudName"] 
                         ?? "dufvodhuw";
        }

        public async Task<bool> DeleteImageByTokenAsync(string deleteToken)
        {
            if (string.IsNullOrEmpty(deleteToken)) return false;

            try
            {
                var response = await _httpClient.PostAsJsonAsync(
                    $"https://api.cloudinary.com/v1_1/{_cloudName}/delete_by_token",
                    new { token = deleteToken }
                );

                return response.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                // Log error in production
                Console.WriteLine($"Error deleting image from Cloudinary: {ex.Message}");
                return false;
            }
        }
    }
}
