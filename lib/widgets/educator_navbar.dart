import 'package:flutter/material.dart';

import '../features/student/presentation/avatar_icons.dart';
import '../features/student/presentation/student_theme.dart';

class EducatorNavbar extends StatelessWidget implements PreferredSizeWidget {
  const EducatorNavbar({
    super.key,
    required this.displayName,
    required this.levelLabel,
    this.avatarUrl,
    this.avatarIndex,
    this.onMenuTap,
  });

  final String displayName;
  final String levelLabel;
  final String? avatarUrl;
  final int? avatarIndex;
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
        child: Text(
          'KwentoVerse',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: StudentTheme.titleDark,
              ),
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

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: StudentTheme.cardLightOrange,
      );
    }
    final icon =
        avatarIndex != null ? avatarIconFor(avatarIndex!) : Icons.person_rounded;
    return CircleAvatar(
      radius: 16,
      backgroundColor: StudentTheme.cardLightOrange,
      child: Icon(icon, size: 18, color: StudentTheme.primaryOrange),
    );
  }
}

