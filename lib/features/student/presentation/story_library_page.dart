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
        const Text(
          'Current readings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: StudentTheme.titleDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _currentReadings.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final item = _currentReadings[i];
              return SizedBox(
                width: 280,
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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See More →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: StudentTheme.titleDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._exercises.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReadingCard(
              title: item.title,
              author: item.author,
              progress: item.progress,
              onTap: () {},
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StudentTheme.titleDark,
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StudentTheme.titleDark,
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BookCoverPlaceholder(width: 56, height: 80),
              const SizedBox(width: 12),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: StudentTheme.titleDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 13,
                        color: StudentTheme.secondaryGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                progress,
                style: const TextStyle(
                  fontSize: 12,
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
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: StudentTheme.titleDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
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
