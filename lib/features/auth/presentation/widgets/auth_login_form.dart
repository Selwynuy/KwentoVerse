import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_state.dart';

class AuthLoginForm extends ConsumerStatefulWidget {
  const AuthLoginForm({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.buttonText,
    required this.toggleText,
    required this.onToggle,
  });

  final String title;
  final Color primaryColor;
  final String buttonText;
  final String toggleText;
  final VoidCallback onToggle;

  @override
  ConsumerState<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends ConsumerState<AuthLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final color = widget.primaryColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                color: color,
                fontSize: 12,
              ),
              hintStyle: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                color: color,
                fontSize: 12,
              ),
              hintStyle: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: widget.onToggle,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black.withValues(alpha: 0.65),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text(widget.toggleText),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    await ref.read(authControllerProvider.notifier).login(email: email, password: password);

    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
      return;
    }

    if (auth.isAuthenticated && auth.role == UserRole.student) {
      // For now, always send logged-in students to avatar selection.
      // Later this can be gated by a "hasAvatar" flag on the user profile.
      context.go('/student/avatar-select');
    }
  }
}

