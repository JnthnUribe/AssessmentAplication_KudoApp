/// Modelo de Proyecto para la aplicación Flutter
/// Mapea el JSON retornado por la API .NET
class Project {
  final String id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final int totalVotes;

  Project({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.totalVotes,
  });

  /// Factory constructor para crear un Project desde JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      totalVotes: json['totalVotes'] ?? 0,
    );
  }

  /// Convierte el Project a Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'totalVotes': totalVotes,
    };
  }
}
