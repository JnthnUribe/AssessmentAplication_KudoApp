using KudoApi.Core.Domain.Entities;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace KudoApi.Infrastructure.Data
{
    public class MongoDbContext
    {
        private readonly IMongoDatabase _database;

        public MongoDbContext(IConfiguration configuration)
        {
            var connectionString = configuration.GetValue<string>("MongoDbSettings:ConnectionString");
            var databaseName = configuration.GetValue<string>("MongoDbSettings:DatabaseName");
            var settings = MongoClientSettings.FromConnectionString(connectionString);
            settings.ConnectTimeout = TimeSpan.FromSeconds(60); // Increase timeout to 60 seconds
            var client = new MongoClient(settings);
            _database = client.GetDatabase(databaseName);
        }

        public IMongoCollection<User> Users => _database.GetCollection<User>("users");
        public IMongoCollection<Project> Projects => _database.GetCollection<Project>("projects");
        public IMongoCollection<Review> Reviews => _database.GetCollection<Review>("reviews");
        public IMongoCollection<Vote> Votes => _database.GetCollection<Vote>("votes");
        public IMongoCollection<Comment> Comments => _database.GetCollection<Comment>("comments");
    }
}
