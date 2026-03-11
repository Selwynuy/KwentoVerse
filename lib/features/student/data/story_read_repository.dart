import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/stories/data/supabase_story_repository.dart';
import '../../../features/stories/domain/story.dart';
import 'offline_sync_queue.dart';

class StoryReadRepository {
  StoryReadRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  String? get _userId => _client.auth.currentUser?.id;

  /// Marks a story as read (upsert — safe to call multiple times).
  /// Sets ended_at to now so it counts as a completed read.
  /// If offline, queues the write for later and returns without throwing.
  Future<void> markRead(String storyId) async {
    final userId = _userId;
    if (userId == null) return;

    final now = DateTime.now().toUtc().toIso8601String();

    try {
      await _client.from('story_reads').upsert(
        {
          'student_id': userId,
          'story_id': storyId,
          'ended_at': now,
        },
        onConflict: 'student_id,story_id',
      ).timeout(_timeout);
    } catch (_) {
      await OfflineSyncQueue.instance.enqueue('story_read', {
        'student_id': userId,
        'story_id': storyId,
        'ended_at': now,
      });
    }
  }

  /// Returns stories the current user has completed (ended_at is set).
  Future<List<Story>> getReadStories() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from('story_reads')
        .select('story_id, stories(*)')
        .eq('student_id', userId)
        .not('ended_at', 'is', null)
        .order('ended_at', ascending: false)
        .timeout(_timeout);

    final storyRepo = SupabaseStoryRepository(_client);
    final list = <Story>[];
    for (final raw in rows as List) {
      final row = raw as Map<String, dynamic>?;
      if (row == null) continue;
      final storyMap = row['stories'] as Map<String, dynamic>?;
      if (storyMap != null) list.add(storyRepo.mapRowToStory(storyMap));
    }
    return list;
  }

  /// Flush any queued story_read writes (call when connectivity returns).
  Future<void> flushQueue() async {
    final queue = OfflineSyncQueue.instance;
    final items = await queue.drain();
    for (final item in items) {
      if (item['type'] == 'story_read') {
        final payload = item['payload'] as Map<String, dynamic>;
        try {
          await _client.from('story_reads').upsert(
            payload,
            onConflict: 'student_id,story_id',
          ).timeout(_timeout);
        } catch (_) {
          await queue.enqueue('story_read', payload);
        }
      }
    }
  }
}
