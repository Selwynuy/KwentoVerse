import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  const EvaluationPage({super.key, required this.storyId, required this.type});

  final String storyId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Evaluation: $type')),
      body: Center(child: Text('Evaluation stub for story=$storyId, type=$type')),
    );
  }
}

