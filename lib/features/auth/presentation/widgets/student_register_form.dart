import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_state.dart';

class StudentRegisterForm extends ConsumerStatefulWidget {
  const StudentRegisterForm({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.toggleText,
    required this.onToggle,
  });

  final String title;
  final Color primaryColor;
  final String toggleText;
  final VoidCallback onToggle;

  @override
  ConsumerState<StudentRegisterForm> createState() => _StudentRegisterFormState();
}

class _StudentRegisterFormState extends ConsumerState<StudentRegisterForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _birthdayController = TextEditingController();
  DateTime? _birthday;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _birthdayController.dispose();
    super.dispose();
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

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _birthday = picked;
        _birthdayController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _onSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final ok = await ref.read(authControllerProvider.notifier).registerStudent(
          username: username,
          password: password,
          birthday: _birthday,
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
          _field(controller: _usernameController, label: 'Username'),
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
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickBirthday,
            child: AbsorbPointer(
              child: TextField(
                controller: _birthdayController,
                readOnly: true,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  labelStyle: TextStyle(color: Colors.black87, fontSize: 12),
                  suffixIcon: Icon(Icons.calendar_month_outlined, color: Colors.black87),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
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
}
