import 'package:flutter/material.dart';

import 'student_theme.dart';

class EvaluationPage extends StatelessWidget {
  const EvaluationPage({super.key, required this.storyId, required this.type});

  final String storyId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return _EvaluationPageScaffold(
      storyId: storyId,
      type: type,
    );
  }
}

/// Supported evaluation types aligned with DepEd's 5A stages.
enum EvaluationStage {
  activity,
  abstraction,
  application,
  assessment,
}

EvaluationStage parseEvaluationStage(String raw) {
  switch (raw.toLowerCase()) {
    case 'activity':
      return EvaluationStage.activity;
    case 'abstraction':
      return EvaluationStage.abstraction;
    case 'application':
      return EvaluationStage.application;
    case 'assessment':
      return EvaluationStage.assessment;
    default:
      return EvaluationStage.activity;
  }
}

String stageTitle(EvaluationStage stage) {
  switch (stage) {
    case EvaluationStage.activity:
      return 'Activity';
    case EvaluationStage.abstraction:
      return 'Abstraction';
    case EvaluationStage.application:
      return 'Application';
    case EvaluationStage.assessment:
      return 'Assessment';
  }
}

/// Simple MCQ model for local/sample questions.
class EvaluationQuestion {
  const EvaluationQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

/// Arguments passed to the result screen.
class EvaluationResultArgs {
  const EvaluationResultArgs({
    required this.type,
    required this.correct,
    required this.total,
  });

  final String type;
  final int correct;
  final int total;
}

/// Hard-coded sample questions while the real evaluation engine is not wired.
///
/// These are scoped to story "sample-1" for now and follow the 5A lesson stages.
List<EvaluationQuestion> _questionsFor(String storyId, EvaluationStage stage) {
  // Later this should query Supabase / a repository for real data.
  if (storyId == 'sample-1') {
    switch (stage) {
      case EvaluationStage.activity:
        return const [
          EvaluationQuestion(
            id: 'act-1',
            prompt: 'What does the word trail most likely mean in general?',
            options: [
              'A path or track made by the passage of people or animals',
              'To leave a trace or mark behind',
              'To follow or lag behind',
              'To move quickly and suddenly',
            ],
            correctIndex: 0,
          ),
          EvaluationQuestion(
            id: 'act-2',
            prompt: 'Why do Hansel and Gretel ignore the narrator\'s instructions?',
            options: [
              'They don\'t trust the narrator to help them',
              'They want to rewrite the story their way',
              'They are afraid of what will and won\'t work',
              'They forgot the instructions given by the narrator',
            ],
            correctIndex: 1,
          ),
          EvaluationQuestion(
            id: 'act-3',
            prompt: 'What is one problem Hansel and Gretel face in the story?',
            options: [
              'They cannot find the witch\'s house',
              'They keep changing the story and getting into trouble',
              'They refuse to go into the forest',
              'They don\'t want to listen to their parents',
            ],
            correctIndex: 1,
          ),
        ];
      case EvaluationStage.abstraction:
        return const [
          EvaluationQuestion(
            id: 'abs-1',
            prompt: 'What is the main idea of the story?',
            options: [
              'Hansel and Gretel decide to follow the narrator and avoid trouble',
              'Hansel and Gretel create their own version of a classic fairy tale',
              'The witch captures Hansel and Gretel and keeps them in a cage',
              'Hansel and Gretel get lost while following the narrator',
            ],
            correctIndex: 1,
          ),
        ];
      case EvaluationStage.application:
        return const [
          EvaluationQuestion(
            id: 'app-1',
            prompt:
                'If you were in Hansel and Gretel\'s place, how would you rewrite a classic fairy tale to make it different?',
            options: [
              'Add more magical creatures to the story',
              'Remove the danger and focus on fun',
              'Change the setting to a modern city',
              'All of the above',
            ],
            correctIndex: 3,
          ),
        ];
      case EvaluationStage.assessment:
        return const [
          EvaluationQuestion(
            id: 'assess-1',
            prompt: 'Why do Hansel and Gretel ignore the narrator\'s instructions?',
            options: [
              'They don\'t trust the narrator to help',
              'They want to rewrite the story their way',
              'They are afraid of what will and won\'t work',
              'They forgot the instructions given by the narrator',
            ],
            correctIndex: 1,
          ),
          EvaluationQuestion(
            id: 'assess-2',
            prompt: 'What lesson can readers learn from Hansel and Gretel\'s behavior?',
            options: [
              'Listening carefully can keep you out of trouble',
              'Stories should never be changed',
              'You should always ignore adults',
              'Magic always solves problems',
            ],
            correctIndex: 0,
          ),
          EvaluationQuestion(
            id: 'assess-3',
            prompt: 'Which best describes the narrator in the story?',
            options: [
              'Bossy and rude',
              'Helpful but often ignored',
              'Afraid and quiet',
              'Always changing the story',
            ],
            correctIndex: 1,
          ),
        ];
    }
  }

  // Fallback: simple one-question assessment if we have no custom set.
  return const [
    EvaluationQuestion(
      id: 'generic-1',
      prompt: 'What is the main message of the story you just read?',
      options: [
        'Be brave and curious when reading',
        'Never try anything new',
        'Stories are only for fun, not learning',
        'You should never change the ending of a story',
      ],
      correctIndex: 0,
    ),
  ];
}

class _EvaluationPageScaffold extends StatefulWidget {
  const _EvaluationPageScaffold({
    required this.storyId,
    required this.type,
  });

