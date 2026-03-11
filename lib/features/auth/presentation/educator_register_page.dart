import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_state.dart';

class EducatorRegisterPage extends ConsumerStatefulWidget {
  const EducatorRegisterPage({super.key});

  static const _primary = Color(0xFF0B3B66);

  @override
  ConsumerState<EducatorRegisterPage> createState() =>
      _EducatorRegisterPageState();
}

class _EducatorRegisterPageState
    extends ConsumerState<EducatorRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  UserRole _role = UserRole.educator;

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
      body: SafeArea(
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
                      border: Border.all(
                          color: EducatorRegisterPage._primary),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: EducatorRegisterPage._primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _field(
                          controller: _nameController,
                          label: 'Full name',
                        ),
                        const SizedBox(height: 10),
                        _field(
                          controller: _emailController,
                          label: 'Institutional email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          controller: _passwordController,
                          label: 'Create password',
                          obscure: true,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          controller: _confirmController,
                          label: 'Confirm password',
                          obscure: true,
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Register as:',
                            style: TextStyle(
                              color: EducatorRegisterPage._primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserRole>(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: const Text(
                                  'Teacher',
                                  style: TextStyle(
                                    color: EducatorRegisterPage._primary,
                                    fontSize: 12,
                                  ),
                                ),
                                value: UserRole.educator,
                                groupValue: _role,
                                activeColor: EducatorRegisterPage._primary,
                                onChanged: (v) {
                                  if (v != null) setState(() => _role = v);
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserRole>(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: const Text(
                                  'Principal',
                                  style: TextStyle(
                                    color: EducatorRegisterPage._primary,
                                    fontSize: 12,
                                  ),
                                ),
                                value: UserRole.principal,
                                groupValue: _role,
                                activeColor: EducatorRegisterPage._primary,
                                onChanged: (v) {
                                  if (v != null) setState(() => _role = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  EducatorRegisterPage._primary,
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
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
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
                          onPressed: () => context.go('/login-educator'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.black.withValues(alpha: 0.65),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('or login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: EducatorRegisterPage._primary,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          color: EducatorRegisterPage._primary,
          fontSize: 12,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: EducatorRegisterPage._primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: EducatorRegisterPage._primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: EducatorRegisterPage._primary),
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
          role: _role,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/login-educator');
    } else {
      final msg = ref.read(authControllerProvider).errorMessage;
      if (msg != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }
}
