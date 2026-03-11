import 'package:flutter/material.dart';

import '../features/student/presentation/student_theme.dart';

class StudentNavbar extends StatelessWidget implements PreferredSizeWidget {
  const StudentNavbar({
    super.key,
    required this.displayName,
    required this.levelLabel,
    this.avatarUrl,
    this.onMenuTap,
  });

  final String displayName;
  final String levelLabel;
  final String? avatarUrl;
  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: StudentTheme.surfaceCream,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkResponse(
            radius: 28,
            onTap: onMenuTap,
            child: _buildAvatar(context),
          ),
        ),
      ),
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'KwentoVerse',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: StudentTheme.titleDark,
                  ),
            ),
            const SizedBox(height: 4),
            _buildProgressBar(),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.emoji_events_rounded,
            color: StudentTheme.primaryOrange,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressBar() {
    const progress = 0.35;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: StudentTheme.primaryOrange.withValues(alpha: 0.18),
        valueColor: const AlwaysStoppedAnimation<Color>(StudentTheme.primaryOrange),
        minHeight: 3,
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: StudentTheme.cardLightOrange,
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: StudentTheme.cardLightOrange,
      child: Icon(
        Icons.person_rounded,
        size: 18,
        color: StudentTheme.primaryOrange,
      ),
    );
  }
}
