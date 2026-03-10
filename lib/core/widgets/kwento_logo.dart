import 'package:flutter/material.dart';

class KwentoLogo extends StatelessWidget {
  const KwentoLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size;
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: iconSize,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          Positioned(
            top: iconSize * 0.08,
            right: iconSize * 0.15,
            child: Icon(
              Icons.auto_awesome,
              size: iconSize * 0.28,
              color: accent.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

