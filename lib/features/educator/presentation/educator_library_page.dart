import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stories/data/story_providers.dart';
import '../../stories/domain/story.dart';
import '../../student/presentation/student_theme.dart';

class EducatorLibraryPage extends ConsumerStatefulWidget {
  const EducatorLibraryPage({super.key});

  @override
  ConsumerState<EducatorLibraryPage> createState() =>
      _EducatorLibraryPageState();
}

class _EducatorLibraryPageState extends ConsumerState<EducatorLibraryPage> {
  int _selectedSegment = 0; // 0 = Home, 1 = Notifications

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(currentUserSchoolStoriesProvider);

    return storiesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: StudentTheme.primaryOrange),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Could not load stories: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: StudentTheme.titleDark),
          ),
        ),
      ),
      data: (stories) {
        final myLibrary = stories;
        final forYou = stories.reversed.toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSegmentControl(),
            Expanded(
              child: _selectedSegment == 0
                  ? _buildHomeContent(
                      myLibrary: myLibrary,
                      forYou: forYou,
                    )
                  : _buildNotificationsContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSegmentControl() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _SegmentChip(
              label: 'Home',
              isSelected: _selectedSegment == 0,
              onTap: () => setState(() => _selectedSegment = 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentChip(
              label: 'Notifications',
              isSelected: _selectedSegment == 1,
              onTap: () => setState(() => _selectedSegment = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent({
    required List<Story> myLibrary,
    required List<Story> forYou,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _CreateStoryBanner(),
        const SizedBox(height: 14),
        _OuterSectionCard(
          child: _InnerSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'My library',
                  actionLabel: 'See More \u2192',
                ),
                const SizedBox(height: 10),
                _HorizontalBooksStrip(
                  books: myLibrary,
                  onTap: (storyId) =>
                      context.go('/educator/story/$storyId'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _OuterSectionCard(
          child: _InnerSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Stories Available',
                  actionLabel: 'See More \u2192',
                  onActionTap: null,
                ),
                const SizedBox(height: 10),
                _HorizontalBooksStrip(
                  books: forYou,
                  onTap: (storyId) =>
                      context.go('/educator/story/$storyId'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Notifications',
          style: StudentTheme.sectionHeaderSecondary,
        ),
        SizedBox(height: 8),
        Text(
          'No notifications yet.',
          style: TextStyle(
            fontSize: 13,
            color: StudentTheme.secondaryGray,
          ),
        ),
      ],
    );
  }
}

class _CreateStoryBanner extends StatelessWidget {
  const _CreateStoryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudentTheme.primaryOrange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            color: StudentTheme.primaryOrange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Create a new story',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: StudentTheme.titleDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Write and assign stories to your students.',
                  style: TextStyle(
                    fontSize: 12,
                    color: StudentTheme.secondaryGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => context.go('/educator/stories/new'),
            style: FilledButton.styleFrom(
              backgroundColor: StudentTheme.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          isSelected ? StudentTheme.primaryOrange : StudentTheme.cardCream,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : StudentTheme.titleDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _OuterSectionCard extends StatelessWidget {
  const _OuterSectionCard({required this.child});

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
      child: child,
    );
  }
}

class _InnerSectionCard extends StatelessWidget {
  const _InnerSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StudentTheme.primaryOrange.withValues(alpha: 0.10),
        ),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: StudentTheme.sectionHeader,
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: StudentTheme.actionLabel.copyWith(fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _HorizontalBooksStrip extends StatelessWidget {
  const _HorizontalBooksStrip({
    required this.books,
    required this.onTap,
  });

  final List<Story> books;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const titleLines = 2;
    const titleFontSize = 10.5;
    const titleLineHeight = 1.05;
    const titleGap = 6.0;
    const coverHeight = 96.0;
    const tileWidth = 96.0;
    const tilePadding = 4.0;
    const titleHeight = titleFontSize * titleLineHeight * titleLines;

    if (books.isEmpty) {
      return const Text(
        'No stories yet.',
        style: TextStyle(
          fontSize: 12,
          color: StudentTheme.secondaryGray,
        ),
      );
    }

    return SizedBox(
      // Slightly taller than the student strip to avoid
      // rare bottom overflows on web with long titles.
      height: coverHeight + titleGap + titleHeight + tilePadding * 2 + 6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final book = books[i];
          return SizedBox(
            width: tileWidth,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(book.id),
                child: Padding(
                  padding: const EdgeInsets.all(tilePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _BookCoverPlaceholder(
                        width: 92,
                        height: coverHeight,
                      ),
                      const SizedBox(height: titleGap),
                      SizedBox(
                        height: titleHeight,
                        child: Text(
                          book.title,
                          textAlign: TextAlign.center,
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: titleFontSize,
                            height: titleLineHeight,
                            fontWeight: FontWeight.w600,
                            color: StudentTheme.titleDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: StudentTheme.cardLightOrange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: StudentTheme.primaryOrange.withValues(alpha: 0.7),
      ),
    );
  }
}

