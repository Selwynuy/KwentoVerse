import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'student_theme.dart';

class StoryLibraryPage extends StatefulWidget {
  const StoryLibraryPage({super.key});

  @override
  State<StoryLibraryPage> createState() => _StoryLibraryPageState();
}

class _StoryLibraryPageState extends State<StoryLibraryPage> {
  int _selectedSegment = 0; // 0 = Home, 1 = Notifications

  static const _myLibrary = [
    _BookItem('It\'s Not Hansel and Gretel'),
    _BookItem('Tonya and Her Perfect Tea'),
    _BookItem('The Three Little Pigs'),
  ];

  static const _forYou = [
    _BookItem('Be Kind'),
    _BookItem('My Quiet Imagination'),
    _BookItem('A Day At Abbott Elementary'),
  ];

  static const _currentReadings = [
    _ReadingItem('It\'s Not Hansel and Gretel', 'Josh Funk', '100% done'),
  ];

  static const _exercises = [
    _ReadingItem('It\'s Not Hansel and Gretel', 'Josh Funk', '3/15 answered'),
    _ReadingItem('Tonya and Her Perfect Tea', 'Alina Slyshik', '15/15 answered'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSegmentControl(),
        Expanded(
          child: _selectedSegment == 0 ? _buildHomeContent() : _buildNotificationsContent(),
        ),
      ],
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

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OuterSectionCard(
          child: _InnerSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'My library',
                  actionLabel: 'See More →',
                  onActionTap: () {},
                ),
                const SizedBox(height: 10),
                _HorizontalBooksStrip(books: _myLibrary),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'For you',
                  actionLabel: 'See More →',
                  onActionTap: () {},
                ),
                const SizedBox(height: 10),
                _HorizontalBooksStrip(books: _forYou),
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
                const Text(
                  'Current readings',
                  style: StudentTheme.sectionHeader,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentReadings.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final item = _currentReadings[i];
                      return SizedBox(
                        width: 250,
                        child: _ReadingCard(
                          title: item.title,
                          author: item.author,
                          progress: item.progress,
                          onTap: () => context.go('/student/story/sample-1'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Exercises',
                  actionLabel: 'See More →',
                  onActionTap: () {},
                ),
                const SizedBox(height: 10),
                ..._exercises.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReadingCard(
                      title: item.title,
                      author: item.author,
                      progress: item.progress,
                      onTap: () {},
                    ),
                  ),
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
      children: [
        const Text(
          'Today',
          style: StudentTheme.sectionHeaderSecondary,
        ),
        const SizedBox(height: 8),
        _NotificationTile(
          icon: Icons.emoji_events_rounded,
          iconColor: StudentTheme.primaryOrange,
          message: 'You received a badge for leveling up! Level: Worm',
          time: '1 hour ago',
          backgroundColor: StudentTheme.cardLightOrange,
        ),
        const SizedBox(height: 24),
        const Text(
          'Earlier',
          style: StudentTheme.sectionHeaderSecondary,
        ),
        const SizedBox(height: 8),
        _NotificationTile(
          icon: Icons.people_rounded,
          iconColor: StudentTheme.secondaryGray,
          message: 'A new story is available in the school!',
          time: '17 hours ago',
          backgroundColor: Colors.white,
        ),
      ],
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
      color: isSelected ? StudentTheme.primaryOrange : StudentTheme.cardCream,
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

class _ReadingItem {
  const _ReadingItem(this.title, this.author, this.progress);
  final String title;
  final String author;
  final String progress;
}

class _BookItem {
  const _BookItem(this.title);
  final String title;
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
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.16)),
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
        border: Border.all(color: StudentTheme.primaryOrange.withValues(alpha: 0.10)),
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
  const _HorizontalBooksStrip({required this.books});

  final List<_BookItem> books;

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

    return SizedBox(
      // Tile content includes internal padding; account for it to avoid overflow.
      height: coverHeight + titleGap + titleHeight + tilePadding * 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final book = books[i];
          final id = book.title == "It's Not Hansel and Gretel" ? 'sample-1' : 'sample-1';
          return SizedBox(
            width: tileWidth,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go('/student/story/$id'),
                child: Padding(
                  padding: const EdgeInsets.all(tilePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BookCoverPlaceholder(width: 92, height: coverHeight),
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

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.title,
    required this.author,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String author;
  final String progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudentTheme.cardLightOrange,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BookCoverPlaceholder(width: 46, height: 66),
              const SizedBox(width: 10),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: StudentTheme.titleDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StudentTheme.secondaryGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                progress,
                style: const TextStyle(
                  fontSize: 11,
                  color: StudentTheme.secondaryGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.time,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final String time;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: backgroundColor == Colors.white
            ? Border.all(color: StudentTheme.cardLightOrange)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: StudentTheme.titleDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: StudentTheme.secondaryGray,
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
