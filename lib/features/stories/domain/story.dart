class Story {
  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.difficultyLabel,
    required this.paragraphs,
    this.genre,
    this.publicationDate,
    this.coverAssetPath,
    this.coverStoragePath,
    this.localCoverPath,
    this.estimatedMinutes,
    this.readsCount,
    this.averageRating,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final String difficultyLabel;
  final List<String> paragraphs;
  final String? genre;
  final String? publicationDate;
  final String? coverAssetPath;

  /// Supabase Storage key/path (canonical source of truth), e.g. `covers/story-123.jpg`.
  /// Convert this to a public/signed URL in your storage layer.
  final String? coverStoragePath;

  /// Local on-device path for downloaded books (preferred when available).
  final String? localCoverPath;
  final int? estimatedMinutes;
  final int? readsCount;
  final double? averageRating;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'difficulty_label': difficultyLabel,
        'paragraphs': paragraphs,
        'genre': genre,
        'publication_date': publicationDate,
        'cover_asset_path': coverAssetPath,
        'cover_storage_path': coverStoragePath,
        'local_cover_path': localCoverPath,
        'estimated_minutes': estimatedMinutes,
        'reads_count': readsCount,
        'average_rating': averageRating,
      };

  factory Story.fromJson(Map<String, dynamic> json) {
    final rawParagraphs = json['paragraphs'];
    List<String> paragraphs = [];
    if (rawParagraphs is List) {
      paragraphs = rawParagraphs.map((e) => e.toString()).toList();
    }
    final avg = json['average_rating'];
    return Story(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Untitled',
      author: (json['author'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      difficultyLabel: (json['difficulty_label'] as String?) ?? '',
      paragraphs: paragraphs,
      genre: json['genre'] as String?,
      publicationDate: json['publication_date'] as String?,
      coverAssetPath: json['cover_asset_path'] as String?,
      coverStoragePath: json['cover_storage_path'] as String?,
      localCoverPath: json['local_cover_path'] as String?,
      estimatedMinutes: json['estimated_minutes'] as int?,
      readsCount: json['reads_count'] as int?,
      averageRating: avg is num ? avg.toDouble() : null,
    );
  }
}

