import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/kwento_bottom_nav_bar.dart';
import '../../auth/application/auth_state.dart';
import '../data/educator_profile_providers.dart';
import '../../../widgets/educator_navbar.dart';
import '../../../widgets/hamburger_menu_overlay.dart';

class EducatorShell extends ConsumerStatefulWidget {
  const EducatorShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Library', '/educator/library', Icons.library_books_rounded),
    ('My School', '/educator/home', Icons.groups_rounded),
    ('Search', '/educator/search', Icons.search_rounded),
  ];

  @override
  ConsumerState<EducatorShell> createState() => _EducatorShellState();
}

class _EducatorShellState extends ConsumerState<EducatorShell> {
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

  Future<void> _handleLogout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx =
        EducatorShell._tabs.indexWhere((t) => location.startsWith(t.$2));
    final currentIndex = idx < 0 ? 0 : idx;

    final profile = ref.watch(myEducatorProfileProvider);
    final displayName = profile.maybeWhen(
      data: (p) => p.fullName,
      orElse: () => 'Educator',
    );
    final avatarIndex = profile.maybeWhen(
      data: (p) => p.avatarIndex,
      orElse: () => null,
    );

    final role = ref.watch(authControllerProvider).role;
    final isPrincipal = role == UserRole.principal;
    final levelLabel = isPrincipal ? 'Principal' : 'Educator';

    // Principal gets three dedicated sub-items; educators get the single
    // School Settings shortcut.
    final principalExtras = isPrincipal
        ? [
            HamburgerMenuExtra(
              icon: Icons.people_alt_rounded,
              label: 'Enrolled Students',
              onTap: () => context.push('/principal/students'),
            ),
            HamburgerMenuExtra(
              icon: Icons.badge_rounded,
              label: 'Educators',
              onTap: () => context.push('/principal/educators'),
            ),
            HamburgerMenuExtra(
              icon: Icons.menu_book_rounded,
              label: 'Story books',
              onTap: () => context.push('/principal/stories'),
            ),
          ]
        : <HamburgerMenuExtra>[];

    return Stack(
      children: [
        Scaffold(
          appBar: EducatorNavbar(
            displayName: displayName,
            levelLabel: levelLabel,
            avatarUrl: null,
            avatarIndex: avatarIndex,
            onMenuTap: _toggleMenu,
          ),
          body: widget.child,
          bottomNavigationBar: KwentoBottomNavBar(
            currentIndex: currentIndex,
            items: [
              for (final t in EducatorShell._tabs)
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
          avatarIndex: avatarIndex,
          onClose: _closeMenu,
          onProfile: () => context.push('/educator/profile'),
          // Educators keep the School Settings item; principals use extraItems.
          onProgress: isPrincipal ? null : () => context.push('/educator/school'),
          progressLabel: 'School Settings',
          progressIcon: Icons.settings_rounded,
          extraItems: principalExtras,
          onLogout: _handleLogout,
        ),
      ],
    );
  }
}

