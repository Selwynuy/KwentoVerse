import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_state.dart';

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Home', '/student/home', Icons.home),
    ('Library', '/student/library', Icons.menu_book),
    ('Progress', '/student/progress', Icons.insights),
    ('Badges', '/student/badges', Icons.emoji_events),
    ('Profile', '/student/profile', Icons.person),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.$2));
    final currentIndex = idx < 0 ? 0 : idx;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KwentoVerse'),
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

