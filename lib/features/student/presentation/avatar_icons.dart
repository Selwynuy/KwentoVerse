import 'package:flutter/material.dart';

/// Shared avatar icon for profile avatarIndex (0-5). Use everywhere we show
/// the selected profile avatar: navbar, sliding menu, progress page, profile.
IconData avatarIconFor(int index) {
  switch (index) {
    case 0:
      return Icons.sentiment_satisfied_alt_outlined;
    case 1:
      return Icons.emoji_people_outlined;
    case 2:
      return Icons.face_retouching_natural_outlined;
    case 3:
      return Icons.psychology_alt_outlined;
    case 4:
      return Icons.self_improvement_outlined;
    case 5:
    default:
      return Icons.star_border_rounded;
  }
}
