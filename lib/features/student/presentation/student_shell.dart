import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentoverse/widgets/hamburger_menu_overlay.dart';
import 'package:kwentoverse/widgets/student_navbar.dart';

import '../../../shared/widgets/kwento_bottom_nav_bar.dart';
import '../../auth/application/auth_state.dart';
import '../data/student_profile_providers.dart';

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
    final profile = ref.watch(myStudentProfileProvider);
    final displayName = profile.maybeWhen(data: (p) => p.fullName, orElse: () => 'Student');
    final levelLabel = ref.watch(studentLevelLabelProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: StudentNavbar(
            displayName: displayName,
            levelLabel: levelLabel,
            avatarUrl: null,
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
          displayName: displayName,
          levelLabel: levelLabel,
          avatarUrl: null,
          onClose: _closeMenu,
          onProfile: () => context.push('/student/profile'),
          onProgress: () => context.push('/student/progress'),
          onLogout: () => _handleLogout(context),
        ),
      ],
    );
  }
}

