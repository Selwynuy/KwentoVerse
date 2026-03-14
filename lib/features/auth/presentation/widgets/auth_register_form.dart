import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth_state.dart';

class AuthRegisterForm extends ConsumerStatefulWidget {
  const AuthRegisterForm({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.toggleText,
    required this.onToggle,
    required this.onRegister,
    this.showRoleSelector = false,
  });

  final String title;
  final Color primaryColor;
  final String toggleText;
  final VoidCallback onToggle;
  final Future<void> Function({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) onRegister;
  final bool showRoleSelector;

  @override
  ConsumerState<AuthRegisterForm> createState() => _AuthRegisterFormState();
}

class _AuthRegisterFormState extends ConsumerState<AuthRegisterForm> {
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _field(controller: _nameController, label: 'Full name'),
          const SizedBox(height: 10),
          _field(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          _field(
            controller: _passwordController,
            label: 'Password',
            obscure: true,
          ),
          const SizedBox(height: 10),
          _field(
            controller: _confirmController,
            label: 'Confirm password',
            obscure: true,
          ),
          if (widget.showRoleSelector) ...[
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Register as:',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<UserRole>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Teacher',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    value: UserRole.educator,
                    groupValue: _role,
                    activeColor: Colors.black87,
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
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    value: UserRole.principal,
                    groupValue: _role,
                    activeColor: Colors.black87,
                    onChanged: (v) {
                      if (v != null) setState(() => _role = v);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
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
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
            ),
          ),
          const SizedBox(height: 4),
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
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    await widget.onRegister(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: password,
      role: widget.showRoleSelector ? _role : UserRole.student,
    );
  }
}
