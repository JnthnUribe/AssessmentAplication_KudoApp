using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Core.Domain.Entities
{
    public class Review
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("projectId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string ProjectId { get; set; } = string.Empty;

        [BsonElement("judgeId")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string JudgeId { get; set; } = string.Empty;

        [BsonElement("score")]
        public int Score { get; set; }

        [BsonElement("comment")]
        public string Comment { get; set; } = string.Empty;

        [BsonElement("judgeFullNameSnap")]
        public string JudgeFullNameSnap { get; set; } = string.Empty;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
