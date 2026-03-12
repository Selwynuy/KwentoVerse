import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/data/school_educators_providers.dart';
import '../../student/data/school_educators_repository.dart';
import '../../student/data/school_providers.dart';

/// Co-educators in the current user's school, excluding the current user.
final coEducatorsProvider = FutureProvider<List<SchoolEducator>>((ref) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final educatorsRepo = ref.watch(schoolEducatorsRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  final currentUserId = client.auth.currentUser?.id;
  final all = await educatorsRepo.getEducatorsForSchool(schoolId);

  if (currentUserId == null) return all;
  return all.where((e) => e.userId != currentUserId).toList(growable: false);
});

