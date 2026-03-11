import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/story.dart';
import 'local_story_repository.dart';

final localStoryRepositoryProvider = Provider<LocalStoryRepository>((ref) {
  return const LocalStoryRepository();
});

final storyByIdProvider = Provider.family<Story?, String>((ref, id) {
  return ref.watch(localStoryRepositoryProvider).getById(id);
});

