import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/student_register_form.dart';

class StudentRegisterPage extends ConsumerWidget {
  const StudentRegisterPage({super.key});

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
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Image.asset(
                    'assets/kwentoverse_logo.png',
                    width: 150,
                    height: 150,
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(height: 12),
                  StudentRegisterForm(
                    title: 'REGISTER',
                    primaryColor: const Color(0xFFF59E0B),
                    toggleText: 'or login',
                    onToggle: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
