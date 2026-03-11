import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolEducator {
  const SchoolEducator({required this.userId, required this.fullName});
  final String userId;
  final String fullName;
}

class SchoolEducatorsRepository {
  SchoolEducatorsRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  /// Returns educators for [schoolId] (joined with profiles for display name).
  Future<List<SchoolEducator>> getEducatorsForSchool(String schoolId) async {
    final rows = await _client
        .from('school_educators')
        .select('user_id, profiles(full_name)')
        .eq('school_id', schoolId)
        .timeout(_timeout);

    final list = <SchoolEducator>[];
    for (final raw in rows as List) {
      final row = raw as Map<String, dynamic>?;
      if (row == null) continue;
      final userId = row['user_id'] as String?;
      if (userId == null) continue;
      final profile = row['profiles'] as Map<String, dynamic>?;
      final fullName = (profile?['full_name'] as String?)?.trim();
      list.add(SchoolEducator(
        userId: userId,
        fullName: (fullName != null && fullName.isNotEmpty) ? fullName : 'Educator',
      ));
    }
    return list;
  }
}
