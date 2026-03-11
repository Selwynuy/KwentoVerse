import 'package:supabase_flutter/supabase_flutter.dart';

class School {
  const School({required this.id, required this.name});

  final String id;
  final String name;

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class SchoolRepository {
  SchoolRepository(this._client);

  final SupabaseClient _client;

  Future<List<School>> getSchools() async {
    final data = await _client
        .from('schools')
        .select('id, name')
        .order('name');
    return (data as List).map((e) => School.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Sets the current user's school (enrollment). Requires authenticated user.
  Future<void> enroll(String schoolId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');
    await _client.from('profiles').update({'school_id': schoolId}).eq('id', userId);
  }

  /// Returns the current user's school_id if set.
  Future<String?> getCurrentUserSchoolId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _client
        .from('profiles')
        .select('school_id')
        .eq('id', userId)
        .maybeSingle();
    return data?['school_id'] as String?;
  }
}
