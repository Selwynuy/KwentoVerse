import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/story_readers_providers.dart';
import '../data/story_readers_repository.dart';
import '../../student/presentation/avatar_icons.dart';
import '../../student/presentation/student_theme.dart';

class StoryReadersPage extends ConsumerWidget {
  const StoryReadersPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readersAsync = ref.watch(storyReadersProvider(storyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story readers'),
      ),
      body: readersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: StudentTheme.primaryOrange,
          ),
        ),
        error: (e, st) => const Center(
          child: Text(
            'Could not load readers.',
            style: TextStyle(
              color: StudentTheme.secondaryGray,
              fontSize: 13,
            ),
          ),
        ),
        data: (readers) {
          if (readers.isEmpty) {
            return const Center(
              child: Text(
                'No students in this school yet.',
                style: TextStyle(
                  color: StudentTheme.secondaryGray,
                  fontSize: 13,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: readers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = readers[i];
              return _ReaderTile(entry: r);
            },
          );
        },
      ),
    );
  }
}

class _ReaderTile extends StatelessWidget {
  const _ReaderTile({required this.entry});

  final StoryReaderEntry entry;

  @override
  Widget build(BuildContext context) {
    final icon = entry.avatarIndex != null
        ? avatarIconFor(entry.avatarIndex!)
        : Icons.person_rounded;
    final hasRead = entry.hasRead;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StudentTheme.cardLightOrange,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: StudentTheme.cardLightOrange,
            child: Icon(
              icon,
              size: 20,
              color: StudentTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StudentTheme.titleDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: hasRead
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              hasRead ? 'Read' : 'Not yet',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: hasRead ? Colors.green.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

