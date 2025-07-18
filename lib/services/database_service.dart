import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser; // Alias your custom User model
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/leaderboard_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  final SupabaseClient _supabase = Supabase.instance.client;

  // User Authentication
  Future<AppUser.User?> loginUser(String email, String password) async {
    try {
      print('Attempting to login user: $email');
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Auth response: ${response.user?.id}');
      if (response.user != null) {
        // Try to get existing profile, create one if it doesn't exist
        var profile;
        try {
          profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
        } catch (e) {
          print('Profile not found, creating new profile: $e');
          // Create profile if it doesn't exist
          profile = await _supabase
              .from('profiles')
              .insert({
                'id': response.user!.id,
                'name': response.user!.email?.split('@')[0] ?? 'User',
                'email': response.user!.email!,
                'total_score': 0,
                'quizzes_completed': 0,
                'accuracy': 0.0,
              })
              .select()
              .single();
        }

        // Pass the AuthResponse directly to the factory
        return AppUser.User.fromSupabase(response, profile);
      }
    } on AuthException catch (e) {
      print('Login error: ${e.message}');
      return null;
    } catch (e) {
      print('Login unexpected error: $e');
      return null;
    }
    return null;
  }

  Future<AppUser.User?> registerUser(
      String name, String email, String password) async {
    try {
      print('Attempting to register user: $email');
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      print('Registration auth response: ${response.user?.id}');
      if (response.user != null) {
        // Check if profile already exists (in case of email confirmation flow)
        var profile;
        try {
          profile = await _supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();
        } catch (e) {
          // Profile doesn't exist, create it
          try {
            profile = await _supabase
                .from('profiles')
                .insert({
                  'id': response.user!.id,
                  'name': name,
                  'email': email,
                  'total_score': 0,
                  'quizzes_completed': 0,
                  'accuracy': 0.0,
                })
                .select()
                .single();
          } catch (insertError) {
            print('Error creating profile: $insertError');
            return null;
          }
        }

        // Pass the AuthResponse directly to the factory
        return AppUser.User.fromSupabase(response, profile);
      }
    } on AuthException catch (e) {
      print('Registration error: ${e.message}');
      return null;
    } catch (e) {
      print('Registration unexpected error: $e');
      return null;
    }
    return null;
  }

  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Questions
  Future<List<Question>> getQuestionsByCategory(String category) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('questions')
          .select()
          .eq('category', category)
          .order('id', ascending: true);

      return data.map((q) => Question.fromJson(q)).toList();
    } catch (e) {
      print('Get questions by category error: $e');
    }
    return [];
  }

  Future<List<Question>> getRandomQuestions(int count,
      {String? gameMode}) async {
    try {
      var query = _supabase.from('questions').select();

      if (gameMode != null && gameMode != 'all') {
        switch (gameMode) {
          case 'science':
            query =
                query.inFilter('category', ['Physics', 'Chemistry', 'Biology']);
            break;
          case 'mathematics':
            query = query.eq('category', 'Mathematics');
            break;
          case 'technology':
            query =
                query.inFilter('category', ['Computer Science', 'Engineering']);
            break;
          case 'expert':
            query = query.eq('difficulty', 'hard');
            break;
        }
      }

      final List<Map<String, dynamic>> data = await query.limit(count * 2);

      final List<Question> allQuestions =
          data.map((q) => Question.fromJson(q)).toList();
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      print('Get random questions error: $e');
    }
    return [];
  }

  // Quiz Results
  Future<bool> saveQuizResult(QuizResult result) async {
    try {
      await _supabase.from('quiz_results').insert({
        'user_id': result.userId,
        'score': result.score,
        'total_questions': result.totalQuestions,
        'accuracy': result.accuracy,
        'category': result.category,
        'game_mode': result.gameMode,
        'time_spent': result.timeSpent,
        'completed_at': result.completedAt.toIso8601String(),
        'question_ids': result.questionIds,
        'user_answers': result.userAnswers,
      });

      final currentProfile = await _supabase
          .from('profiles')
          .select('total_score, quizzes_completed, accuracy')
          .eq('id', result.userId)
          .single();

      final int currentTotalScore = currentProfile['total_score'] ?? 0;
      final int currentQuizzesCompleted =
          currentProfile['quizzes_completed'] ?? 0;

      final newTotalScore = currentTotalScore + result.score;
      final newQuizzesCompleted = currentQuizzesCompleted + 1;
      // Recalculate accuracy based on total correct answers and total questions across all quizzes
      // Ensure total questions is not zero to avoid division by zero
      final totalQuestionsAnswered = (currentQuizzesCompleted *
              (result.totalQuestions / newQuizzesCompleted)) +
          result
              .totalQuestions; // Simplified for now, might need more robust tracking
      final newAccuracy = totalQuestionsAnswered > 0
          ? (newTotalScore / totalQuestionsAnswered) * 100
          : 0.0;

      await _supabase.from('profiles').update({
        'total_score': newTotalScore,
        'quizzes_completed': newQuizzesCompleted,
        'accuracy': newAccuracy,
      }).eq('id', result.userId);

      return true;
    } catch (e) {
      print('Save quiz result error: $e');
    }
    return false;
  }

  Future<List<QuizResult>> getUserQuizHistory(String userId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('quiz_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return data.map((r) => QuizResult.fromJson(r)).toList();
    } catch (e) {
      print('Get quiz history error: $e');
    }
    return [];
  }

  // Leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('profiles')
          .select('id, name, avatar, total_score, quizzes_completed, accuracy')
          .order('total_score', ascending: false)
          .order('accuracy', ascending: false)
          .limit(limit);

      return data.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final profile = entry.value;
        return LeaderboardEntry(
          rank: rank,
          userId: profile['id'],
          userName: profile['name'],
          userAvatar: profile['avatar'],
          totalScore: profile['total_score'],
          quizzesCompleted: profile['quizzes_completed'],
          accuracy: (profile['accuracy'] ?? 0.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print('Get leaderboard error: $e');
    }
    return [];
  }

  // User Progress
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('total_score, quizzes_completed, accuracy')
          .eq('id', userId)
          .single();

      // Corrected select for aggregation and grouping:
      // When using aggregate functions like count() and avg(), PostgREST automatically groups
      // by any non-aggregated columns in the select statement.
      final List<Map<String, dynamic>> categoryStatsData = await _supabase
          .from('quiz_results')
          .select(
              'category, count(id), avg(accuracy)') // Removed the second positional argument
          .eq('user_id', userId)
          .order('category', ascending: true);

      final Map<String, dynamic> categoryStats = {};
      for (var row in categoryStatsData) {
        categoryStats[row['category']] = {
          'completed': row['count'] ?? 0,
          'accuracy': (row['avg'] ?? 0.0).toDouble(),
        };
      }

      return {
        'total_quizzes': profile['quizzes_completed'] ?? 0,
        'average_score': profile['accuracy'] ?? 0.0,
        'best_score': 0, // This would require more complex logic
        'total_time_spent': 0, // This would require more complex logic
        'best_streak': 0, // This would require more complex logic
        'category_stats': categoryStats,
      };
    } catch (e) {
      print('Get user progress error: $e');
    }
    return {};
  }

  Future<bool> updateUserProfile(AppUser.User user) async {
    try {
      await _supabase.from('profiles').update({
        'name': user.name,
        'avatar': user.avatar,
      }).eq('id', user.id);
      return true;
    } catch (e) {
      print('Update profile error: $e');
    }
    return false;
  }
}
