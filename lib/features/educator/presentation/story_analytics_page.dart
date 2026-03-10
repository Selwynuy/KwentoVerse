import 'package:flutter/material.dart';

class StoryAnalyticsPage extends StatelessWidget {
  const StoryAnalyticsPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics: $storyId')),
      body: const Center(child: Text('Story Analytics (stub)')),
    );
  }
}

