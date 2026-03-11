import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/quiz_result.dart';
import 'quiz_result_repository.dart';

final quizResultRepositoryProvider = Provider<QuizResultRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return QuizResultRepository(client);
});

/// Latest quiz result per story for the current user (for progress page).
/// Invalidate after submitting a quiz so the progress page updates.
final myQuizScoresWithStoriesProvider = FutureProvider<List<QuizResultWithStory>>((ref) async {
  final repo = ref.watch(quizResultRepositoryProvider);
  return repo.getMyLatestQuizResultsWithStories();
});
