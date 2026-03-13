import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/data/school_providers.dart';
import '../domain/story.dart';
import 'downloaded_story_cache.dart';
import 'local_story_repository.dart';
import 'supabase_story_repository.dart';

final localStoryRepositoryProvider = Provider<LocalStoryRepository>((ref) {
  return const LocalStoryRepository();
});

final supabaseStoryRepositoryProvider = Provider<SupabaseStoryRepository>((ref) {
  return SupabaseStoryRepository(ref.watch(supabaseClientProvider));
});

final localStoryByIdProvider = Provider.family<Story?, String>((ref, id) {
  return ref.watch(localStoryRepositoryProvider).getById(id);
});

/// Primary story lookup. Uses Supabase when available; falls back to the
/// persistent offline cache. Also saves fetched stories into the cache so
/// they are available offline on next launch.
final storyByIdProvider = FutureProvider.family<Story?, String>((ref, id) async {
  if (id == 'sample-1') {
    return ref.watch(localStoryByIdProvider(id));
  }

  final supabaseRepo = ref.watch(supabaseStoryRepositoryProvider);
  final cache = DownloadedStoryCache.instance;

  try {
    final remote = await supabaseRepo.getStoryById(id);
    if (remote != null) {
      // Persist into cache (preserves existing questions if any).
      final existingQuestions = cache.getQuestions(id);
      await cache.put(remote, questions: existingQuestions);
      return remote;
    }
  } catch (_) {
    // Offline or network error — fall through to cache.
  }

  final cached = cache.get(id);
  if (cached != null) return cached;
  return ref.watch(localStoryByIdProvider(id));
});

/// Stories scoped to a given school id.
final storiesForSchoolProvider =
    FutureProvider.family<List<Story>, String?>((ref, schoolId) async {
  final repo = ref.watch(supabaseStoryRepositoryProvider);
  return repo.listStoriesForSchool(schoolId: schoolId);
});

/// Stories for the current user's school. Used for library and exercises.
/// Student-facing: excludes archived stories.
final currentUserSchoolStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final storyRepo = ref.watch(supabaseStoryRepositoryProvider);
  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  return storyRepo.listStoriesForSchool(schoolId: schoolId);
});

/// Educator-facing: includes archived stories (so educators can still see their uploads).
final educatorSchoolStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final storyRepo = ref.watch(supabaseStoryRepositoryProvider);
  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  return storyRepo.listAllStoriesForSchool(schoolId: schoolId);
});

/// Current user's rating for a story (1–5), or null if not rated.
final storyMyRatingProvider =
    FutureProvider.family<int?, String>((ref, storyId) async {
  final repo = ref.watch(supabaseStoryRepositoryProvider);
  return repo.getMyRating(storyId);
});

/// Search results scoped to the current user's school.
final searchStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, query) async {
  final schoolRepo = ref.watch(schoolRepositoryProvider);
  final storyRepo = ref.watch(supabaseStoryRepositoryProvider);
  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  return storyRepo.listStoriesForSchool(
    schoolId: schoolId,
    query: query.trim().isEmpty ? null : query.trim(),
  );
});
