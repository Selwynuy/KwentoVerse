import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/auth_state.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<UserRole?> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) return null;
    return _loadRole(user.id);
  }

  Future<UserRole?> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': _roleToString(role),
      },
    );
    final user = response.user;
    if (user == null) return null;

    await _client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'role': _roleToString(role),
    });

    return _loadRole(user.id);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<UserRole?> getCurrentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _loadRole(user.id);
  }

  Future<UserRole?> _loadRole(String userId) async {
    final data = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    if (data == null || data['role'] == null) return null;
    return _roleFromString(data['role'] as String?);
  }

  static String _roleToString(UserRole role) {
    return switch (role) {
      UserRole.student => 'student',
      UserRole.educator => 'educator',
      UserRole.admin => 'admin',
    };
  }

  static UserRole? _roleFromString(String? value) {
    switch (value) {
      case 'student':
        return UserRole.student;
      case 'educator':
        return UserRole.educator;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }
}

