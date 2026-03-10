import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/auth_login_form.dart';

class EducatorLoginPage extends ConsumerWidget {
  const EducatorLoginPage({super.key});

  static const _primary = Color(0xFF0B3B66);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black87,
                    onPressed: () => context.go('/'),
                  ),
                ),
                const SizedBox(height: 12),
                Image.asset(
                  'assets/kwentoverse_logo.png',
                  width: 120,
                  height: 120,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(height: 24),
                const Text(
                  'KwentoVerse',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 24),
                AuthLoginForm(
                  title: 'EDUCATOR LOGIN',
                  primaryColor: _primary,
                  buttonText: 'Login',
                  toggleText: 'or student login',
                  onToggle: () => context.go('/login'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

