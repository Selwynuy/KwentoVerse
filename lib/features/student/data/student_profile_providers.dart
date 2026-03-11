import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../stories/domain/story.dart';
import '../domain/quiz_result.dart';
import 'level_config.dart';
import 'quiz_result_providers.dart';
import 'story_read_providers.dart';
import 'student_profile_repository.dart';

final studentProfileRepositoryProvider = Provider<StudentProfileRepository>((ref) {
  return StudentProfileRepository(ref.watch(supabaseClientProvider));
});

final myStudentProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final repo = ref.watch(studentProfileRepositoryProvider);
  return repo.getMyProfile();
});

/// Total points derived from read stories and quiz results.
/// 20 pts per completed story + 1 pt per correct quiz answer.
final studentTotalPointsProvider = Provider<int>((ref) {
  const storyBonus = 20;
  const pointsPerCorrect = 1;

  final readStories = ref.watch(myReadStoriesProvider).maybeWhen(
    data: (v) => v,
    orElse: () => const <Story>[],
  );
  final quizScores = ref.watch(myQuizScoresWithStoriesProvider).maybeWhen(
    data: (v) => v,
    orElse: () => const <QuizResultWithStory>[],
  );

  return readStories.length * storyBonus +
      quizScores.fold(0, (sum, r) => sum + r.totalCorrect * pointsPerCorrect);
});

/// Current level label from points, e.g. "Level: Hatchling".
final studentLevelLabelProvider = Provider<String>((ref) {
  return levelLabelForPoints(ref.watch(studentTotalPointsProvider));
});
