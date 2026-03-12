import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import '../../student/presentation/student_theme.dart';
import '../../student/presentation/avatar_icons.dart';
import '../data/educator_profile_providers.dart';
import '../data/school_students_providers.dart';
import '../data/school_students_repository.dart';

class EducatorSchoolSettingsPage extends ConsumerWidget {
  const EducatorSchoolSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myEducatorProfileProvider);
    final storiesAsync = ref.watch(currentUserSchoolStoriesProvider);
    final studentsAsync = ref.watch(schoolStudentsProvider);

    final displayName = profileAsync.maybeWhen(
      data: (p) => p.fullName,
      orElse: () => 'Educator',
    );
    final avatarIndex = profileAsync.maybeWhen(
      data: (p) => p.avatarIndex,
      orElse: () => null,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/educator/home');
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
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: StudentTheme.cardLightOrange,
            child: Icon(
              avatarIndex != null
                  ? avatarIconFor(avatarIndex)
                  : Icons.person_rounded,
              size: 44,
              color: StudentTheme.primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: StudentTheme.titleDark,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Educator',
            style: TextStyle(
              fontSize: 12,
              color: StudentTheme.secondaryGray,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ── School Students ──────────────────────────────────────────
        _SectionCard(
          title: 'School Students',
          child: studentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, st) => const Text(
              'Could not load students.',
              style: TextStyle(
                color: StudentTheme.secondaryGray,
                fontSize: 13,
              ),
            ),
            data: (students) {
              if (students.isEmpty) {
                return const Text(
                  'No students enrolled yet.',
                  style: TextStyle(
                    color: StudentTheme.secondaryGray,
                    fontSize: 13,
                  ),
                );
              }
              return _StudentList(students: students);
            },
          ),
        ),

        const SizedBox(height: 14),

        // ── My Library (stories → readers) ──────────────────────────
        _SectionCard(
          title: 'My Library',
          child: storiesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, st) => const Text(
              'Could not load library.',
              style: TextStyle(
                color: StudentTheme.secondaryGray,
                fontSize: 13,
              ),
            ),
            data: (stories) {
              if (stories.isEmpty) {
                return const Text(
                  'No stories yet.',
                  style: TextStyle(
                    color: StudentTheme.secondaryGray,
                    fontSize: 13,
                  ),
                );
              }
              return _StoryList(stories: stories);
            },
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: StudentTheme.cardCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.16),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StudentTheme.cardLightOrange,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: StudentTheme.primaryOrange.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: StudentTheme.sectionHeader),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _StudentList extends StatelessWidget {
  const _StudentList({required this.students});

  final List<SchoolStudent> students;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final student in students)
          InkWell(
            onTap: () => context.push(
              '/educator/student/${student.userId}/progress',
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StudentTheme.cardLightOrange,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: StudentTheme.primaryOrange.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: StudentTheme.cardCream,
                    child: Icon(
                      student.avatarIndex != null
                          ? avatarIconFor(student.avatarIndex!)
                          : Icons.person_rounded,
                      size: 20,
                      color: StudentTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      student.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: StudentTheme.titleDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: StudentTheme.secondaryGray,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryList extends StatelessWidget {
  const _StoryList({required this.stories});

  final List<Story> stories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final story in stories)
          InkWell(
            onTap: () => context.push(
              '/educator/story-readers/${story.id}',
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StudentTheme.cardLightOrange,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: StudentTheme.primaryOrange.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 66,
                    decoration: BoxDecoration(
                      color: StudentTheme.cardCream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: StudentTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: StudentTheme.titleDark,
                          ),
                        ),
                        if (story.author.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            story.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: StudentTheme.secondaryGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: StudentTheme.secondaryGray,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
