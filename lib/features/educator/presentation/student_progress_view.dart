import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/student_progress_providers.dart';
import '../../student/presentation/progress_page.dart';

class StudentProgressView extends ConsumerWidget {
  const StudentProgressView({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileByIdProvider(studentId));
    final readStoriesAsync =
        ref.watch(studentReadStoriesProvider(studentId));
    final quizScoresAsync =
        ref.watch(studentQuizScoresProvider(studentId));

    return ProgressOverviewPage(
      profileAsync: profileAsync,
      readStoriesAsync: readStoriesAsync,
      quizScoresAsync: quizScoresAsync,
      showShareButton: false,
      overrideBackDestination: () => Navigator.of(context).pop(),
    );
  }
}

