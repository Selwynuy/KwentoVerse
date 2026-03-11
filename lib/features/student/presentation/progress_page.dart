import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../stories/domain/story.dart';
import '../data/quiz_result_providers.dart';
import '../data/student_profile_providers.dart';
import '../data/student_profile_repository.dart';
import '../data/story_read_providers.dart';
import '../domain/quiz_result.dart';
import 'avatar_icons.dart';
import 'student_theme.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myStudentProfileProvider);
    final readStoriesAsync = ref.watch(myReadStoriesProvider);
    final quizScoresAsync = ref.watch(myQuizScoresWithStoriesProvider);
    return _ProgressOverviewPage(
      profileAsync: profileAsync,
      readStoriesAsync: readStoriesAsync,
      quizScoresAsync: quizScoresAsync,
    );
  }
}

class _ProgressOverviewPage extends StatelessWidget {
  const _ProgressOverviewPage({
    required this.profileAsync,
    required this.readStoriesAsync,
    required this.quizScoresAsync,
  });

  final AsyncValue<StudentProfile> profileAsync;
  final AsyncValue<List<Story>> readStoriesAsync;
  final AsyncValue<List<QuizResultWithStory>> quizScoresAsync;

  @override
  Widget build(BuildContext context) {
    final displayName = profileAsync.maybeWhen(
      data: (p) => p.fullName,
      orElse: () => 'Student',
    );

    final readStories = readStoriesAsync.maybeWhen(
      data: (v) => v,
      orElse: () => const <Story>[],
    );
    final quizScores = quizScoresAsync.maybeWhen(
      data: (v) => v,
      orElse: () => const <QuizResultWithStory>[],
    );
    final student = _deriveStudentProgress(
      displayName: displayName,
      readStories: readStories,
      quizScores: quizScores,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (GoRouter.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go('/student/home');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: StudentTheme.titleDark,
                      splashRadius: 20,
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: _AvatarCircle(
                    radius: 58,
                    color: StudentTheme.cardLightOrange,
                    iconColor: StudentTheme.primaryOrange,
                    avatarIndex: profileAsync.maybeWhen(data: (p) => p.avatarIndex, orElse: () => null),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: StudentTheme.titleDark,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: InkWell(
                    onTap: () => _openLevelsSheet(context, student),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: StudentTheme.primaryOrange,
                              ),
                          children: [
                            const TextSpan(text: 'Level: '),
                            TextSpan(text: student.currentLevelName),
                            const TextSpan(text: '  •  '),
                            TextSpan(text: '${student.totalPoints} pts'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: student.nextLevelProgress,
                        backgroundColor: StudentTheme.primaryOrange.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(StudentTheme.primaryOrange),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ),
                if (student.nextLevelName != null) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Next: ${student.nextLevelName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: StudentTheme.titleDark.withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Badges',
                  child: _BadgeCard(badge: student.latestBadge),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Quiz Scores',
                  child: quizScoresAsync.when(
                    data: (scores) => _QuizScoresContent(scores: scores),
                    loading: () => const _ScoresLoading(),
                    error: (error, stackTrace) => const _ScoresError(),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: "Books I've read so far!",
                  child: readStoriesAsync.when(
                    data: (stories) => _BookRow(stories: stories),
                    loading: () => const _BooksLoading(),
                    error: (error, stackTrace) => const _BooksError(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () => _openShareSheet(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: StudentTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Share Progress',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  Future<void> _openShareSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final media = MediaQuery.of(context);
        final maxHeight = media.size.height * 0.72;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18,
              10,
              18,
              20 + media.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share to External Apps',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: StudentTheme.titleDark,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 18,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: const [
                    _ShareTarget(icon: Icons.facebook_rounded, label: 'Facebook'),
                    _ShareTarget(icon: Icons.message_rounded, label: 'Messenger'),
                    _ShareTarget(icon: Icons.send_rounded, label: 'Telegram'),
                    _ShareTarget(icon: Icons.music_note_rounded, label: 'TikTok'),
                    _ShareTarget(icon: Icons.forum_rounded, label: 'Discord'),
                    _ShareTarget(icon: Icons.more_horiz_rounded, label: 'More Apps'),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: StudentTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLevelsSheet(BuildContext context, _StudentProgress student) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final media = MediaQuery.of(context);
        final maxHeight = media.size.height * 0.78;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 18 + media.viewInsets.bottom),
            children: [
              Center(
                child: Text(
                  'Levels',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: StudentTheme.titleDark,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              ...student.levels.map(
                (lvl) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LevelRow(
                    level: lvl,
                    isCurrent: lvl.name == student.currentLevelName,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: StudentTheme.primaryOrange.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: StudentTheme.primaryOrange, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: StudentTheme.titleDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: StudentTheme.cardCream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StudentTheme.sectionHeader),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final _BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    final inner = const Color(0xFFFFB862);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inner,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, color: StudentTheme.primaryOrange, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: StudentTheme.titleDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.caption,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: StudentTheme.titleDark.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.stories});

  final List<Story> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Finish and rate a story to see it here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: StudentTheme.titleDark.withValues(alpha: 0.7),
              ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final story in stories) ...[
            _BookCard(story: story),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final inner = const Color(0xFFFFB862);
    return InkWell(
      onTap: () => context.push('/student/story/${story.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: inner,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 86, child: BookCoverPlaceholder(useConstraints: true)),
            const SizedBox(height: 8),
            Text(
              story.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
                color: StudentTheme.titleDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizScoresContent extends StatelessWidget {
  const _QuizScoresContent({required this.scores});

  final List<QuizResultWithStory> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Finish a story and complete its quiz to see your scores here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: StudentTheme.titleDark.withValues(alpha: 0.7),
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < scores.length; i++) ...[
          _StoryScoreCard(score: scores[i]),
          if (i < scores.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StoryScoreCard extends StatelessWidget {
  const _StoryScoreCard({required this.score});

  final QuizResultWithStory score;

  @override
  Widget build(BuildContext context) {
    const inner = Color(0xFFFFB862);
    return InkWell(
      onTap: () => context.push('/student/story/${score.storyId}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StudentTheme.cardLightOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56, width: 44, child: BookCoverPlaceholder(useConstraints: true)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.storyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: StudentTheme.titleDark,
                        ),
                      ),
                      if (score.storyAuthor.isNotEmpty)
                        Text(
                          score.storyAuthor,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: StudentTheme.titleDark.withValues(alpha: 0.75),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: 1,
                                backgroundColor: StudentTheme.primaryOrange.withValues(alpha: 0.22),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Scores',
              style: StudentTheme.sectionHeader.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 6),
            ...score.stageScores.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: inner.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        row.stageName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: StudentTheme.titleDark,
                        ),
                      ),
                      Text(
                        '${row.correct}/${row.total}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: StudentTheme.titleDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total score:',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: StudentTheme.titleDark,
                    ),
                  ),
                  Text(
                    '${score.totalCorrect}/${score.totalQuestions}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: StudentTheme.titleDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoresLoading extends StatelessWidget {
  const _ScoresLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}

class _ScoresError extends StatelessWidget {
  const _ScoresError();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Could not load scores.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700,
            ),
      ),
    );
  }
}

class _BooksLoading extends StatelessWidget {
  const _BooksLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}

class _BooksError extends StatelessWidget {
  const _BooksError();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Could not load your reads.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700,
            ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level, required this.isCurrent});

  final _LevelProgress level;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final rowBg = StudentTheme.cardCream;
    final barBg = StudentTheme.primaryOrange.withValues(alpha: 0.22);
    final progressColor = locked ? Colors.grey.shade400 : Colors.green;
    Widget pill({
      required String label,
      required Color fg,
      required Color bg,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: fg,
            height: 1.0,
          ),
        ),
      );
    }

    final statusPills = <Widget>[
      if (isCurrent)
        pill(
          label: 'Current',
          fg: StudentTheme.primaryOrange,
          bg: StudentTheme.primaryOrange.withValues(alpha: 0.12),
        ),
      if (!isCurrent && level.completed)
        pill(
          label: 'Completed',
          fg: Colors.green.shade700,
          bg: Colors.green.withValues(alpha: 0.12),
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: locked
                  ? Colors.grey.shade200
                  : StudentTheme.primaryOrange.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              level.icon,
              color: locked ? Colors.grey.shade600 : StudentTheme.primaryOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        level.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: StudentTheme.titleDark,
                        ),
                      ),
                    ),
                    if (statusPills.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 6,
                            runSpacing: 6,
                            children: statusPills,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: level.progress,
                    backgroundColor: barBg,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level.subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: locked
                        ? Colors.grey.shade700
                        : StudentTheme.titleDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.radius,
    required this.color,
    required this.iconColor,
    this.avatarIndex,
  });

  final double radius;
  final Color color;
  final Color iconColor;
  final int? avatarIndex;

  @override
  Widget build(BuildContext context) {
    final icon = avatarIndex != null
        ? avatarIconFor(avatarIndex!)
        : Icons.person_rounded;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Icon(icon, size: radius * 0.9, color: iconColor),
    );
  }
}

class _StudentProgress {
  const _StudentProgress({
    required this.displayName,
    required this.totalPoints,
    required this.currentLevelName,
    required this.nextLevelName,
    required this.nextLevelProgress,
    required this.latestBadge,
    required this.levels,
  });

  final String displayName;
  final int totalPoints;
  final String currentLevelName;
  final String? nextLevelName;
  final double nextLevelProgress;
  final _BadgeProgress latestBadge;
  final List<_LevelProgress> levels;
}

class _BadgeProgress {
  const _BadgeProgress({required this.name, required this.caption, required this.icon});

  final String name;
  final String caption;
  final IconData icon;
}

class _LevelProgress {
  const _LevelProgress({
    required this.name,
    required this.icon,
    required this.unlocked,
    required this.progress,
    required this.subtitle,
    this.completed = false,
  });

  final String name;
  final IconData icon;
  final bool unlocked;
  final double progress;
  final String subtitle;
  final bool completed;
}

_StudentProgress _deriveStudentProgress({
  required String displayName,
  required List<Story> readStories,
  required List<QuizResultWithStory> quizScores,
}) {
  // PRD H1: points = story completion bonus + correct answers (question points).
  // Numeric constants are still an open decision in the PRD; keep them centralized here.
  const storyCompletionBonusPoints = 20;
  const pointsPerCorrectAnswer = 1;

  final storyPoints = readStories.length * storyCompletionBonusPoints;
  final quizPoints = quizScores.fold<int>(0, (sum, r) => sum + (r.totalCorrect * pointsPerCorrectAnswer));
  final totalPoints = storyPoints + quizPoints;

  final ladder = <({int threshold, String name, IconData icon})>[
    (threshold: 0, name: 'Egg', icon: Icons.egg_alt_rounded),
    (threshold: 20, name: 'Hatchling', icon: Icons.egg_rounded),
    (threshold: 60, name: 'Caterpillar', icon: Icons.bug_report_rounded),
    (threshold: 100, name: 'Explorer', icon: Icons.pets_rounded),
    (threshold: 140, name: 'Kwento Dash', icon: Icons.flutter_dash_rounded),
  ];

  int currentIndex = 0;
  for (var i = 0; i < ladder.length; i++) {
    if (totalPoints >= ladder[i].threshold) currentIndex = i;
  }

  final current = ladder[currentIndex];
  final next = (currentIndex < ladder.length - 1) ? ladder[currentIndex + 1] : null;

  final nextLevelProgress = () {
    if (next == null) return 1.0;
    final span = (next.threshold - current.threshold).clamp(1, 1 << 30);
    final into = (totalPoints - current.threshold).clamp(0, span);
    return into / span;
  }();

  final badge = _BadgeProgress(
    name: current.name,
    caption: 'You reached level ${currentIndex + 1}!',
    icon: current.icon,
  );

  final levels = <_LevelProgress>[];
  for (var i = 0; i < ladder.length; i++) {
    final lvl = ladder[i];
    final unlocked = totalPoints >= lvl.threshold;
    final isCurrent = i == currentIndex;
    final nextThreshold = (i < ladder.length - 1) ? ladder[i + 1].threshold : null;
    final completed = unlocked && !isCurrent;

    final progress = () {
      if (!unlocked) return 0.0;
      if (nextThreshold == null) return 1.0;
      if (!isCurrent) return 1.0;
      final span = (nextThreshold - lvl.threshold).clamp(1, 1 << 30);
      final into = (totalPoints - lvl.threshold).clamp(0, span);
      return into / span;
    }();

    final subtitle = () {
      if (!unlocked) {
        final remaining = (lvl.threshold - totalPoints).clamp(0, 1 << 30);
        return 'Earn $remaining more points to unlock';
      }
      if (nextThreshold == null) return 'Max level reached';
      if (!isCurrent) return 'Completed';
      final remaining = (nextThreshold - totalPoints).clamp(0, 1 << 30);
      return remaining == 0 ? 'Completed' : 'Earn $remaining more points to unlock next';
    }();

    levels.add(
      _LevelProgress(
        name: unlocked ? lvl.name : '???',
        icon: lvl.icon,
        unlocked: unlocked,
        progress: progress,
        subtitle: subtitle,
        completed: completed || (isCurrent && nextThreshold != null && totalPoints >= nextThreshold),
      ),
    );
  }

  return _StudentProgress(
    displayName: displayName,
    totalPoints: totalPoints,
    currentLevelName: current.name,
    nextLevelName: next?.name,
    nextLevelProgress: nextLevelProgress,
    latestBadge: badge,
    levels: levels,
  );
}
