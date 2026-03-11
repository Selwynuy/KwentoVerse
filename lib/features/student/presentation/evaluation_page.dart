import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/quiz_question_providers.dart';
import '../data/quiz_result_providers.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_result.dart';
import 'student_theme.dart';

class EvaluationPage extends ConsumerWidget {
  const EvaluationPage({super.key, required this.storyId, required this.type});

  final String storyId;
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(quizQuestionsProvider(storyId));

    return questionsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 44, color: StudentTheme.secondaryGray),
                const SizedBox(height: 12),
                const Text('Could not load quiz questions.',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(quizQuestionsProvider(storyId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (allQuestions) {
        if (allQuestions.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                onPressed: () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) { router.pop(); }
                  else { router.go('/student/story/$storyId'); }
                },
              ),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No quiz questions available for this story yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: StudentTheme.secondaryGray),
                ),
              ),
            ),
          );
        }

        final isCombined = type.toLowerCase() == 'combined';
        final filteredQuestions = isCombined
            ? allQuestions
            : allQuestions.where((q) => q.stage == type.toLowerCase()).toList();

        return _EvaluationScaffold(
          storyId: storyId,
          type: type,
          questions: filteredQuestions,
          isCombined: isCombined,
        );
      },
    );
  }
}

class _EvaluationScaffold extends ConsumerStatefulWidget {
  const _EvaluationScaffold({
    required this.storyId,
    required this.type,
    required this.questions,
    required this.isCombined,
  });

  final String storyId;
  final String type;
  final List<QuizQuestion> questions;
  final bool isCombined;

  @override
  ConsumerState<_EvaluationScaffold> createState() => _EvaluationScaffoldState();
}

class _EvaluationScaffoldState extends ConsumerState<_EvaluationScaffold> {
  int _currentIndex = 0;
  final Map<String, int> _answers = {};

  QuizQuestion get _current => widget.questions[_currentIndex];

  String _stageTitle(String stage) {
    switch (stage) {
      case 'activity':      return 'Activity';
      case 'abstraction':   return 'Abstraction';
      case 'application':   return 'Application';
      case 'assessment':    return 'Assessment';
      default:              return stage;
    }
  }

  List<StageScore> _computeStageScores() {
    final byStage = <String, List<QuizQuestion>>{};
    for (final q in widget.questions) {
      byStage.putIfAbsent(q.stage, () => []).add(q);
    }
    return byStage.entries.map((e) {
      final correct = e.value.where((q) => _answers[q.id] == q.correctIndex).length;
      return StageScore(
        stageName: _stageTitle(e.key),
        correct: correct,
        total: e.value.length,
      );
    }).toList();
  }

  Future<void> _onNextOrSubmit() async {
    if (!_answers.containsKey(_current.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before continuing.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
      return;
    }

    final correctCount =
        widget.questions.where((q) => _answers[q.id] == q.correctIndex).length;
    final stageScores = _computeStageScores();

    final result = QuizResult(
      storyId: widget.storyId,
      stageScores: stageScores,
      totalCorrect: correctCount,
      totalQuestions: widget.questions.length,
    );

    try {
      await ref.read(quizResultRepositoryProvider).save(result);
      ref.invalidate(myQuizScoresWithStoriesProvider);
    } catch (_) {
      // Still show result even if save fails.
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EvaluationResultPage(
          storyId: widget.storyId,
          type: widget.type,
          correct: correctCount,
          total: widget.questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == widget.questions.length - 1;
    final selectedIndex = _answers[_current.id];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EvaluationHeader(
                  title: widget.isCombined ? 'Story Quiz' : _stageTitle(widget.type),
                  onBack: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.go('/student/story/${widget.storyId}');
                    }
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: StudentTheme.caption.copyWith(
                            fontSize: 12,
                            color: StudentTheme.secondaryGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (widget.isCombined)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              _stageTitle(_current.stage),
                              style: StudentTheme.caption.copyWith(
                                fontSize: 11,
                                color: StudentTheme.secondaryGray,
                              ),
                            ),
                          ),
                        Text(
                          _current.prompt,
                          style: StudentTheme.sectionHeaderSecondary.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(_current.options.length, (i) {
                          final label =
                              String.fromCharCode('a'.codeUnitAt(0) + i);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OptionButton(
                              label: '$label. ${_current.options[i]}',
                              isSelected: selectedIndex == i,
                              onTap: () =>
                                  setState(() => _answers[_current.id] = i),
                            ),
                          );
                        }),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: _currentIndex == 0
                                    ? null
                                    : () => setState(() => _currentIndex--),
                                child: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: StudentTheme.primaryOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _onNextOrSubmit,
                                  child: Text(isLast ? 'Submit' : 'Next'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EvaluationHeader extends StatelessWidget {
  const _EvaluationHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          ),
          Expanded(
            child: Text(
              title,
              style: StudentTheme.sectionHeader.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? StudentTheme.primaryOrange : Colors.white;
    final fg = isSelected ? Colors.white : StudentTheme.primaryOrange;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: StudentTheme.primaryOrange
                  .withValues(alpha: isSelected ? 0.0 : 1.0),
              width: 1.4,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultDonutPainter extends CustomPainter {
  const _ResultDonutPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - (strokeWidth / 2);
    if (radius <= 0) return;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ResultDonutPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}

class EvaluationResultPage extends StatelessWidget {
  const EvaluationResultPage({
    super.key,
    required this.storyId,
    required this.type,
    required this.correct,
    required this.total,
  });

  final String storyId;
  final String type;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : correct / total * 100;
    const circleSize = 360.0;
    const strokeWidth = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Result',
                        style: StudentTheme.sectionHeader.copyWith(fontSize: 18)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: circleSize,
                      width: circleSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(circleSize, circleSize),
                            painter: _ResultDonutPainter(
                              progress: percent / 100.0,
                              strokeWidth: strokeWidth,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${percent.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: StudentTheme.titleDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You got $correct/$total right',
                                style: StudentTheme.caption.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StudentTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => EvaluationPage(
                                storyId: storyId,
                                type: type,
                              ),
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        GoRouter.of(context).go('/student/home');
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
