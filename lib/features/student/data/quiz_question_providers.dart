import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../features/stories/data/downloaded_story_cache.dart';
import '../domain/quiz_question.dart';
import 'quiz_question_repository.dart';

final quizQuestionRepositoryProvider = Provider<QuizQuestionRepository>((ref) {
  return QuizQuestionRepository(ref.watch(supabaseClientProvider));
});

/// Questions for a story. Falls back to the offline cache when Supabase is
/// unavailable. Returns empty list when neither source has data.
final quizQuestionsProvider =
    FutureProvider.family<List<QuizQuestion>, String>((ref, storyId) async {
  final repo = ref.watch(quizQuestionRepositoryProvider);
  final cache = DownloadedStoryCache.instance;

  try {
    final questions = await repo.getQuestionsForStory(storyId);
    // Always keep cache up-to-date when online.
    final cached = cache.get(storyId);
    if (cached != null) {
      await cache.put(cached, questions: questions);
    }
    return questions;
  } catch (_) {
    // Offline: serve from cache if available.
    final offline = cache.getQuestions(storyId);
    if (offline != null) return offline;
    return const [];
  }
});
