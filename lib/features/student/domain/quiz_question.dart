/// A single MCQ question fetched from Supabase `quiz_questions`.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.storyId,
    required this.stage,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.sortOrder,
  });

  final String id;
  final String storyId;
  final String stage; // 'activity' | 'abstraction' | 'application' | 'assessment'
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int sortOrder;

  factory QuizQuestion.fromRow(Map<String, dynamic> row) {
    final rawOptions = row['options'];
    List<String> options = [];
    if (rawOptions is List) {
      options = rawOptions.map((e) => e.toString()).toList();
    }
    return QuizQuestion(
      id: row['id'] as String,
      storyId: row['story_id'] as String,
      stage: (row['stage'] as String?) ?? 'activity',
      prompt: (row['prompt'] as String?) ?? '',
      options: options,
      correctIndex: _toInt(row['correct_index']),
      sortOrder: _toInt(row['sort_order']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'story_id': storyId,
        'stage': stage,
        'prompt': prompt,
        'options': options,
        'correct_index': correctIndex,
        'sort_order': sortOrder,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      QuizQuestion.fromRow(json);

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}
