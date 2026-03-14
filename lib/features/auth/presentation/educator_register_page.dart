import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_state.dart';
import 'widgets/auth_register_form.dart';

class EducatorRegisterPage extends ConsumerWidget {
  const EducatorRegisterPage({super.key});

  static const _primary = Color(0xFF0B3B66);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black87,
                        onPressed: () => context.go('/login-educator'),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Image.asset(
                      'assets/kwentoverse_logo.png',
                      width: 120,
                      height: 120,
                      filterQuality: FilterQuality.none,
                    ),
                    const SizedBox(height: 12),
                    AuthRegisterForm(
                      title: 'REGISTER',
                      primaryColor: _primary,
                      toggleText: 'or login',
                      onToggle: () => context.go('/login-educator'),
                      showRoleSelector: true,
                      onRegister: ({required name, required email, required password, required role}) async {
                        final ok = await ref.read(authControllerProvider.notifier).register(
                          email: email,
                          password: password,
                          fullName: name,
                          role: role,
                        );
                        if (!context.mounted) return;
                        if (ok) {
                          context.go('/login-educator');
                        } else {
                          final msg = ref.read(authControllerProvider).errorMessage;
                          if (msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
