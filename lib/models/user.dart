import 'package:supabase_flutter/supabase_flutter.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int totalScore;
  final int quizzesCompleted;
  final double accuracy;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.accuracy,
    required this.createdAt,
  });

  // Updated to accept AuthResponse directly
  factory User.fromSupabase(
      AuthResponse authResponse, Map<String, dynamic> profileData) {
    final authUser = authResponse.user!;
    return User(
      id: authUser.id,
      name: profileData['name'] ?? authUser.email?.split('@')[0] ?? 'User',
      email: authUser.email!,
      avatar: profileData['avatar'],
      totalScore: profileData['total_score'] ?? 0,
      quizzesCompleted: profileData['quizzes_completed'] ?? 0,
      accuracy: (profileData['accuracy'] ?? 0.0).toDouble(),
      // Explicitly handle nullable DateTime from authUser.createdAt
      createdAt: authUser.createdAt is String
          ? DateTime.parse(authUser.createdAt as String)
          : (authUser.createdAt is DateTime
              ? authUser.createdAt as DateTime
              : DateTime.now()),
    );
  }

  factory User.fromProfileJson(Map<String, dynamic> json) {
    // Safely get 'created_at' as a String, or null if it's not a string or doesn't exist
    final dynamic createdAtValue = json['created_at'];
    DateTime parsedCreatedAt;

    if (createdAtValue is String) {
      parsedCreatedAt = DateTime.parse(createdAtValue);
    } else if (createdAtValue is DateTime) {
      // Handle if it's already a DateTime object
      parsedCreatedAt = createdAtValue;
    } else {
      parsedCreatedAt =
          DateTime.now(); // Fallback if type is unexpected or null
    }

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      avatar: json['avatar'],
      totalScore: json['total_score'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'total_score': totalScore,
      'quizzes_completed': quizzesCompleted,
      'accuracy': accuracy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
