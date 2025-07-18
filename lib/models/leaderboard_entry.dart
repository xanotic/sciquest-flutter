class LeaderboardEntry {
  final int rank;
  final String userId; // Changed from int to String
  final String userName;
  final String? userAvatar;
  final int totalScore;
  final int quizzesCompleted;
  final double accuracy;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.accuracy,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      userId: json['user_id'], // Ensure this is read as String
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      totalScore: json['total_score'],
      quizzesCompleted: json['quizzes_completed'],
      accuracy: (json['accuracy']).toDouble(),
    );
  }
}
