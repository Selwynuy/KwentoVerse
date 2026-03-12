import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/data/school_providers.dart';
import 'story_readers_repository.dart';

final storyReadersRepositoryProvider =
    Provider<StoryReadersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StoryReadersRepository(client);
});

/// School-scoped readers/non-readers for a given story.
final storyReadersProvider =
    FutureProvider.family<List<StoryReaderEntry>, String>((ref, storyId) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final repo = ref.watch(storyReadersRepositoryProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  return repo.getReadersForStory(storyId, schoolId);
});

