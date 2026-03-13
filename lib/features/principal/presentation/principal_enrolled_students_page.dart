import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../educator/data/school_students_providers.dart';
import '../../educator/data/school_students_repository.dart';
import '../../student/presentation/avatar_icons.dart';
import '../../student/presentation/student_theme.dart';

class PrincipalEnrolledStudentsPage extends ConsumerWidget {
  const PrincipalEnrolledStudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(schoolStudentsProvider);

    return Scaffold(
      backgroundColor: StudentTheme.surfaceCream,
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────
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
                      'KwentoVerse',
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

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enrolled Students',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: StudentTheme.titleDark,
                ),
              ),
            ),
          ),

          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: StudentTheme.primaryOrange),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Could not load students: $e',
                  style:
                      const TextStyle(color: StudentTheme.secondaryGray),
                ),
              ),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students enrolled yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: StudentTheme.secondaryGray,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: students.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _StudentRow(student: students[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final SchoolStudent student;

  @override
  Widget build(BuildContext context) {
    final icon = student.avatarIndex != null
        ? avatarIconFor(student.avatarIndex!)
        : Icons.person_rounded;

    return InkWell(
      onTap: () =>
          context.push('/educator/student/${student.userId}/progress'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudentTheme.cardLightOrange),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: StudentTheme.cardLightOrange,
              child:
                  Icon(icon, size: 22, color: StudentTheme.primaryOrange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                student.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: StudentTheme.titleDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: StudentTheme.secondaryGray,
            ),
          ],
        ),
      ),
    );
  }
}
