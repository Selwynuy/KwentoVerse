import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'level_config.dart';
import 'student_profile_repository.dart';

final studentProfileRepositoryProvider = Provider<StudentProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StudentProfileRepository(client);
});

final myStudentProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final repo = ref.watch(studentProfileRepositoryProvider);
  return repo.getMyProfile();
});

/// Total points for the current student. Replace with DB-backed provider when
/// profiles.total_points or a progress table exists.
final studentTotalPointsProvider = Provider<int>((ref) => 0);

/// Current level label from points, e.g. "Level: Egg".
final studentLevelLabelProvider = Provider<String>((ref) {
  final points = ref.watch(studentTotalPointsProvider);
  return levelLabelForPoints(points);
});

