import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_state.dart';

class EducatorShell extends ConsumerWidget {
  const EducatorShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Dashboard', '/educator/home', Icons.dashboard),
    ('Stories', '/educator/stories', Icons.library_books),
    ('Profile', '/educator/profile', Icons.person),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].$2),
        destinations: [
          for (final t in _tabs) NavigationDestination(icon: Icon(t.$3), label: t.$1),
        ],
      ),
    );
  }
}

