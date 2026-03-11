import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/quiz_question.dart';

class QuizQuestionRepository {
  QuizQuestionRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  /// Fetches all questions for [storyId], ordered by stage + sort_order.
  Future<List<QuizQuestion>> getQuestionsForStory(String storyId) async {
    final rows = await _client
        .from('quiz_questions')
        .select('id, story_id, stage, prompt, options, correct_index, sort_order')
        .eq('story_id', storyId)
        .order('sort_order')
        .timeout(_timeout);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromRow)
        .toList();
  }
}
