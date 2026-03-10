import 'package:flutter/material.dart';

class HamburgerMenuOverlay extends StatelessWidget {
  const HamburgerMenuOverlay({
    super.key,
    required this.isOpen,
    this.onClose,
    this.onProfile,
    this.onProgress,
    this.onNotifications,
    this.onLogout,
  });

  final bool isOpen;
  final VoidCallback? onClose;
  final VoidCallback? onProfile;
  final VoidCallback? onProgress;
  final VoidCallback? onNotifications;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.75 > 320 ? 320.0 : size.width * 0.75;

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
              right: isOpen ? 0 : -panelWidth,
              child: SizedBox(
                width: panelWidth,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 12,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          _MenuItem(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            onTap: () {
                              onProfile?.call();
                              onClose?.call();
                            },
                          ),
                          _MenuItem(
                            icon: Icons.list_alt_outlined,
                            label: 'Progress',
                            onTap: () {
                              onProgress?.call();
                              onClose?.call();
                            },
                          ),
                          _MenuItem(
                            icon: Icons.notifications_none_outlined,
                            label: 'Notifications',
                            onTap: () {
                              onNotifications?.call();
                              onClose?.call();
                            },
                          ),
                          const Spacer(),
                          _MenuItem(
                            icon: Icons.logout,
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

