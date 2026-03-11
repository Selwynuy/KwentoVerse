class Story {
  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.difficultyLabel,
    required this.paragraphs,
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

  /// Placeholder asset to use when no network/local cover is available.
  /// Example: `assets/kwentoverse_logo.png`.
  final String? coverAssetPath;

  /// Supabase Storage key/path (canonical source of truth), e.g. `covers/story-123.jpg`.
  /// Convert this to a public/signed URL in your storage layer.
  final String? coverStoragePath;

  /// Local on-device path for downloaded books (preferred when available).
  /// Not available on web builds.
  final String? localCoverPath;
  final int? estimatedMinutes;

  /// Total reads (placeholder until wired to analytics).
  final int? readsCount;

  /// Average rating out of 5 (placeholder until wired to ratings).
  final double? averageRating;
}