  final String storyId;
  final String type;

  @override
  State<_EvaluationPageScaffold> createState() => _EvaluationPageScaffoldState();
}

class _EvaluationPageScaffoldState extends State<_EvaluationPageScaffold> {
  late final EvaluationStage _stage = parseEvaluationStage(widget.type);
  late final List<EvaluationQuestion> _questions = _questionsFor(widget.storyId, _stage);

  int _currentIndex = 0;
  final Map<String, int> _answers = {}; // questionId -> selectedIndex

  EvaluationQuestion get _currentQuestion => _questions[_currentIndex];

  void _onSelectOption(int index) {
    setState(() {
      _answers[_currentQuestion.id] = index;
    });
  }

  void _onNextOrSubmit() {
    final hasAnswer = _answers.containsKey(_currentQuestion.id);
    if (!hasAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before continuing.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final isLast = _currentIndex == _questions.length - 1;
    if (!isLast) {
      setState(() {
        _currentIndex++;
      });
      return;
    }

    // Submit and navigate to result.
    final correctCount = _questions.where((q) {
      final selected = _answers[q.id];
      return selected != null && selected == q.correctIndex;
    }).length;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EvaluationResultPage(
          storyId: widget.storyId,
          type: widget.type,
          correct: correctCount,
          total: _questions.length,
        ),
      ),
    );
  }

  void _onPrevious() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final selectedIndex = _answers[question.id];
    final isLast = _currentIndex == _questions.length - 1;

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
                  title: stageTitle(_stage),
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${_questions.length}',
                          style: StudentTheme.caption.copyWith(
                            fontSize: 12,
                            color: StudentTheme.secondaryGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.prompt,
                          style: StudentTheme.sectionHeaderSecondary.copyWith(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(question.options.length, (i) {
                          final optionLabel = String.fromCharCode('A'.codeUnitAt(0) + i);
                          final isSelected = selectedIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OptionButton(
                              label: '$optionLabel. ${question.options[i]}',
                              isSelected: isSelected,
                              onTap: () => _onSelectOption(i),
                            ),
                          );
                        }),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: _currentIndex == 0 ? null : _onPrevious,
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: StudentTheme.sectionHeader.copyWith(fontSize: 18),
          ),
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
    final bg = isSelected ? StudentTheme.primaryOrange : StudentTheme.primaryOrange;
    const fg = Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
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
    final percent = total == 0 ? 0.0 : (correct / total) * 100;
    final scoreText = '${percent.toStringAsFixed(2)}%';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Result',
                    style: StudentTheme.sectionHeader.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade300,
                          ),
                        ),
                        CircularProgressIndicator(
                          value: percent / 100.0,
                          strokeWidth: 12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          backgroundColor: Colors.transparent,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              scoreText,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: StudentTheme.titleDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You got $correct/$total right',
                              style: StudentTheme.caption.copyWith(fontSize: 12),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


