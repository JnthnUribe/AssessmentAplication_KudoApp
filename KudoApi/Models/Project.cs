using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace KudoApi.Models;

/// <summary>
/// Modelo de Proyecto que mapea a la colección "projects" en MongoDB
/// </summary>
public class Project
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = string.Empty;

    [BsonElement("title")]
    public string Title { get; set; } = string.Empty;

    [BsonElement("category")]
    public string Category { get; set; } = string.Empty;

    [BsonElement("description")]
    public string Description { get; set; } = string.Empty;

    [BsonElement("imageUrl")]
    public string ImageUrl { get; set; } = string.Empty;

    [BsonElement("totalVotes")]
    public int TotalVotes { get; set; } = 0;
}
