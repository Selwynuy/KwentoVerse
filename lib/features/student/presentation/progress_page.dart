import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import '../data/student_profile_providers.dart';
import '../data/student_profile_repository.dart';
import 'avatar_icons.dart';
import 'student_theme.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myStudentProfileProvider);
    final readStoriesAsync = ref.watch(myReadStoriesProvider);
    return _ProgressOverviewPage(
      profileAsync: profileAsync,
      readStoriesAsync: readStoriesAsync,
    );
  }
}

class _ProgressOverviewPage extends StatelessWidget {
  const _ProgressOverviewPage({
    required this.profileAsync,
    required this.readStoriesAsync,
  });

  final AsyncValue<StudentProfile> profileAsync;
  final AsyncValue<List<Story>> readStoriesAsync;

  @override
  Widget build(BuildContext context) {
    final student = _demoStudentProgress;
    final displayName = profileAsync.maybeWhen(
      data: (p) => p.fullName,
      orElse: () => 'Student',
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Badges',
                  child: _BadgeCard(badge: student.latestBadge),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: "Books I've read so far!",
                  child: readStoriesAsync.when(
                    data: (stories) => _BookRow(stories: stories),
                    loading: () => const _BooksLoading(),
                    error: (_, __) => const _BooksError(),
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
      if (isCurrent || level.completed)
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
    required this.currentLevelName,
    required this.latestBadge,
    required this.levels,
  });

  final String displayName;
  final String currentLevelName;
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

const _demoStudentProgress = _StudentProgress(
  displayName: 'Ayeeshah',
  currentLevelName: 'Egg',
  latestBadge: _BadgeProgress(
    name: 'Egg',
    caption: 'You reached level 1!',
    icon: Icons.egg_alt_rounded,
  ),
  levels: [
    _LevelProgress(
      name: 'Egg',
      icon: Icons.egg_alt_rounded,
      unlocked: true,
      progress: 1,
      subtitle: 'Completed',
      completed: true,
    ),
    _LevelProgress(
      name: '???',
      icon: Icons.egg_rounded,
      unlocked: false,
      progress: 0.05,
      subtitle: 'Earn 20 more points to unlock',
    ),
    _LevelProgress(
      name: '???',
      icon: Icons.bug_report_rounded,
      unlocked: false,
      progress: 0.02,
      subtitle: 'Earn 60 more points to unlock',
    ),
    _LevelProgress(
      name: '???',
      icon: Icons.pets_rounded,
      unlocked: false,
      progress: 0.01,
      subtitle: 'Earn 100 more points to unlock',
    ),
    _LevelProgress(
      name: '???',
      icon: Icons.flutter_dash_rounded,
      unlocked: false,
      progress: 0.0,
      subtitle: 'Earn 140 more points to unlock',
    ),
  ],
);
