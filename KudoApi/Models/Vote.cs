using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Models;

/// <summary>
/// Modelo de Voto para MongoDB
/// </summary>
[BsonIgnoreExtraElements]
public class Vote
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = string.Empty;

    [BsonElement("projectId")]
    [BsonRepresentation(BsonType.ObjectId)]
    public string ProjectId { get; set; } = string.Empty;

    [BsonElement("voterId")]
    public string VoterId { get; set; } = string.Empty;

    [BsonElement("score")]
    public int Score { get; set; } = 0;

    [BsonElement("votedAt")]
    public DateTime VotedAt { get; set; } = DateTime.UtcNow;
}
