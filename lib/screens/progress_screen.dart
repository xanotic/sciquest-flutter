import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/database_service.dart';
import '../models/quiz_result.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<QuizResult> _quizHistory = [];
  Map<String, dynamic> _progressData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  void _loadProgressData() async {
    final user = UserSession.instance.currentUser;
    if (user != null) {
      // Pass user.id (which is now a String)
      final history =
          await DatabaseService.instance.getUserQuizHistory(user.id);
      final progress = await DatabaseService.instance.getUserProgress(user.id);

      setState(() {
        _quizHistory = history;
        _progressData = progress;
        _isLoading = false;
      });
    } else {
      // Handle case where user is not logged in, e.g., navigate to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBackground,
              AppTheme.secondaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overall Progress
                          _buildOverallProgress(),
                          const SizedBox(height: 30),
                          // Category Progress
                          _buildCategoryProgress(),
                          const SizedBox(height: 30),
                          // Recent Quiz History
                          _buildQuizHistory(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final totalQuizzes = _progressData['total_quizzes'] ?? 0;
    final averageScore = _progressData['average_score'] ?? 0.0;
    final bestStreak = _progressData['best_streak'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.electricBlue, AppTheme.softPurple],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('Total Quizzes', totalQuizzes.toString()),
              _buildProgressStat(
                  'Avg Score', '${averageScore.toStringAsFixed(1)}%'),
              _buildProgressStat('Best Streak', bestStreak.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgress() {
    final categoryStats =
        _progressData['category_stats'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Progress',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (categoryStats.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No category progress yet.\nStart a quiz to see your stats!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...categoryStats.entries.map((entry) {
            final category = entry.key;
            final stats = entry.value as Map<String, dynamic>;
            final accuracy = (stats['accuracy'] ?? 0.0).toDouble();
            final completed = stats['completed'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppTheme.getCategoryIcon(category),
                    color: AppTheme.getCategoryColor(category),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor:
                              AppTheme.textSecondary.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getCategoryColor(category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${accuracy.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppTheme.getCategoryColor(category),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completed quizzes',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildQuizHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Quiz History',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_quizHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No quiz history yet.\nComplete a quiz to see it here!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ..._quizHistory.take(10).map((result) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(result.category)
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppTheme.getCategoryIcon(result.category),
                      color: AppTheme.getCategoryColor(result.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.category,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${result.score}/${result.totalQuestions} • ${result.accuracy.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${result.completedAt.day}/${result.completedAt.month}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
