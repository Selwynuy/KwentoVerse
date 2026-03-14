import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

String mapAuthErrorToFriendlyMessage(
  Object error, {
  bool isUsernameLogin = false,
  bool isUsernameSignup = false,
}) {
  if (error is RevokedAccessException) {
    return 'Your access has been revoked by your principal.';
  }
  if (error is AuthException) {
    final code = (error is AuthApiException) ? error.code : null;

    switch (code) {
      case 'email_not_confirmed':
        return 'Please confirm your email first, then try logging in.';
      case 'invalid_login_credentials':
        return isUsernameLogin
            ? 'Incorrect username or password.'
            : 'Incorrect email or password.';
      case 'user_already_exists':
        return isUsernameSignup
            ? 'This username is already taken.'
            : 'An account with this email already exists. Try logging in instead.';
      case 'signup_disabled':
        return 'Sign up is currently disabled. Please contact your school admin.';
    }

    final msg = error.message.trim();
    if (msg.isNotEmpty) return msg;
    return 'Authentication failed. Please try again.';
  }

  if (error is PostgrestException) {
    if (error.code == '42501') {
      return 'Your account was created, but setup was blocked by permissions. Please contact support.';
    }
    final msg = (error.message).trim();
    if (msg.isNotEmpty) return msg;
    return 'A database error occurred. Please try again.';
  }

  if (error is AuthRetryableFetchException) {
    return 'Network error. Check your connection and try again.';
  }

  return 'Something went wrong. Please try again.';
}

