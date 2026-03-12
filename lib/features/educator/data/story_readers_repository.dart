import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class StoryReaderEntry {
  const StoryReaderEntry({
    required this.studentId,
    required this.fullName,
    required this.avatarIndex,
    required this.hasRead,
  });

  final String studentId;
  final String fullName;
  final int? avatarIndex;
  final bool hasRead;
}

class StoryReadersRepository {
  StoryReadersRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  /// For a given story and school, returns school-scoped readers/non-readers.
  ///
  /// This matches the SQL sketch from the PRD:
  /// - LEFT JOIN story_reads (so non-readers are included)
  /// - JOIN profiles for display name + avatar_index
  Future<List<StoryReaderEntry>> getReadersForStory(
    String storyId,
    String schoolId,
  ) async {
    final rows = await _client
        .from('student_enrollments')
        .select(
          'student_id, profiles(full_name, avatar_index), story_reads(ended_at)',
        )
        .eq('school_id', schoolId)
        .eq('story_reads.story_id', storyId)
        .timeout(_timeout);

    final result = <StoryReaderEntry>[];
    for (final raw in rows as List) {
      final row = raw as Map<String, dynamic>?;
      if (row == null) continue;

      final studentId = row['student_id'] as String?;
      if (studentId == null) continue;

      final profile = row['profiles'] as Map<String, dynamic>?;
      final fullNameRaw = (profile?['full_name'] as String?) ?? '';
      final fullName =
          fullNameRaw.trim().isNotEmpty ? fullNameRaw.trim() : 'Student';

      final avatarRaw = profile?['avatar_index'];
      final avatarIndex = avatarRaw is int
          ? avatarRaw
          : (avatarRaw is num ? avatarRaw.toInt() : null);

      // PostgREST returns embedded resources as a List, even when filtered.
      final storyReadsList = row['story_reads'];
      DateTime? endedAt;
      if (storyReadsList is List && storyReadsList.isNotEmpty) {
        final first = storyReadsList.first as Map<String, dynamic>?;
        final endedRaw = first?['ended_at'];
        if (endedRaw != null) {
          endedAt = DateTime.tryParse(endedRaw.toString());
        }
      }

      result.add(
        StoryReaderEntry(
          studentId: studentId,
          fullName: fullName,
          avatarIndex: avatarIndex,
          hasRead: endedAt != null,
        ),
      );
    }

    return result;
  }
}

