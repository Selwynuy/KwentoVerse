import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryManagementPage extends StatelessWidget {
  const StoryManagementPage({super.key, this.storyId, this.createMode = false});

  final String? storyId;
  final bool createMode;

  @override
  Widget build(BuildContext context) {
    final title = createMode
        ? 'Create Story (stub)'
        : storyId == null
            ? 'Story Management (stub)'
            : 'Edit Story: $storyId (stub)';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (!createMode && storyId == null)
          ListTile(
            title: const Text('Sample Story'),
            subtitle: const Text('Tap to edit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/educator/stories/sample-1'),
          ),
        const SizedBox(height: 12),
        if (!createMode && storyId == null)
          ElevatedButton(
            onPressed: () => context.go('/educator/stories/new'),
            child: const Text('Create new story'),
          ),
      ],
    );
  }
}

