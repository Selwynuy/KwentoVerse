import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryLibraryPage extends StatelessWidget {
  const StoryLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Story Library (stub)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: const Text('Sample Story'),
          subtitle: const Text('Tap to open details'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/student/story/sample-1'),
        ),
      ],
    );
  }
}

