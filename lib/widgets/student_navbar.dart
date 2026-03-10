import 'package:flutter/material.dart';

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
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hi, $displayName!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                levelLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: Colors.grey[200],
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 20,
        color: Colors.grey[700],
      ),
    );
  }
}

