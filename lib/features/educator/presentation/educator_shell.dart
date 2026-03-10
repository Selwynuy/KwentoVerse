import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/kwento_bottom_nav_bar.dart';
import '../../auth/application/auth_state.dart';

class EducatorShell extends ConsumerWidget {
  const EducatorShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Library', '/educator/stories', Icons.library_books_rounded),
    ('My School', '/educator/home', Icons.home_rounded),
    ('Search', '/educator/stories', Icons.search_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.$2));
    final currentIndex = idx < 0 ? 0 : idx;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educator'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: KwentoBottomNavBar(
        currentIndex: currentIndex,
        items: [
          for (final t in _tabs)
            KwentoBottomNavBarItem(
              icon: t.$3,
              label: t.$1,
              onTap: () => context.go(t.$2),
            ),
        ],
      ),
    );
  }
}

