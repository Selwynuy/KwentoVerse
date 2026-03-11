import 'package:flutter/material.dart';

/// In-app level definitions. Thresholds and names are fixed; user's current
/// level is computed from their total points (from DB or local state later).
class LevelEntry {
  const LevelEntry({
    required this.name,
    required this.minPoints,
    required this.icon,
  });

  final String name;
  final int minPoints;
  final IconData icon;
}

/// Ordered by minPoints ascending. First level is 0.
const List<LevelEntry> kLevels = [
  LevelEntry(name: 'Egg', minPoints: 0, icon: Icons.egg_alt_rounded),
  LevelEntry(name: 'Worm', minPoints: 20, icon: Icons.egg_rounded),
  LevelEntry(name: 'Caterpillar', minPoints: 60, icon: Icons.bug_report_rounded),
  LevelEntry(name: 'Chrysalis', minPoints: 100, icon: Icons.pets_rounded),
  LevelEntry(name: 'Butterfly', minPoints: 140, icon: Icons.flutter_dash_rounded),
];

/// Returns the level entry for the given total points.
LevelEntry levelForPoints(int totalPoints) {
  LevelEntry current = kLevels.first;
  for (final level in kLevels) {
    if (totalPoints >= level.minPoints) current = level;
  }
  return current;
}

/// e.g. "Level: Egg"
String levelLabelForPoints(int totalPoints) {
  return 'Level: ${levelForPoints(totalPoints).name}';
}
