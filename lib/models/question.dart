class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
  final String subcategory;
  final String difficulty;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.subcategory,
    required this.difficulty,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      category: json['category'],
      subcategory: json['subcategory'],
      difficulty: json['difficulty'],
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'category': category,
      'subcategory': subcategory,
      'difficulty': difficulty,
      'explanation': explanation,
    };
  }
}
