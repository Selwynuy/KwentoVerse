import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/quiz_result.dart';

class QuizResultRepository {
  QuizResultRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');
    return userId;
  }

  Future<void> save(QuizResult result) async {
    try {
      final userId = _requireUserId();
      await _client
          .from('quiz_results')
          .insert(result.toInsertRow(userId))
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception('Quiz result save timed out. Please try again.');
    } on PostgrestException catch (e) {
      throw Exception('Failed to save quiz result: ${e.message}');
    }
  }

  Future<List<QuizResultWithStory>> getMyLatestQuizResultsWithStories() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    return getLatestQuizResultsWithStoriesForUser(userId);
  }

  /// Latest quiz result per story for an arbitrary user (educator view).
  Future<List<QuizResultWithStory>> getLatestQuizResultsWithStoriesForUser(
    String userId,
  ) async {
    try {
      final PostgrestList raw = await _client
          .from('quiz_results')
          .select(
            'story_id, total_correct, total_questions, stage_scores, attempted_at',
          )
          .eq('user_id', userId)
          .order('attempted_at', ascending: false)
          .timeout(_timeout);

      if (raw.isEmpty) return const [];

      // First pass: keep latest attempt per story id.
      final latestRows = <Map<String, dynamic>>[];
      final seenStoryIds = <String>{};

      for (final row in raw) {
        final storyId = row['story_id'] as String?;
        if (storyId == null || seenStoryIds.contains(storyId)) continue;
        seenStoryIds.add(storyId);
        latestRows.add(row);
      }

      if (latestRows.isEmpty) return const [];

      // Second pass: fetch story title/author for these ids in one query.
      final storyIds = latestRows.map((r) => r['story_id']).whereType<String>().toList(growable: false);
      if (storyIds.isEmpty) return const [];

      // Use OR-chain instead of `in.(...)` to avoid URL formatting/casting issues with UUIDs.
      final PostgrestList storiesRaw = storyIds.length == 1
          ? await _client
              .from('stories')
              .select('id, title, author')
              .eq('id', storyIds.first)
              .timeout(_timeout)
          : await _client
              .from('stories')
              .select('id, title, author')
              .or(storyIds.map((id) => 'id.eq.$id').join(','))
              .timeout(_timeout);

      final storiesById = <String, Map<String, dynamic>>{};
      for (final s in storiesRaw) {
        final id = s['id'] as String?;
        if (id == null) continue;
        storiesById[id] = s;
      }

      final out = <QuizResultWithStory>[];
      for (final rowMap in latestRows) {
        final storyId = rowMap['story_id'] as String?;
        if (storyId == null) continue;

        final storyRow = storiesById[storyId];
        final title = (storyRow?['title'] as String?)?.trim();
        final author = (storyRow?['author'] as String?)?.trim() ?? '';
        final storyTitle = (title != null && title.isNotEmpty) ? title : 'Untitled';

        out.add(
          QuizResultWithStory(
            storyId: storyId,
            storyTitle: storyTitle,
            storyAuthor: author,
            stageScores: _parseStageScores(rowMap['stage_scores']),
            totalCorrect: _toInt(rowMap['total_correct']),
            totalQuestions: _toInt(rowMap['total_questions']),
            attemptedAt: _parseDateTime(rowMap['attempted_at']),
          ),
        );
      }

      return out;
    } on TimeoutException {
      throw Exception('Failed to load quiz results: Request timed out');
    } on PostgrestException catch (e) {
      throw Exception('Failed to load quiz results: ${e.message}');
    }
  }

  List<StageScore> _parseStageScores(dynamic scores) {
    if (scores is! List) return const [];
    
    return scores
        .whereType<Map<String, dynamic>>()
        .map((e) => StageScore.fromJson(e))
        .toList();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}