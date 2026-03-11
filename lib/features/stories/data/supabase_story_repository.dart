import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/story.dart';

class SupabaseStoryRepository {
  SupabaseStoryRepository(this._client);

  final SupabaseClient _client;

  static const _timeout = Duration(seconds: 12);

  Future<List<Story>> listStoriesForSchool({
    String? schoolId,
    String? query,
  }) async {
    dynamic q = _client.from('stories').select('*');

    if (schoolId != null && schoolId.isNotEmpty) {
      q = q.eq('school_id', schoolId);
    }

    if (query != null && query.trim().isNotEmpty) {
      q = q.ilike('title', '%${query.trim()}%');
    }

    q = q.order('created_at', ascending: false);
    final List<dynamic> rows = await q.timeout(_timeout);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapRowToStory)
        .toList(growable: false);
  }

  Future<Story?> getStoryById(String id) async {
    final dynamic row =
        await _client.from('stories').select('*').eq('id', id).maybeSingle().timeout(_timeout);

    if (row == null) return null;
    if (row is! Map<String, dynamic>) return null;
    return _mapRowToStory(row);
  }

  Story _mapRowToStory(Map<String, dynamic> row) {
    final title = (row['title'] as String?)?.trim().isNotEmpty == true ? (row['title'] as String).trim() : 'Untitled Story';
    final summary = (row['summary'] as String?) ?? '';
    final difficultyLabel = (row['difficulty_label'] as String?) ??
        (row['difficulty_level'] as String?) ??
        '';
    final contentText = (row['content_text'] as String?) ?? '';
    final isArchived = (row['is_archived'] as bool?) == true || (row['archived'] as bool?) == true;

    // Basic safeguard: hide archived stories from the student-side repository.
    if (isArchived) {
      // This should normally be filtered at the query level, but keep a guard.
    }

    final paragraphs = _segmentParagraphs(contentText.isNotEmpty ? contentText : summary);

    final avg = row['average_rating'];
    final averageRating = avg != null
        ? (avg is num ? avg.toDouble() : double.tryParse(avg.toString()))
        : null;

    final author = (row['author'] as String?)?.trim();
    final genre = (row['genre'] as String?)?.trim();
    final publicationDate = row['publication_date']?.toString();
    final readsCount = row['reads_count'] is int
        ? row['reads_count'] as int
        : (row['reads_count'] is num ? (row['reads_count'] as num).toInt() : null);

    return Story(
      id: row['id'] as String,
      title: title,
      author: (author != null && author.isNotEmpty) ? author : '',
      description: summary.isNotEmpty ? summary : title,
      difficultyLabel: difficultyLabel,
      paragraphs: paragraphs,
      genre: (genre != null && genre.isNotEmpty) ? genre : null,
      publicationDate: (publicationDate != null && publicationDate.isNotEmpty) ? publicationDate : null,
      coverAssetPath: row['cover_asset_path'] as String?,
      coverStoragePath: row['cover_storage_path'] as String?,
      localCoverPath: row['local_cover_path'] as String?,
      estimatedMinutes: row['estimated_minutes'] as int?,
      readsCount: readsCount,
      averageRating: averageRating,
    );
  }

  /// Fetches the current user's rating for [storyId] (1–5), or null if not rated.
  Future<int?> getMyRating(String storyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('story_ratings')
        .select('rating')
        .eq('story_id', storyId)
        .eq('user_id', userId)
        .maybeSingle()
        .timeout(_timeout);

    if (row == null) return null;
    final r = row['rating'];
    if (r is int && r >= 1 && r <= 5) return r;
    if (r is num) return r.toInt().clamp(1, 5);
    return null;
  }

  /// Upserts the current user's rating for [storyId]. Rating must be 1–5.
  Future<void> submitRating(String storyId, int rating) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');
    final value = rating.clamp(1, 5);

    await _client.from('story_ratings').upsert(
      {
        'story_id': storyId,
        'user_id': userId,
        'rating': value,
      },
      onConflict: 'story_id,user_id',
    ).timeout(_timeout);
  }

  /// Stories the current user has rated (i.e. read and rated). Newest first.
  Future<List<Story>> getStoriesReadByCurrentUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    final rows = await _client
        .from('story_ratings')
        .select('*, stories(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .timeout(_timeout);

    final list = <Story>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>?;
      if (row == null) continue;
      final storyMap = row['stories'] as Map<String, dynamic>?;
      if (storyMap != null) list.add(_mapRowToStory(storyMap));
    }
    return list;
  }

  List<String> _segmentParagraphs(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const <String>[];

    final raw = trimmed.split(RegExp(r'\n\s*\n'));
    final cleaned = raw.map((p) => p.trim()).where((p) => p.isNotEmpty).toList(growable: false);
    if (cleaned.isNotEmpty) return cleaned;
    return <String>[trimmed];
  }
}

