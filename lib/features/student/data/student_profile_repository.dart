import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.schoolName,
    required this.avatarIndex,
  });

  final String id;
  final String fullName;
  final String? schoolName;
  final int? avatarIndex;

  factory StudentProfile.fromRow(Map<String, dynamic> row, {String? schoolName}) {
    final avatarRaw = row['avatar_index'];
    final avatarIndex = avatarRaw is int ? avatarRaw : (avatarRaw is num ? avatarRaw.toInt() : null);

    return StudentProfile(
      id: row['id'] as String,
      fullName: (row['full_name'] as String?)?.trim().isNotEmpty == true
          ? (row['full_name'] as String).trim()
          : 'Student',
      schoolName: schoolName,
      avatarIndex: avatarIndex,
    );
  }
}

class StudentProfileRepository {
  StudentProfileRepository(this._client);

  final SupabaseClient _client;
  static const _timeout = Duration(seconds: 12);

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');
    return userId;
  }

  Future<StudentProfile> getMyProfile() async {
    final userId = _requireUserId();
    final data = await _client
        .from('profiles')
        .select('id, full_name, avatar_index, school_id')
        .eq('id', userId)
        .maybeSingle()
        .timeout(_timeout);

    if (data == null) {
      // Fallback in case a profile row doesn't exist yet.
      return StudentProfile(id: userId, fullName: 'Student', schoolName: null, avatarIndex: null);
    }

    String? schoolName;
    final schoolId = data['school_id'] as String?;
    if (schoolId != null && schoolId.isNotEmpty) {
      final school = await _client
          .from('schools')
          .select('name')
          .eq('id', schoolId)
          .maybeSingle()
          .timeout(_timeout);
      schoolName = school?['name'] as String?;
    }

    return StudentProfile.fromRow(data, schoolName: schoolName);
  }

  Future<void> updateAvatarIndex(int? avatarIndex) async {
    final userId = _requireUserId();
    await _client
        .from('profiles')
        .update({'avatar_index': avatarIndex})
        .eq('id', userId)
        .timeout(_timeout);
  }
}

