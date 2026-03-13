import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/auth_state.dart';

class RevokedAccessException implements Exception {
  const RevokedAccessException();
}

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

    // Best-effort profile setup. If RLS blocks this (e.g. missing policy),
    // let the auth account still be created and usable.
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'role': _roleToString(role),
      });
    } on PostgrestException catch (e) {
      // 42501 = insufficient_privilege in Postgres.
      // MapAuthErrorToFriendlyMessage already handles this for callers,
      // but we don't want educator signup to fully fail just because
      // the profile row couldn't be written yet.
      if (e.code != '42501') rethrow;
    }

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
        .select('role, is_revoked')
        .eq('id', userId)
        .maybeSingle();
    if (data == null || data['role'] == null) return null;
    if (data['is_revoked'] == true) {
      throw RevokedAccessException();
    }
    return _roleFromString(data['role'] as String?);
  }

  static String _roleToString(UserRole role) {
    return switch (role) {
      UserRole.student => 'student',
      UserRole.educator => 'educator',
      UserRole.principal => 'principal',
      UserRole.admin => 'admin',
    };
  }

  static UserRole? _roleFromString(String? value) {
    switch (value) {
      case 'student':
        return UserRole.student;
      case 'educator':
        return UserRole.educator;
      case 'principal':
        return UserRole.principal;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }

  // Principal upgrade flow (to be wired up later).
  Future<void> requestPrincipalUpgrade(String educatorId) async {
    await _client.from('principal_requests').insert({
      'educator_id': educatorId,
    });
  }

  Future<void> approvePrincipalUpgrade({
    required String requestId,
    required String adminId,
  }) async {
    await _client.from('principal_requests').update({
      'status': 'approved',
      'reviewer_admin_id': adminId,
    }).eq('id', requestId);
  }
}

