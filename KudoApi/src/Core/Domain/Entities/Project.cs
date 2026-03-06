using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Core.Domain.Entities
{
    public class Project
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("creatorId")]
        [BsonRepresentation(BsonType.ObjectId)]
        [System.Text.Json.Serialization.JsonPropertyName("creatorId")]
        public string CreatorId { get; set; } = string.Empty;

        [BsonElement("qrToken")]
        [System.Text.Json.Serialization.JsonPropertyName("qrToken")]
        public string QrToken { get; set; } = string.Empty;

        [BsonElement("status")]
        [System.Text.Json.Serialization.JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;

        [BsonElement("isDeleted")]
        [System.Text.Json.Serialization.JsonPropertyName("isDeleted")]
        public bool IsDeleted { get; set; } = false;

        [BsonElement("identity")]
        [System.Text.Json.Serialization.JsonPropertyName("identity")]
        public ProjectIdentity Identity { get; set; } = new();

        [BsonElement("narrative")]
        [System.Text.Json.Serialization.JsonPropertyName("narrative")]
        public ProjectNarrative Narrative { get; set; } = new();

        [BsonElement("techStack")]
        [System.Text.Json.Serialization.JsonPropertyName("techStack")]
        public List<string> TechStack { get; set; } = new();

        [BsonElement("outcomes")]
        [System.Text.Json.Serialization.JsonPropertyName("outcomes")]
        public ProjectOutcomes Outcomes { get; set; } = new();

        [BsonElement("media")]
        [System.Text.Json.Serialization.JsonPropertyName("media")]
        public ProjectMedia Media { get; set; } = new();

        [BsonElement("totalVotes")]
        [System.Text.Json.Serialization.JsonPropertyName("totalVotes")]
        public int TotalVotes { get; set; } = 0;

        [BsonElement("averageRating")]
        [System.Text.Json.Serialization.JsonPropertyName("averageRating")]
        public double AverageRating { get; set; } = 0;

        [BsonElement("createdAt")]
        [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        [System.Text.Json.Serialization.JsonPropertyName("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class ProjectIdentity
    {
        [BsonElement("title")]
        [System.Text.Json.Serialization.JsonPropertyName("title")]
        public string Title { get; set; } = string.Empty;

        [BsonElement("category")]
        [System.Text.Json.Serialization.JsonPropertyName("category")]
        public string Category { get; set; } = string.Empty;

        [BsonElement("platform")]
        [System.Text.Json.Serialization.JsonPropertyName("platform")]
        public string Platform { get; set; } = string.Empty;
    }

    public class ProjectNarrative
    {
        [BsonElement("problem")]
        [System.Text.Json.Serialization.JsonPropertyName("problem")]
        public string Problem { get; set; } = string.Empty;

        [BsonElement("roleDescription")]
        [System.Text.Json.Serialization.JsonPropertyName("roleDescription")]
        public string RoleDescription { get; set; } = string.Empty;
    }

    public class ProjectOutcomes
    {
        [BsonElement("results")]
        [System.Text.Json.Serialization.JsonPropertyName("results")]
        public List<string> Results { get; set; } = new();

        [BsonElement("learnings")]
        [System.Text.Json.Serialization.JsonPropertyName("learnings")]
        public List<string> Learnings { get; set; } = new();
    }

    public class ProjectMedia
    {
        [BsonElement("images")]
        [System.Text.Json.Serialization.JsonPropertyName("images")]
        public List<MediaItem> Images { get; set; } = new();

        [BsonElement("videoUrl")]
        [System.Text.Json.Serialization.JsonPropertyName("videoUrl")]
        public string VideoUrl { get; set; } = string.Empty;

        [BsonElement("links")]
        [System.Text.Json.Serialization.JsonPropertyName("links")]
        public List<ProjectLink> Links { get; set; } = new();

        // Deprecated: Keeping temporarily for migration if needed, but will prioritize 'images'
        [BsonElement("imageUrls")]
        [BsonIgnoreIfNull]
        public List<string>? ImageUrls { get; set; }

        [BsonElement("deleteTokens")]
        [BsonIgnoreIfNull]
        public List<MediaToken>? DeleteTokens { get; set; }
    }

    public class MediaItem
    {
        [BsonElement("url")]
        [System.Text.Json.Serialization.JsonPropertyName("url")]
        public string Url { get; set; } = string.Empty;

        [BsonElement("deleteToken")]
        [System.Text.Json.Serialization.JsonPropertyName("deleteToken")]
        public string DeleteToken { get; set; } = string.Empty;
    }

    public class MediaToken
    {
        [BsonElement("url")]
        [System.Text.Json.Serialization.JsonPropertyName("url")]
        public string Url { get; set; } = string.Empty;

        [BsonElement("token")]
        [System.Text.Json.Serialization.JsonPropertyName("token")]
        public string Token { get; set; } = string.Empty;
    }

    public class ProjectLink
    {
        [BsonElement("label")]
        [System.Text.Json.Serialization.JsonPropertyName("label")]
        public string Label { get; set; } = string.Empty;

        [BsonElement("url")]
        [System.Text.Json.Serialization.JsonPropertyName("url")]
        public string Url { get; set; } = string.Empty;
    }
}
