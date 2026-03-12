import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../features/stories/data/supabase_story_repository.dart';
import '../../../features/stories/domain/story.dart';
import '../../student/data/student_profile_repository.dart';
import '../../student/domain/quiz_result.dart';
import '../../student/data/quiz_result_providers.dart';

/// Profile for an arbitrary student id (educator read-only view).
final studentProfileByIdProvider =
    FutureProvider.family<StudentProfile, String>((ref, studentId) async {
  final client = ref.watch(supabaseClientProvider);

  // Single join query: profiles → schools to avoid a second round trip.
  final data = await client
      .from('profiles')
      .select('id, full_name, avatar_index, schools(name)')
      .eq('id', studentId)
      .maybeSingle()
      .timeout(const Duration(seconds: 12));

  if (data == null) {
    return StudentProfile(
      id: studentId,
      fullName: 'Student',
      schoolName: null,
      avatarIndex: null,
    );
  }

  final schoolRow = data['schools'] as Map<String, dynamic>?;
  final schoolName = schoolRow?['name'] as String?;

  return StudentProfile.fromRow(data, schoolName: schoolName);
});

/// Stories a specific student has completed (ended_at set).
final studentReadStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, studentId) async {
  final client = ref.watch(supabaseClientProvider);
  final storyRepo = SupabaseStoryRepository(client);

  final rows = await client
      .from('story_reads')
      .select('story_id, stories(*)')
      .eq('student_id', studentId)
      .not('ended_at', 'is', null)
      .order('ended_at', ascending: false)
      .timeout(const Duration(seconds: 12));

  final list = <Story>[];
  for (final raw in rows as List) {
    final row = raw as Map<String, dynamic>?;
    if (row == null) continue;
    final storyMap = row['stories'] as Map<String, dynamic>?;
    if (storyMap != null) list.add(storyRepo.mapRowToStory(storyMap));
  }
  return list;
});

/// Latest quiz result per story for a specific student.
final studentQuizScoresProvider =
    FutureProvider.family<List<QuizResultWithStory>, String>(
        (ref, studentId) async {
  final repo = ref.watch(quizResultRepositoryProvider);
  return repo.getLatestQuizResultsWithStoriesForUser(studentId);
});

