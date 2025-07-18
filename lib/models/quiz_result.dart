class QuizResult {
  final int? id;
  final String userId; // Changed from int to String
  final int score;
  final int totalQuestions;
  final double accuracy;
  final String category;
  final String gameMode;
  final int timeSpent;
  final DateTime completedAt;
  final List<int> questionIds;
  final List<int> userAnswers;

  QuizResult({
    this.id,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.category,
    required this.gameMode,
    required this.timeSpent,
    required this.completedAt,
    required this.questionIds,
    required this.userAnswers,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      userId: json['user_id'], // Ensure this is read as String
      score: json['score'],
      totalQuestions: json['total_questions'],
      accuracy: (json['accuracy']).toDouble(),
      category: json['category'],
      gameMode: json['game_mode'],
      timeSpent: json['time_spent'],
      completedAt: DateTime.parse(json['completed_at']),
      questionIds: List<int>.from(json['question_ids']),
      userAnswers: List<int>.from(json['user_answers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
      'accuracy': accuracy,
      'category': category,
      'game_mode': gameMode,
      'time_spent': timeSpent,
      'completed_at': completedAt.toIso8601String(),
      'question_ids': questionIds,
      'user_answers': userAnswers,
    };
  }
}
