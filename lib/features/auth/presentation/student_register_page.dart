import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_state.dart';

class StudentRegisterPage extends ConsumerStatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  ConsumerState<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends ConsumerState<StudentRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 20),
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
                const SizedBox(height: 4),
                Image.asset(
                  'assets/kwentoverse_logo.png',
                  width: 80,
                  height: 80,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          labelStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          labelStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
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
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black.withValues(alpha: 0.65),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('or login'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final ok = await ref.read(authControllerProvider.notifier).register(
          email: email,
          password: password,
          fullName: name,
          role: UserRole.student,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/login');
    } else {
      final msg = ref.read(authControllerProvider).errorMessage;
      if (msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }
}

