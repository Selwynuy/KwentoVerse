/// One stage in a quiz (e.g. Activity 3/3).
class StageScore {
  const StageScore({
    required this.stageName,
    required this.correct,
    required this.total,
  });

  final String stageName;
  final int correct;
  final int total;

  Map<String, dynamic> toJson() => {
        'stage': stageName,
        'correct': correct,
        'total': total,
      };

  static StageScore fromJson(Map<String, dynamic> json) {
    return StageScore(
      stageName: (json['stage'] as String?) ?? '',
      correct: (json['correct'] is int) ? json['correct'] as int : ((json['correct'] as num?)?.toInt() ?? 0),
      total: (json['total'] is int) ? json['total'] as int : ((json['total'] as num?)?.toInt() ?? 0),
    );
  }
}

/// Quiz attempt record (for save and for list from DB).
class QuizResult {
  const QuizResult({
    required this.storyId,
    required this.stageScores,
    required this.totalCorrect,
    required this.totalQuestions,
    this.attemptedAt,
  });

  final String storyId;
  final List<StageScore> stageScores;
  final int totalCorrect;
  final int totalQuestions;
  final DateTime? attemptedAt;

  Map<String, dynamic> toInsertRow(String userId) => {
        'user_id': userId,
        'story_id': storyId,
        'total_correct': totalCorrect,
        'total_questions': totalQuestions,
        'stage_scores': stageScores.map((s) => s.toJson()).toList(),
      };
}

/// Quiz result with story display info (for progress page).
class QuizResultWithStory {
  const QuizResultWithStory({
    required this.storyId,
    required this.storyTitle,
    required this.storyAuthor,
    required this.stageScores,
    required this.totalCorrect,
    required this.totalQuestions,
    this.attemptedAt,
  });

  final String storyId;
  final String storyTitle;
  final String storyAuthor;
  final List<StageScore> stageScores;
  final int totalCorrect;
  final int totalQuestions;
  final DateTime? attemptedAt;

  static QuizResultWithStory fromRow(Map<String, dynamic> row) {
    final stageScoresRaw = row['stage_scores'];
    List<StageScore> stageScores = [];
    if (stageScoresRaw is List) {
      for (final e in stageScoresRaw) {
        if (e is Map<String, dynamic>) stageScores.add(StageScore.fromJson(e));
      }
    }
    return QuizResultWithStory(
      storyId: row['story_id'] as String,
      storyTitle: (row['title'] as String?)?.trim().isNotEmpty == true ? (row['title'] as String).trim() : 'Untitled',
      storyAuthor: (row['author'] as String?)?.trim() ?? '',
      stageScores: stageScores,
      totalCorrect: (row['total_correct'] is int) ? row['total_correct'] as int : ((row['total_correct'] as num?)?.toInt() ?? 0),
      totalQuestions: (row['total_questions'] is int) ? row['total_questions'] as int : ((row['total_questions'] as num?)?.toInt() ?? 0),
      attemptedAt: row['attempted_at'] != null ? DateTime.tryParse(row['attempted_at'].toString()) : null,
    );
  }
}
