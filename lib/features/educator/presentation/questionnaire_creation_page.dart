import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/presentation/student_theme.dart';

// ── Data model used only while building the form ────────────────────────────

class _DraftQuestion {
  _DraftQuestion({required this.stage})
      : prompt = TextEditingController(),
        choices = [TextEditingController()];

  final String stage;
  final TextEditingController prompt;
  final List<TextEditingController> choices;
  int? correctIndex;

  void dispose() {
    prompt.dispose();
    for (final c in choices) {
      c.dispose();
    }
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class QuestionnaireCreationPage extends ConsumerStatefulWidget {
  const QuestionnaireCreationPage({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<QuestionnaireCreationPage> createState() =>
      _QuestionnaireCreationPageState();
}

class _QuestionnaireCreationPageState
    extends ConsumerState<QuestionnaireCreationPage> {
  static const _stages = [
    'Activity',
    'Abstraction',
    'Application',
    'Assessment',
  ];

  // One list of draft questions per stage (ordered).
  late final Map<String, List<_DraftQuestion>> _questions;

  // Which stage tab is currently shown.
  String _activeStage = 'Activity';

  bool _saving = false;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    _questions = {for (final s in _stages) s: []};
  }

  @override
  void dispose() {
    for (final list in _questions.values) {
      for (final q in list) {
        q.dispose();
      }
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _addQuestion() {
    setState(() {
      _questions[_activeStage]!.add(_DraftQuestion(stage: _activeStage));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[_activeStage]!.removeAt(index).dispose();
    });
  }

  void _addChoice(_DraftQuestion q) {
    setState(() => q.choices.add(TextEditingController()));
  }

  void _removeChoice(_DraftQuestion q, int index) {
    setState(() {
      q.choices.removeAt(index).dispose();
      if (q.correctIndex == index) {
        q.correctIndex = null;
      } else if (q.correctIndex != null && q.correctIndex! > index) {
        q.correctIndex = q.correctIndex! - 1;
      }
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final rows = <Map<String, dynamic>>[];
    int sortOrder = 0;

    for (final stage in _stages) {
      for (final q in _questions[stage]!) {
        final prompt = q.prompt.text.trim();
        if (prompt.isEmpty) continue;
        final opts =
            q.choices.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        if (opts.isEmpty) continue;
        rows.add({
          'story_id': widget.storyId,
          'stage': stage.toLowerCase(),
          'prompt': prompt,
          'options': opts,
          'correct_index': q.correctIndex ?? 0,
          'sort_order': sortOrder++,
        });
      }
    }

    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question to save.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('quiz_questions').insert(rows);
      if (mounted) context.go('/educator/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save questions: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stageQuestions = _questions[_activeStage]!;

    return Scaffold(
      backgroundColor: StudentTheme.surfaceCream,
      body: Stack(
        children: [
          Column(
            children: [
              // ── App bar ──────────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: StudentTheme.titleDark,
                        ),
                        onPressed: () => context.go('/educator/home'),
                      ),
                      const Expanded(
                        child: Text(
                          'Create',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: StudentTheme.titleDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              // ── Stage label chip ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StageLabel(stage: _activeStage),
                ),
              ),

              // ── Question list ────────────────────────────────────────
              Expanded(
                child: stageQuestions.isEmpty
                    ? const Center(
                        child: Text(
                          'No questions yet.\nTap "Add Questions" to begin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: StudentTheme.secondaryGray,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: stageQuestions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _QuestionCard(
                          question: stageQuestions[index],
                          index: index,
                          onRemove: () => _removeQuestion(index),
                          onAddChoice: () => _addChoice(stageQuestions[index]),
                          onRemoveChoice: (ci) =>
                              _removeChoice(stageQuestions[index], ci),
                          onCorrectChanged: (ci) => setState(
                              () => stageQuestions[index].correctIndex = ci),
                          onChanged: () => setState(() {}),
                        ),
                      ),
              ),

              // ── Add Questions + Save buttons ─────────────────────────
              SafeArea(
                top: false,
                child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _OutlineActionButton(
                      label: 'Add Questions',
                      onTap: _addQuestion,
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: StudentTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            StudentTheme.primaryOrange.withValues(alpha: 0.5),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),

          // ── FAB speed-dial (stage switcher) ─────────────────────────
          if (_fabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _fabOpen = false),
                child: Container(color: Colors.black38),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 122,
            child: _StageFab(
              stages: _stages,
              activeStage: _activeStage,
              isOpen: _fabOpen,
              onToggle: () => setState(() => _fabOpen = !_fabOpen),
              onSelectStage: (s) => setState(() {
                _activeStage = s;
                _fabOpen = false;
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onRemove,
    required this.onAddChoice,
    required this.onRemoveChoice,
    required this.onCorrectChanged,
    required this.onChanged,
  });

  final _DraftQuestion question;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onAddChoice;
  final ValueChanged<int> onRemoveChoice;
  final ValueChanged<int?> onCorrectChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Prompt header ──────────────────────────────────────────
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 36, 8),
                child: TextField(
                  controller: question.prompt,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    hintText: 'Write questions here...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: StudentTheme.secondaryGray,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: StudentTheme.titleDark,
                  ),
                  maxLines: null,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: StudentTheme.secondaryGray,
                  ),
                ),
              ),
            ],
          ),

          // ── Choices ────────────────────────────────────────────────
          ...List.generate(question.choices.length, (ci) {
            final letter = String.fromCharCode(65 + ci); // A, B, C…
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: _ChoiceRow(
                letter: letter,
                controller: question.choices[ci],
                isCorrect: question.correctIndex == ci,
                onTap: () => onCorrectChanged(ci),
                onRemove: question.choices.length > 1
                    ? () => onRemoveChoice(ci)
                    : null,
                onChanged: onChanged,
              ),
            );
          }),

          // ── Add Choices button ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _OutlineActionButton(
              label: '+ Add Choices',
              onTap: onAddChoice,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice row ────────────────────────────────────────────────────────────────

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.letter,
    required this.controller,
    required this.isCorrect,
    required this.onTap,
    required this.onRemove,
    required this.onChanged,
  });

  final String letter;
  final TextEditingController controller;
  final bool isCorrect;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCorrect
              ? StudentTheme.primaryOrange.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCorrect
                ? StudentTheme.primaryOrange
                : StudentTheme.cardLightOrange,
          ),
        ),
        child: Row(
          children: [
            Text(
              '$letter.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isCorrect
                    ? StudentTheme.primaryOrange
                    : StudentTheme.secondaryGray,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Choice text...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: StudentTheme.secondaryGray,
                  ),
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: isCorrect
                      ? StudentTheme.primaryOrange
                      : StudentTheme.titleDark,
                  fontWeight:
                      isCorrect ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: StudentTheme.primaryOrange,
              ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: StudentTheme.secondaryGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stage label chip ──────────────────────────────────────────────────────────

class _StageLabel extends StatelessWidget {
  const _StageLabel({required this.stage});

  final String stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        stage,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: StudentTheme.primaryOrange,
        ),
      ),
    );
  }
}

// ── Outline action button (Add Choices / Add Questions) ───────────────────────

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: StudentTheme.titleDark,
        side: const BorderSide(color: StudentTheme.primaryOrange),
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: StudentTheme.titleDark,
        ),
      ),
    );
  }
}

// ── Stage FAB speed-dial ──────────────────────────────────────────────────────

class _StageFab extends StatelessWidget {
  const _StageFab({
    required this.stages,
    required this.activeStage,
    required this.isOpen,
    required this.onToggle,
    required this.onSelectStage,
  });

  final List<String> stages;
  final String activeStage;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelectStage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Stage pill buttons shown when open
        if (isOpen) ...[
          ...stages.map((s) {
            final isActive = s == activeStage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onSelectStage(s),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? StudentTheme.primaryOrange
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        offset: Offset(0, 2),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : StudentTheme.titleDark,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
        ],

        // FAB button
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: StudentTheme.primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, 3),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Icon(
              isOpen ? Icons.close_rounded : Icons.menu_book_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
