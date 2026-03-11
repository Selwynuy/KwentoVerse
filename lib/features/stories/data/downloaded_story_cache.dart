import '../domain/story.dart';

/// In-memory cache of stories fetched from Supabase (e.g. when user opens details).
/// When offline, storyByIdProvider uses this so downloaded details are still shown.
/// When back online, refetch invalidates and Supabase data is used again.
class DownloadedStoryCache {
  DownloadedStoryCache._();
  static final DownloadedStoryCache _instance = DownloadedStoryCache._();
  static DownloadedStoryCache get instance => _instance;

  final Map<String, Story> _byId = {};

  Story? get(String id) => _byId[id];

  void put(Story story) {
    _byId[story.id] = story;
  }

  void remove(String id) {
    _byId.remove(id);
  }
}
