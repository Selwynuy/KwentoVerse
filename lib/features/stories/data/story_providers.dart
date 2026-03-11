import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/story.dart';
import 'downloaded_story_cache.dart';
import 'local_story_repository.dart';
import 'supabase_story_repository.dart';

final localStoryRepositoryProvider = Provider<LocalStoryRepository>((ref) {
  return const LocalStoryRepository();
});

final supabaseStoryRepositoryProvider = Provider<SupabaseStoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStoryRepository(client);
});

/// Local-only sample story lookup, kept for design/dev.
final localStoryByIdProvider = Provider.family<Story?, String>((ref, id) {
  return ref.watch(localStoryRepositoryProvider).getById(id);
});

/// Primary story lookup. Uses Supabase when available; when offline or on error
/// uses downloaded cache (stories previously fetched). When back online,
/// invalidate this provider to refetch and update UI from Supabase.
final storyByIdProvider = FutureProvider.family<Story?, String>((ref, id) async {
  final supabaseRepo = ref.watch(supabaseStoryRepositoryProvider);
  final cache = DownloadedStoryCache.instance;

  if (id == 'sample-1') {
    return ref.watch(localStoryByIdProvider(id));
  }

  try {
    final remote = await supabaseRepo.getStoryById(id);
    if (remote != null) {
      cache.put(remote);
      return remote;
    }
  } catch (_) {
    // Offline or error: use cached copy if we have it.
  }
  final cached = cache.get(id);
  if (cached != null) return cached;
  return ref.watch(localStoryByIdProvider(id));
});

/// Stories scoped to a given school id (may be null for \"all\" stories).
final storiesForSchoolProvider = FutureProvider.family<List<Story>, String?>((ref, schoolId) async {
  final repo = ref.watch(supabaseStoryRepositoryProvider);
  return repo.listStoriesForSchool(schoolId: schoolId);
});

/// Current user's rating for a story (1–5), or null if not rated / not authenticated.
/// Invalidate after submitting a rating so the UI updates.
final storyMyRatingProvider = FutureProvider.family<int?, String>((ref, storyId) async {
  final repo = ref.watch(supabaseStoryRepositoryProvider);
  return repo.getMyRating(storyId);
});

