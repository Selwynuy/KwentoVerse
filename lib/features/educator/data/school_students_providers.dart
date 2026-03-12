import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/data/school_providers.dart';
import 'school_students_repository.dart';

final schoolStudentsRepositoryProvider =
    Provider<SchoolStudentsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SchoolStudentsRepository(client);
});

/// Students enrolled in the same school as the current educator.
final schoolStudentsProvider = FutureProvider<List<SchoolStudent>>((ref) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final repo = ref.watch(schoolStudentsRepositoryProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  return repo.getStudentsForSchool(schoolId);
});

