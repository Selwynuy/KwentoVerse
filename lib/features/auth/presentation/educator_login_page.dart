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
          child: Padding(
            padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.max,
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
                const SizedBox(height: 8),
                Image.asset(
                  'assets/kwentoverse_logo.png',
                  width: 96,
                  height: 96,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(height: 16),
                AuthLoginForm(
                  title: 'EDUCATOR LOGIN',
                  primaryColor: _primary,
                  buttonText: 'Login',
                  toggleText: 'or register as teacher',
                  onToggle: () => context.go('/register-educator'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

