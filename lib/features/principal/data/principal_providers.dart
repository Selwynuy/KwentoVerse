import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/data/school_providers.dart';

// ── Domain models ─────────────────────────────────────────────────────────────

class SchoolEducatorDetail {
  const SchoolEducatorDetail({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.isRevoked,
    this.avatarIndex,
  });

  final String userId;
  final String fullName;
  final String role; // 'principal' | 'educator'
  final bool isRevoked;
  final int? avatarIndex;
}

class SchoolStoryDetail {
  const SchoolStoryDetail({
    required this.id,
    required this.title,
    required this.author,
    required this.isArchived,
    this.coverStoragePath,
    this.uploaderName,
  });

  final String id;
  final String title;
  final String author;
  final bool isArchived;
  final String? coverStoragePath;
  final String? uploaderName;
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// All educators (including the principal) in the principal's school,
/// sourced from the school_educators join table.
final principalSchoolEducatorsProvider =
    FutureProvider<List<SchoolEducatorDetail>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final schoolRepo = ref.watch(schoolRepositoryProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  final rows = await client
      .from('school_educators')
      .select('user_id, profiles(full_name, role, is_revoked, avatar_index)')
      .eq('school_id', schoolId)
      .timeout(const Duration(seconds: 12));

  final list = <SchoolEducatorDetail>[];
  for (final raw in rows as List) {
    final row = raw as Map<String, dynamic>;
    final userId = row['user_id'] as String?;
    if (userId == null) continue;
    final profile = row['profiles'] as Map<String, dynamic>?;
    if (profile == null) continue;
    final role = (profile['role'] as String?) ?? 'educator';
    if (role != 'educator' && role != 'principal') continue;
    final avatarRaw = profile['avatar_index'];
    list.add(SchoolEducatorDetail(
      userId: userId,
      fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profile['full_name'] as String).trim()
          : 'Educator',
      role: role,
      isRevoked: (profile['is_revoked'] as bool?) ?? false,
      avatarIndex: avatarRaw is int
          ? avatarRaw
          : (avatarRaw is num ? avatarRaw.toInt() : null),
    ));
  }
  return list;
});

/// All stories (active + archived) in the principal's school.
final principalSchoolStoriesProvider =
    FutureProvider<List<SchoolStoryDetail>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final schoolRepo = ref.watch(schoolRepositoryProvider);

  final schoolId = await schoolRepo.getCurrentUserSchoolId();
  if (schoolId == null || schoolId.isEmpty) return const [];

  final rows = await client
      .from('stories')
      .select('id, title, author, is_archived, cover_storage_path, uploader_id')
      .eq('school_id', schoolId)
      .order('created_at', ascending: false)
      .timeout(const Duration(seconds: 12));

  final list = <SchoolStoryDetail>[];
  for (final raw in rows as List) {
    final row = raw as Map<String, dynamic>;
    final id = row['id'] as String?;
    if (id == null) continue;
    list.add(SchoolStoryDetail(
      id: id,
      title: (row['title'] as String?)?.trim().isNotEmpty == true
          ? (row['title'] as String).trim()
          : 'Untitled',
      author: (row['author'] as String?)?.trim() ?? '',
      isArchived: (row['is_archived'] as bool?) ?? false,
      coverStoragePath: row['cover_storage_path'] as String?,
    ));
  }
  return list;
});

// ── Mutations ─────────────────────────────────────────────────────────────────

Future<void> revokeEducator(SupabaseClient client, String userId) async {
  await client
      .from('profiles')
      .update({'is_revoked': true})
      .eq('id', userId)
      .timeout(const Duration(seconds: 12));
}

Future<void> restoreEducator(SupabaseClient client, String userId) async {
  await client
      .from('profiles')
      .update({'is_revoked': false})
      .eq('id', userId)
      .timeout(const Duration(seconds: 12));
}

Future<void> archiveStory(SupabaseClient client, String storyId) async {
  final rows = await client
      .from('stories')
      .update({'is_archived': true})
      .eq('id', storyId)
      .select('id')
      .timeout(const Duration(seconds: 12));
  if ((rows as List).isEmpty) {
    throw Exception('Archive was blocked — check your permissions.');
  }
}

Future<void> unarchiveStory(SupabaseClient client, String storyId) async {
  final rows = await client
      .from('stories')
      .update({'is_archived': false})
      .eq('id', storyId)
      .select('id')
      .timeout(const Duration(seconds: 12));
  if ((rows as List).isEmpty) {
    throw Exception('Unarchive was blocked — check your permissions.');
  }
}

Future<void> deleteStory(SupabaseClient client, String storyId) async {
  final rows = await client
      .from('stories')
      .delete()
      .eq('id', storyId)
      .select('id')
      .timeout(const Duration(seconds: 12));

  if ((rows as List).isEmpty) {
    throw Exception('Delete was blocked — check your permissions.');
  }
}
