import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reader: $storyId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Reader (stub)'),
          const SizedBox(height: 12),
          const Text(
            'This will render cleaned story text. Next: add TTS + tap-to-dictionary + saved position.',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/student/evaluation/$storyId/activity'),
            child: const Text('Proceed to Evaluation (stub)'),
          ),
        ],
      ),
    );
  }
}

