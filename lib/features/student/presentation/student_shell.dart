import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentoverse/widgets/hamburger_menu_overlay.dart';
import 'package:kwentoverse/widgets/student_navbar.dart';

import '../../../shared/widgets/kwento_bottom_nav_bar.dart';
import '../../auth/application/auth_state.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Library', '/student/library', Icons.library_books_rounded),
    ('My School', '/student/home', Icons.groups_rounded),
    ('Search', '/student/search', Icons.search_rounded),
  ];

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  bool _isMenuOpen = false;

  // TODO: replace with real student profile data from Supabase.
  final String _studentName = 'Student';
  final String _studentLevel = 'Level: Worm';
  final String? _avatarUrl = null;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = StudentShell._tabs.indexWhere((t) => location.startsWith(t.$2));
    final currentIndex = idx < 0 ? 0 : idx;

    return Stack(
      children: [
        Scaffold(
          appBar: StudentNavbar(
            displayName: _studentName,
            levelLabel: _studentLevel,
            avatarUrl: _avatarUrl,
            onMenuTap: _toggleMenu,
          ),
          body: widget.child,
          bottomNavigationBar: KwentoBottomNavBar(
            currentIndex: currentIndex,
            items: [
              for (final t in StudentShell._tabs)
                KwentoBottomNavBarItem(
                  icon: t.$3,
                  label: t.$1,
                  onTap: () => context.go(t.$2),
                ),
            ],
          ),
        ),
        HamburgerMenuOverlay(
          isOpen: _isMenuOpen,
          onClose: _closeMenu,
          onProfile: () => context.go('/student/profile'),
          onProgress: () => context.go('/student/progress'),
          onNotifications: () => context.go('/student/home'),
          onLogout: () => _handleLogout(context),
        ),
      ],
    );
  }
}

