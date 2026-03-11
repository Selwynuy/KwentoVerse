import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../features/stories/domain/story.dart';
import 'story_read_repository.dart';

final storyReadRepositoryProvider = Provider<StoryReadRepository>((ref) {
  return StoryReadRepository(ref.watch(supabaseClientProvider));
});

/// Stories the current user has read (completed reader → started quiz).
/// Invalidate after marking a story as read so the progress page updates.
final myReadStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final repo = ref.watch(storyReadRepositoryProvider);
  return repo.getReadStories();
});
