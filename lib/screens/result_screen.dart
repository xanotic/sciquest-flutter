import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_button.dart';
import '../models/question.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scoreController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final score = args?['score'] ?? 0;
    final total = args?['total'] ?? 3;
    final percentage = args?['percentage'] ?? 0;
    final List<Question> questions = (args?['questions'] as List<dynamic>?)
            ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final List<int> userAnswers = (args?['userAnswers'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

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
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Result Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: percentage >= 70
                                  ? [AppTheme.neonGreen, AppTheme.electricBlue]
                                  : percentage >= 50
                                      ? [Colors.orange, Colors.yellow]
                                      : [Colors.red, Colors.pink],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (percentage >= 70
                                        ? AppTheme.neonGreen
                                        : percentage >= 50
                                            ? Colors.orange
                                            : Colors.red)
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            percentage >= 70
                                ? Icons.emoji_events
                                : percentage >= 50
                                    ? Icons.thumb_up
                                    : Icons.refresh,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          percentage >= 70
                              ? 'Excellent!'
                              : percentage >= 50
                                  ? 'Good Job!'
                                  : 'Keep Trying!',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          percentage >= 70
                              ? 'Outstanding performance!'
                              : percentage >= 50
                                  ? 'You\'re on the right track!'
                                  : 'Practice makes perfect!',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Score Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Animated Score
                              AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${(score * _scoreAnimation.value).round()}/$total',
                                    style: TextStyle(
                                      color: percentage >= 70
                                          ? AppTheme.neonGreen
                                          : percentage >= 50
                                              ? Colors.orange
                                              : Colors.red,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const Text(
                                'Correct Answers',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Percentage
                              AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${(percentage * _scoreAnimation.value).round()}%',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                              const Text(
                                'Accuracy',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Feedback
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.electricBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppTheme.electricBlue,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getFeedback(percentage),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/quiz');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppTheme.electricBlue),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: AppTheme.electricBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedButton(
                                text: 'Next Challenge',
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getFeedback(int percentage) {
    if (percentage >= 90) {
      return 'Perfect! You have mastered this topic. Ready for more advanced challenges?';
    } else if (percentage >= 70) {
      return 'Great work! You have a solid understanding. Keep practicing to perfect your skills.';
    } else if (percentage >= 50) {
      return 'Good effort! Review the topics you missed and try again to improve your score.';
    } else {
      return 'Don\'t give up! Learning takes time. Review the material and practice more.';
    }
  }
}
