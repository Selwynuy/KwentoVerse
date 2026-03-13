import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../student/presentation/student_theme.dart';
import '../data/principal_providers.dart';

class PrincipalStoryBooksPage extends ConsumerWidget {
  const PrincipalStoryBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: StudentTheme.surfaceCream,
        body: Column(
          children: [
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
            const TabBar(
              labelColor: StudentTheme.primaryOrange,
              unselectedLabelColor: StudentTheme.secondaryGray,
              indicatorColor: StudentTheme.primaryOrange,
              labelStyle:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Archived'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _StoryList(archived: false),
                  _StoryList(archived: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Story list tab ────────────────────────────────────────────────────────────

class _StoryList extends ConsumerStatefulWidget {
  const _StoryList({required this.archived});

  final bool archived;

  @override
  ConsumerState<_StoryList> createState() => _StoryListState();
}

class _StoryListState extends ConsumerState<_StoryList> {
  // IDs being mutated right now — show per-row loading indicator.
  final Set<String> _pending = {};

  Future<void> _archiveToggle(SchoolStoryDetail story) async {
    setState(() => _pending.add(story.id));
    final client = ref.read(supabaseClientProvider);
    try {
      if (story.isArchived) {
        await unarchiveStory(client, story.id);
      } else {
        await archiveStory(client, story.id);
      }
      // skipLoadingOnReload keeps the list visible while re-fetching.
      ref.invalidate(principalSchoolStoriesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _pending.remove(story.id));
    }
  }

  Future<void> _delete(SchoolStoryDetail story) async {
    final confirmed = await _confirmDelete(story.title);
    if (!confirmed || !mounted) return;

    setState(() => _pending.add(story.id));
    final client = ref.read(supabaseClientProvider);
    try {
      await deleteStory(client, story.id);
      ref.invalidate(principalSchoolStoriesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
        setState(() => _pending.remove(story.id));
      }
      // On success the provider re-fetches and removes the row — no need to
      // manually remove from _pending since the widget rebuilds without it.
    }
  }

  Future<bool> _confirmDelete(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StudentTheme.surfaceCream,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Story',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "$title"? This cannot be undone.',
          style: const TextStyle(
            fontSize: 13,
            color: StudentTheme.secondaryGray,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: StudentTheme.secondaryGray),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // skipLoadingOnReload: keeps showing previous data while re-fetching
    // so the list doesn't flash to a spinner on every archive/delete.
    final storiesAsync = ref.watch(principalSchoolStoriesProvider);

    return storiesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudentTheme.primaryOrange),
      ),
      error: (e, _) => Center(
        child: Text(
          'Could not load stories: $e',
          style: const TextStyle(color: StudentTheme.secondaryGray),
        ),
      ),
      skipLoadingOnReload: true,
      data: (stories) {
        final filtered =
            stories.where((s) => s.isArchived == widget.archived).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              widget.archived ? 'No archived stories.' : 'No active stories.',
              style: const TextStyle(
                fontSize: 13,
                color: StudentTheme.secondaryGray,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _StoryRow(
            story: filtered[i],
            isPending: _pending.contains(filtered[i].id),
            onArchiveToggle: () => _archiveToggle(filtered[i]),
            onDelete: () => _delete(filtered[i]),
          ),
        );
      },
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _StoryRow extends StatelessWidget {
  const _StoryRow({
    required this.story,
    required this.isPending,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  final SchoolStoryDetail story;
  final bool isPending;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudentTheme.cardLightOrange),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 62,
            decoration: BoxDecoration(
              color: StudentTheme.cardLightOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: StudentTheme.primaryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: StudentTheme.titleDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (story.author.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    story.author,
                    style: const TextStyle(
                      fontSize: 11,
                      color: StudentTheme.secondaryGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (story.isArchived) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: StudentTheme.secondaryGray
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Archived',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: StudentTheme.secondaryGray,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Per-row loading indicator while mutation is in flight.
          if (isPending)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: StudentTheme.primaryOrange,
              ),
            )
          else
            PopupMenuButton<_StoryAction>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: StudentTheme.secondaryGray,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (action) {
                if (action == _StoryAction.archive) onArchiveToggle();
                if (action == _StoryAction.delete) onDelete();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: _StoryAction.archive,
                  child: Row(
                    children: [
                      Icon(
                        story.isArchived
                            ? Icons.unarchive_rounded
                            : Icons.archive_rounded,
                        size: 18,
                        color: StudentTheme.titleDark,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        story.isArchived ? 'Unarchive' : 'Archive',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _StoryAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded,
                          size: 18, color: Colors.red.shade600),
                      const SizedBox(width: 10),
                      Text(
                        'Delete',
                        style:
                            TextStyle(fontSize: 13, color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _StoryAction { archive, delete }
