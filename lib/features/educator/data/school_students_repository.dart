import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolStudent {
  const SchoolStudent({
    required this.userId,
    required this.fullName,
    required this.avatarIndex,
  });

  final String userId;
  final String fullName;
  final int? avatarIndex;
}

class SchoolStudentsRepository {
  SchoolStudentsRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  /// Students enrolled in the given school, joined with profiles for display.
  Future<List<SchoolStudent>> getStudentsForSchool(String schoolId) async {
    final rows = await _client
        .from('student_enrollments')
        .select('student_id, profiles(full_name, avatar_index)')
        .eq('school_id', schoolId)
        .timeout(_timeout);

    final result = <SchoolStudent>[];
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

      result.add(
        SchoolStudent(
          userId: studentId,
          fullName: fullName,
          avatarIndex: avatarIndex,
        ),
      );
    }

    return result;
  }
}

