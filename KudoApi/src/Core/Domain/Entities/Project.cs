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
        public string CreatorId { get; set; } = string.Empty;

        [BsonElement("qrToken")]
        public string QrToken { get; set; } = string.Empty;

        [BsonElement("status")]
        public string Status { get; set; } = string.Empty;

        [BsonElement("platform")]
        public string Platform { get; set; } = string.Empty;

        [BsonElement("isDeleted")]
        public bool IsDeleted { get; set; } = false;

        [BsonElement("identity")]
        public ProjectIdentity Identity { get; set; } = new();

        [BsonElement("narrative")]
        public ProjectNarrative Narrative { get; set; } = new();

        [BsonElement("techStack")]
        public List<string> TechStack { get; set; } = new();

        [BsonElement("outcomes")]
        public ProjectOutcomes Outcomes { get; set; } = new();

        [BsonElement("media")]
        public ProjectMedia Media { get; set; } = new();

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class ProjectIdentity
    {
        [BsonElement("title")]
        public string Title { get; set; } = string.Empty;

        [BsonElement("category")]
        public string Category { get; set; } = string.Empty;
    }

    public class ProjectNarrative
    {
        [BsonElement("problem")]
        public string Problem { get; set; } = string.Empty;

        [BsonElement("roleDescription")]
        public string RoleDescription { get; set; } = string.Empty;
    }

    public class ProjectOutcomes
    {
        [BsonElement("results")]
        public List<string> Results { get; set; } = new();

        [BsonElement("learnings")]
        public List<string> Learnings { get; set; } = new();
    }

    public class ProjectMedia
    {
        [BsonElement("imageUrls")]
        public List<string> ImageUrls { get; set; } = new();

        [BsonElement("videoUrl")]
        public string VideoUrl { get; set; } = string.Empty;

        [BsonElement("links")]
        public List<ProjectLink> Links { get; set; } = new();
    }

    public class ProjectLink
    {
        [BsonElement("label")]
        public string Label { get; set; } = string.Empty;

        [BsonElement("url")]
        public string Url { get; set; } = string.Empty;
    }
}
