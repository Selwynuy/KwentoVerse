import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';
import 'auth_error_mapper.dart';

enum UserRole { student, educator, admin }

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    required this.role,
    this.isLoading = false,
    this.errorMessage,
  });

  const AuthState.unauthenticated()
      : isAuthenticated = false,
        role = null,
        isLoading = false,
        errorMessage = null;

  const AuthState.authenticated(this.role)
      : isAuthenticated = true,
        isLoading = false,
        errorMessage = null;

  final bool isAuthenticated;
  final UserRole? role;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    bool? isAuthenticated,
    UserRole? role,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthState.unauthenticated();
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      final role = await repo.getCurrentRole();
      if (role == null) return;
      state = AuthState.authenticated(role);
    } catch (_) {}
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(authRepositoryProvider);
    try {
      final role = await repo.login(email: email, password: password);
      if (role == null) {
        state =
            const AuthState.unauthenticated().copyWith(errorMessage: 'Unable to determine user role.');
        return;
      }
      state = AuthState.authenticated(role);
    } catch (e) {
      state = const AuthState.unauthenticated().copyWith(
        errorMessage: mapAuthErrorToFriendlyMessage(e),
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      await repo.logout();
      state = const AuthState.unauthenticated();
      return true;
    } catch (e) {
      state = const AuthState.unauthenticated().copyWith(
        errorMessage: mapAuthErrorToFriendlyMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

