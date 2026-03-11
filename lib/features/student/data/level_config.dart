import 'package:flutter/material.dart';

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

/// Ordered by minPoints ascending. First level starts at 0.
const List<LevelEntry> kLevels = [
  LevelEntry(name: 'Egg',         minPoints: 0,   icon: Icons.egg_alt_rounded),
  LevelEntry(name: 'Hatchling',   minPoints: 20,  icon: Icons.egg_rounded),
  LevelEntry(name: 'Caterpillar', minPoints: 60,  icon: Icons.bug_report_rounded),
  LevelEntry(name: 'Explorer',    minPoints: 100, icon: Icons.pets_rounded),
  LevelEntry(name: 'Kwento Dash', minPoints: 140, icon: Icons.flutter_dash_rounded),
];

LevelEntry levelForPoints(int totalPoints) {
  LevelEntry current = kLevels.first;
  for (final level in kLevels) {
    if (totalPoints >= level.minPoints) current = level;
  }
  return current;
}

String levelLabelForPoints(int totalPoints) =>
    'Level: ${levelForPoints(totalPoints).name}';
