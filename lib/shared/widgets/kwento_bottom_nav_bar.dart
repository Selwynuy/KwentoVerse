import 'package:flutter/material.dart';

class KwentoBottomNavBarItem {
  const KwentoBottomNavBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class KwentoBottomNavBar extends StatelessWidget {
  const KwentoBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
  }) : assert(items.length == 3, 'KwentoBottomNavBar currently supports exactly 3 items.');

  final List<KwentoBottomNavBarItem> items;
  final int currentIndex;

  static const _activeColor = Color(0xFFFF9500); // orange
  static const _inactiveColor = Color(0xFF3C3C43); // dark gray
  static const double _baseHeight = 52;
  static const double _contentVerticalPadding = 4;
  static const double _iconSize = 22;
  static const double _labelFontSize = 10;
  static const double _iconLabelGap = 2;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: _baseHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: _contentVerticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    isSelected: i == currentIndex,
                    onTap: items[i].onTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? KwentoBottomNavBar._activeColor : KwentoBottomNavBar._inactiveColor;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: KwentoBottomNavBar._iconSize, color: color),
              const SizedBox(height: KwentoBottomNavBar._iconLabelGap),
              Text(
                label,
                style: TextStyle(
                  fontSize: KwentoBottomNavBar._labelFontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
