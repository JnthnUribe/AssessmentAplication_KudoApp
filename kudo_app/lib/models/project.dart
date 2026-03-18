/// Modelo de Proyecto para la aplicación Flutter
/// Mapea el JSON retornado por la API .NET (estructura nested)
class Project {
  final String id;
  final String creatorId;
  final String qrToken;
  final String status;
  final bool isDeleted;
  final ProjectIdentity identity;
  final ProjectNarrative narrative;
  final List<String> techStack;
  final ProjectOutcomes outcomes;
  final ProjectMedia media;
  final int totalVotes;
  final double averageRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    this.creatorId = '',
    this.qrToken = '',
    this.status = '',
    this.isDeleted = false,
    required this.identity,
    required this.narrative,
    this.techStack = const [],
    ProjectOutcomes? outcomes,
    ProjectMedia? media,
    this.totalVotes = 0,
    this.averageRating = 0,
    this.createdAt,
    this.updatedAt,
  }) : outcomes = outcomes ?? ProjectOutcomes(),
       media = media ?? ProjectMedia();

  // ── Convenience getters (backward compatible with screens) ──
  String get title => identity.title;
  String get category => identity.category;
  String get platform => identity.platform;
  String get description => narrative.problem;
  String get roleDescription => narrative.roleDescription;

  /// Returns the first image URL, falling back to video thumbnail
  String get imageUrl {
    if (media.images.isNotEmpty) return media.images.first.url;
    if (media.imageUrls.isNotEmpty) return media.imageUrls.first;
    // Fallback: generate thumbnail from Cloudinary video URL
    if (media.videoUrl.isNotEmpty) return videoThumbnailUrl;
    return '';
  }

  /// Generate a thumbnail URL from a Cloudinary video URL
  String get videoThumbnailUrl {
    final url = media.videoUrl;
    if (url.contains('res.cloudinary.com') && url.contains('/video/upload/')) {
      // Insert thumbnail transformation and change extension to .jpg
      final withoutExt = url.substring(0, url.lastIndexOf('.'));
      return withoutExt
              .replaceFirst('/video/upload/', '/video/upload/so_0,w_800,f_jpg/')
          + '.jpg';
    }
    // YouTube thumbnail fallback
    final ytId = extractYoutubeId(url);
    if (ytId != null) return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    return '';
  }

  static String? extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
    return null;
  }

  /// All image URLs for gallery display
  List<String> get allImageUrls {
    if (media.images.isNotEmpty) {
      return media.images.map((img) => img.url).toList();
    }
    return media.imageUrls;
  }

  /// Factory constructor: handles BOTH nested (API) and flat (legacy seed) formats
  factory Project.fromJson(Map<String, dynamic> json) {
    // Determine title/category/description from nested or flat format
    final hasIdentity = json['identity'] != null && json['identity'] is Map;
    final hasNarrative = json['narrative'] != null && json['narrative'] is Map;

    return Project(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      qrToken: json['qrToken'] ?? '',
      status: json['status'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      identity: hasIdentity
          ? ProjectIdentity.fromJson(json['identity'])
          : ProjectIdentity(
              title: json['title'] ?? '',
              category: json['category'] ?? '',
            ),
      narrative: hasNarrative
          ? ProjectNarrative.fromJson(json['narrative'])
          : ProjectNarrative(problem: json['description'] ?? ''),
      techStack: json['techStack'] != null
          ? List<String>.from(json['techStack'])
          : [],
      outcomes: json['outcomes'] != null && json['outcomes'] is Map
          ? ProjectOutcomes.fromJson(json['outcomes'])
          : ProjectOutcomes(),
      media: json['media'] != null && json['media'] is Map
          ? ProjectMedia.fromJson(json['media'])
          : ProjectMedia(
              imageUrls: json['imageUrl'] != null && json['imageUrl'] != ''
                  ? [json['imageUrl']]
                  : [],
            ),
      totalVotes: json['totalVotes'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'qrToken': qrToken,
      'status': status,
      'isDeleted': isDeleted,
      'identity': identity.toJson(),
      'narrative': narrative.toJson(),
      'techStack': techStack,
      'outcomes': outcomes.toJson(),
      'media': media.toJson(),
      'totalVotes': totalVotes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// ── Sub-models ──

class ProjectIdentity {
  final String title;
  final String category;
  final String platform;

  ProjectIdentity({this.title = '', this.category = '', this.platform = ''});

  factory ProjectIdentity.fromJson(Map<String, dynamic> json) {
    return ProjectIdentity(
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      platform: json['platform'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'platform': platform,
  };
}

class ProjectNarrative {
  final String problem;
  final String roleDescription;

  ProjectNarrative({this.problem = '', this.roleDescription = ''});

  factory ProjectNarrative.fromJson(Map<String, dynamic> json) {
    return ProjectNarrative(
      problem: json['problem'] ?? '',
      roleDescription: json['roleDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'problem': problem,
    'roleDescription': roleDescription,
  };
}

class ProjectOutcomes {
  final List<String> results;
  final List<String> learnings;

  ProjectOutcomes({this.results = const [], this.learnings = const []});

  factory ProjectOutcomes.fromJson(Map<String, dynamic> json) {
    return ProjectOutcomes(
      results: json['results'] != null
          ? List<String>.from(json['results'])
          : [],
      learnings: json['learnings'] != null
          ? List<String>.from(json['learnings'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {'results': results, 'learnings': learnings};
}

class ProjectMedia {
  final List<MediaItem> images;
  final String videoUrl;
  final List<ProjectLink> links;
  final List<String> imageUrls; // legacy/deprecated field

  ProjectMedia({
    this.images = const [],
    this.videoUrl = '',
    this.links = const [],
    this.imageUrls = const [],
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      images: json['images'] != null
          ? (json['images'] as List)
                .map((img) => MediaItem.fromJson(img))
                .toList()
          : [],
      videoUrl: json['videoUrl'] ?? '',
      links: json['links'] != null
          ? (json['links'] as List)
                .map((link) => ProjectLink.fromJson(link))
                .toList()
          : [],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'images': images.map((img) => img.toJson()).toList(),
    'videoUrl': videoUrl,
    'links': links.map((link) => link.toJson()).toList(),
  };
}

class MediaItem {
  final String url;
  final String deleteToken;

  MediaItem({this.url = '', this.deleteToken = ''});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      url: json['url'] ?? '',
      deleteToken: json['deleteToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'deleteToken': deleteToken};
}

class ProjectLink {
  final String label;
  final String url;

  ProjectLink({this.label = '', this.url = ''});

  factory ProjectLink.fromJson(Map<String, dynamic> json) {
    return ProjectLink(label: json['label'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
}
