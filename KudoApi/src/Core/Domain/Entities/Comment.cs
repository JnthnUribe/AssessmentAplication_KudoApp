using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Core.Domain.Entities
{
    public class Comment
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("projectId")]
        [BsonRepresentation(BsonType.ObjectId)]
        [System.Text.Json.Serialization.JsonPropertyName("projectId")]
        public string ProjectId { get; set; } = string.Empty;

        [BsonElement("authorName")]
        [System.Text.Json.Serialization.JsonPropertyName("authorName")]
        public string AuthorName { get; set; } = string.Empty;

        [BsonElement("text")]
        [System.Text.Json.Serialization.JsonPropertyName("text")]
        public string Text { get; set; } = string.Empty;

        [BsonElement("tags")]
        [System.Text.Json.Serialization.JsonPropertyName("tags")]
        public List<string> Tags { get; set; } = new();

        [BsonElement("createdAt")]
        [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
