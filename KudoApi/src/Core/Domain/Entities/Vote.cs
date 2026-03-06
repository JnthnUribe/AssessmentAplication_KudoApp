using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Core.Domain.Entities
{
    public class Vote
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("projectId")]
        [BsonRepresentation(BsonType.ObjectId)]
        [System.Text.Json.Serialization.JsonPropertyName("projectId")]
        public string ProjectId { get; set; } = string.Empty;

        [BsonElement("voterId")]
        [System.Text.Json.Serialization.JsonPropertyName("voterId")]
        public string VoterId { get; set; } = string.Empty;

        [BsonElement("score")]
        [System.Text.Json.Serialization.JsonPropertyName("score")]
        public int Score { get; set; }

        [BsonElement("comment")]
        [System.Text.Json.Serialization.JsonPropertyName("comment")]
        public string Comment { get; set; } = string.Empty;

        [BsonElement("tags")]
        [System.Text.Json.Serialization.JsonPropertyName("tags")]
        public List<string> Tags { get; set; } = new();

        [BsonElement("createdAt")]
        [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
