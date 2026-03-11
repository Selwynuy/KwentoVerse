import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'student_profile_repository.dart';

final studentProfileRepositoryProvider = Provider<StudentProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StudentProfileRepository(client);
});

final myStudentProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final repo = ref.watch(studentProfileRepositoryProvider);
  return repo.getMyProfile();
});

