import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;
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
        // Get existing profile
        try {
          final profile = await _supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();
          print('Profile found for user');
          return AppUser.User.fromSupabase(response, profile);
        } catch (e) {
          print('Profile not found: $e');
          // If profile doesn't exist, user needs to complete registration
          return null;
        }
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
        final String userId = response.user!.id;
        Map<String, dynamic>? profile;

        // Retry mechanism to wait for the profile to be created by the trigger
        for (int i = 0; i < 5; i++) {
          // Try up to 5 times
          try {
            print(
                'Attempting to fetch profile for user: $userId (attempt ${i + 1})');
            profile = await _supabase
                .from('profiles')
                .select()
                .eq('id', userId)
                .single();
            print('Profile fetched successfully');
            break; // Exit loop if profile is found
          } catch (e) {
            print('Profile fetch failed: $e. Retrying...');
            await Future.delayed(
                const Duration(seconds: 1)); // Wait before retrying
          }
        }

        if (profile != null) {
          // Update the name in the profile if it was provided during registration
          // The trigger sets name to email by default, so we update it here.
          if (name.isNotEmpty && profile['name'] != name) {
            try {
              await _supabase
                  .from('profiles')
                  .update({'name': name}).eq('id', userId);
              profile['name'] =
                  name; // Update local profile map to reflect change
              print('Profile name updated successfully');
            } catch (updateError) {
              print('Error updating profile name: $updateError');
            }
          }
          return AppUser.User.fromSupabase(response, profile);
        } else {
          print('Failed to fetch profile after multiple attempts.');
          // If profile is still null after retries, something went wrong.
          // Consider signing out the user if profile creation is critical.
          await _supabase.auth.signOut(); // Clean up partially created user
          return null;
        }
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
  Future<AppUser.User?> saveQuizResult(QuizResult result) async {
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

      // Update leaderboard entry
      await _supabase.from('leaderboard_entries').upsert({
        'user_id': result.userId,
        'total_score': newTotalScore,
        'quizzes_completed': newQuizzesCompleted,
        'accuracy': newAccuracy,
        'last_updated': DateTime.now().toIso8601String(),
      },
          onConflict:
              'user_id'); // Use onConflict to handle updates for existing users

      // After updating the profile, fetch the latest profile data
      final updatedProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', result.userId)
          .single();

      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        return AppUser.User.fromProfileJson(updatedProfile);
      }
      return null; // Should not happen if user is logged in
    } catch (e) {
      print('Save quiz result error: $e');
      return null; // Return null on error
    }
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

      print('Fetching category stats for user: $userId');
      final List<Map<String, dynamic>> categoryStatsData = await _supabase
          .from('quiz_results')
          .select('category, count(id), avg(accuracy)')
          .eq('user_id', userId)
          // Removed .group('category') as it's not a valid method here.
          // The database implicitly groups by 'category' when it's selected alongside aggregate functions.
          .order('category', ascending: true);

      print('Raw category stats data from Supabase: $categoryStatsData');

      final Map<String, dynamic> categoryStats = {};
      for (var row in categoryStatsData) {
        categoryStats[row['category']] = {
          'completed': row['count'] ?? 0,
          'accuracy': (row['avg'] ?? 0.0).toDouble(),
        };
      }
      print('Processed category stats: $categoryStats');

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
