import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../student/data/student_profile_providers.dart';
import '../../student/data/student_profile_repository.dart';

/// Educator profile for the currently authenticated user.
///
/// This intentionally reuses the shared profiles table and
/// [StudentProfileRepository] wiring from the student side.
final myEducatorProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final repo = ref.watch(studentProfileRepositoryProvider);
  return repo.getMyProfile();
});

