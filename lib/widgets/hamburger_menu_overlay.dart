import 'package:flutter/material.dart';

import '../features/student/presentation/avatar_icons.dart';

class HamburgerMenuOverlay extends StatelessWidget {
  const HamburgerMenuOverlay({
    super.key,
    required this.isOpen,
    this.displayName,
    this.levelLabel,
    this.avatarUrl,
    this.avatarIndex,
    this.onClose,
    this.onProfile,
    this.onProgress,
    this.onLogout,
    this.progressLabel = 'Progress',
    this.progressIcon,
  });

  final bool isOpen;
  final String? displayName;
  final String? levelLabel;
  final String? avatarUrl;
  final int? avatarIndex;
  final VoidCallback? onClose;
  final VoidCallback? onProfile;
  final VoidCallback? onProgress;
  final VoidCallback? onLogout;
  final String progressLabel;
  final IconData? progressIcon;

  static const _progressBarOrange = Color(0xFFFF9500);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.75 > 320 ? 320.0 : size.width * 0.75;
    final theme = Theme.of(context);

    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        opacity: isOpen ? 1 : 0,
        child: Stack(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black54,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isOpen ? 0 : -panelWidth,
              child: SizedBox(
                width: panelWidth,
                child: Material(
                  color: theme.colorScheme.surface,
                  elevation: 12,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 16),
                          _buildProgressSection(context),
                          const SizedBox(height: 24),
                          _MenuItem(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            onTap: () {
                              onProfile?.call();
                              onClose?.call();
                            },
                          ),
                          if (onProgress != null)
                            _MenuItem(
                              icon: progressIcon ?? Icons.trending_up_rounded,
                              label: progressLabel,
                              onTap: () {
                                onProgress?.call();
                                onClose?.call();
                              },
                            ),
                          const Spacer(),
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            onTap: () {
                              onLogout?.call();
                              onClose?.call();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final name = displayName ?? 'Student';
    final level = levelLabel ?? 'Level Egg';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(context),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                level,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: Colors.grey[200],
      );
    }
    final icon = avatarIndex != null
        ? avatarIconFor(avatarIndex!)
        : Icons.person_rounded;
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey[300],
      child: Icon(icon, size: 32, color: Colors.grey[700]),
    );
  }

  /// Placeholder progress bar; real progress data to be wired later.
  Widget _buildProgressSection(BuildContext context) {
    const progressFraction = 0.4; // 40% placeholder
    const percentNeeded = 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      SizedBox(
                        width: barWidth * progressFraction,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: _progressBarOrange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.emoji_events_rounded, size: 20, color: Colors.amber[700]),
            const SizedBox(width: 2),
            Icon(Icons.emoji_events_rounded, size: 20, color: Colors.amber[700]),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'You need $percentNeeded% more to level up!',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _progressBarOrange,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
