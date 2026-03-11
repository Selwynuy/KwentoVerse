import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../student/domain/quiz_question.dart';
import '../domain/story.dart';

/// Persists downloaded stories (+ their quiz questions) to SharedPreferences
/// so they survive app restarts and are available offline.
class DownloadedStoryCache {
  DownloadedStoryCache._();
  static final DownloadedStoryCache instance = DownloadedStoryCache._();

  static const _storiesKey = 'downloaded_stories_v1';
  static const _questionsKey = 'downloaded_questions_v1';

  final Map<String, Story> _stories = {};
  final Map<String, List<QuizQuestion>> _questions = {};
  bool _loaded = false;

  /// Must be called once at app startup before using the cache.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();

    final storiesJson = prefs.getString(_storiesKey);
    if (storiesJson != null) {
      final map = jsonDecode(storiesJson) as Map<String, dynamic>;
      for (final entry in map.entries) {
        if (entry.value is Map<String, dynamic>) {
          _stories[entry.key] = Story.fromJson(entry.value as Map<String, dynamic>);
        }
      }
    }

    final questionsJson = prefs.getString(_questionsKey);
    if (questionsJson != null) {
      final map = jsonDecode(questionsJson) as Map<String, dynamic>;
      for (final entry in map.entries) {
        if (entry.value is List) {
          _questions[entry.key] = (entry.value as List)
              .whereType<Map<String, dynamic>>()
              .map(QuizQuestion.fromJson)
              .toList();
        }
      }
    }
  }

  Story? get(String id) => _stories[id];
  List<QuizQuestion>? getQuestions(String storyId) => _questions[storyId];
  bool has(String id) => _stories.containsKey(id);

  Future<void> put(Story story, {List<QuizQuestion>? questions}) async {
    _stories[story.id] = story;
    if (questions != null) _questions[story.id] = questions;
    await _persist();
  }

  Future<void> remove(String id) async {
    _stories.remove(id);
    _questions.remove(id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final storiesMap = {
      for (final e in _stories.entries) e.key: e.value.toJson(),
    };
    await prefs.setString(_storiesKey, jsonEncode(storiesMap));

    final questionsMap = {
      for (final e in _questions.entries)
        e.key: e.value.map((q) => q.toJson()).toList(),
    };
    await prefs.setString(_questionsKey, jsonEncode(questionsMap));
  }
}
