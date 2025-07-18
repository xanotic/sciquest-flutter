import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/database_service.dart';
import '../models/quiz_result.dart';
import '../models/question.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _category = '';
  List<QuizResult> _categoryHistory = [];
  List<Question> _categoryQuestions = [];
  bool _isLoading = true;
  Map<String, dynamic> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _category = args['category'] ?? '';
        _loadCategoryData();
      } else {
        // Handle case where category is not provided, e.g., navigate back
        Navigator.pop(context);
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadCategoryData() async {
    final user = UserSession.instance.currentUser;
    if (user != null) {
      try {
        // Load user's quiz history for this category
        final allHistory = await DatabaseService.instance
            .getUserQuizHistory(user.id); // Pass user.id as String
        final categoryHistory =
            allHistory.where((result) => result.category == _category).toList();

        // Load questions for this category
        final questions =
            await DatabaseService.instance.getQuestionsByCategory(_category);

        // Calculate category stats
        final stats = _calculateCategoryStats(categoryHistory);

        setState(() {
          _categoryHistory = categoryHistory;
          _categoryQuestions = questions;
          _categoryStats = stats;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading category data: $e');
        // Use dummy data if database fails
        setState(() {
          _categoryHistory = _getDummyHistory();
          _categoryQuestions = _getDummyQuestions();
          _categoryStats = _getDummyStats();
          _isLoading = false;
        });
      }
    } else {
      // Handle case where user is not logged in, e.g., navigate to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Map<String, dynamic> _calculateCategoryStats(List<QuizResult> history) {
    if (history.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestScore': 0,
        'totalTimeSpent': 0,
        'questionsAnswered': 0,
        'correctAnswers': 0,
      };
    }

    final totalQuizzes = history.length;
    final averageScore =
        history.map((r) => r.accuracy).reduce((a, b) => a + b) / totalQuizzes;
    final bestScore =
        history.map((r) => r.accuracy).reduce((a, b) => a > b ? a : b);
    final totalTimeSpent =
        history.map((r) => r.timeSpent).reduce((a, b) => a + b);
    final questionsAnswered =
        history.map((r) => r.totalQuestions).reduce((a, b) => a + b);
    final correctAnswers = history.map((r) => r.score).reduce((a, b) => a + b);

    return {
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'totalTimeSpent': totalTimeSpent,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
    };
  }

  List<QuizResult> _getDummyHistory() {
    return [
      QuizResult(
        id: 1,
        userId: 'dummy_user_id_1', // Dummy UUID
        score: 4,
        totalQuestions: 5,
        accuracy: 80.0,
        category: _category,
        gameMode: 'normal',
        timeSpent: 150,
        questionIds: [1, 2, 3, 4, 5],
        userAnswers: [0, 1, 2, 0, 1],
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      QuizResult(
        id: 2,
        userId: 'dummy_user_id_2', // Dummy UUID
        score: 3,
        totalQuestions: 5,
        accuracy: 60.0,
        category: _category,
        gameMode: 'normal',
        timeSpent: 180,
        questionIds: [6, 7, 8, 9, 10],
        userAnswers: [1, 0, 2, 1, 0],
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<Question> _getDummyQuestions() {
    return [
      Question(
        id: 1,
        question: 'Sample question for $_category?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 0,
        category: _category,
        subcategory: 'General',
        difficulty: 'medium',
        explanation: 'This is a sample explanation.',
      ),
    ];
  }

  Map<String, dynamic> _getDummyStats() {
    return {
      'totalQuizzes': 2,
      'averageScore': 70.0,
      'bestScore': 80.0,
      'totalTimeSpent': 330,
      'questionsAnswered': 10,
      'correctAnswers': 7,
    };
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
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
                          Expanded(
                            child: Text(
                              _category,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                                // Category Stats
                                _buildCategoryStats(),
                                const SizedBox(height: 30),
                                // Quiz History
                                _buildQuizHistory(),
                                const SizedBox(height: 30),
                                // Questions Preview
                                _buildQuestionsPreview(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getCategoryColor(_category),
            AppTheme.getCategoryColor(_category).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppTheme.getCategoryIcon(_category),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '$_category Statistics',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Quizzes Taken',
                  _categoryStats['totalQuizzes'].toString(),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Average Score',
                  '${_categoryStats['averageScore'].toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Best Score',
                  '${_categoryStats['bestScore'].toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Questions Answered',
                  _categoryStats['questionsAnswered'].toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildQuizHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz History',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_categoryHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No quizzes taken in this category yet.\nStart your first quiz!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ..._categoryHistory.map((result) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getScoreColor(result.accuracy).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${result.score}/${result.totalQuestions}',
                        style: TextStyle(
                          color: _getScoreColor(result.accuracy),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.accuracy.toStringAsFixed(1)}% Accuracy',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Completed in ${result.timeSpent}s • ${result.gameMode}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
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

  Widget _buildQuestionsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sample Questions',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/quiz',
                  arguments: {'category': _category},
                );
              },
              child: const Text(
                'Start Quiz',
                style: TextStyle(
                  color: AppTheme.electricBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_categoryQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No sample questions available for this category.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ..._categoryQuestions.take(3).map((question) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getCategoryColor(_category)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.difficulty.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.getCategoryColor(_category),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        question.subcategory,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Color _getScoreColor(double accuracy) {
    if (accuracy >= 80) return AppTheme.neonGreen;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
