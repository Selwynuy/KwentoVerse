import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryDetailsPage extends StatelessWidget {
  const StoryDetailsPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Story Details (stub): $storyId',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.go('/student/reader/$storyId'),
          child: const Text('Read'),
        ),
      ],
    );
  }
}

