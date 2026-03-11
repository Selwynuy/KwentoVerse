import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'school_educators_repository.dart';
import 'school_providers.dart';

final schoolEducatorsRepositoryProvider =
    Provider<SchoolEducatorsRepository>((ref) {
  return SchoolEducatorsRepository(ref.watch(supabaseClientProvider));
});

/// Educators for the current user's school.
final schoolEducatorsProvider =
    FutureProvider<List<SchoolEducator>>((ref) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final educatorsRepo = ref.watch(schoolEducatorsRepositoryProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  return educatorsRepo.getEducatorsForSchool(schoolId);
});
