import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _questionController;
  late AnimationController _timerController;
  late Animation<double> _questionAnimation;
  late Animation<double> _timerAnimation;

  int currentQuestion = 0;
  int selectedAnswer = -1;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  List<Question> questions = [];
  List<int> userAnswers = [];
  bool _isLoading = true;
  String gameMode = 'normal';
  String category = 'Mixed';
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeInOut),
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        gameMode = args['gameMode'] ?? 'normal';
        category = args['category'] ?? 'Mixed';
      }
      _loadQuestions();
    });
  }

  void _loadQuestions() async {
    try {
      List<Question> loadedQuestions;
      if (category != 'Mixed') {
        loadedQuestions =
            await DatabaseService.instance.getQuestionsByCategory(category);
      } else {
        loadedQuestions = await DatabaseService.instance
            .getRandomQuestions(5, gameMode: gameMode);
      }

      if (loadedQuestions.isEmpty) {
        // Use dummy questions if database fails or no questions found
        loadedQuestions = _getDummyQuestions();
      }

      setState(() {
        questions = loadedQuestions;
        userAnswers = List.filled(loadedQuestions.length, -1);
        _isLoading = false;
      });

      _startQuestion();
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        questions = _getDummyQuestions();
        userAnswers = List.filled(questions.length, -1);
        _isLoading = false;
      });
      _startQuestion();
    }
  }

  List<Question> _getDummyQuestions() {
    return [
      Question(
        id: 1,
        question: 'What is the chemical symbol for gold?',
        options: ['Go', 'Gd', 'Au', 'Ag'],
        correctAnswer: 2,
        category: 'Chemistry',
        subcategory: 'Periodic Table',
        difficulty: 'easy',
        explanation: 'Au comes from the Latin word "aurum" meaning gold.',
      ),
      Question(
        id: 2,
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        category: 'Physics',
        subcategory: 'Astronomy',
        difficulty: 'easy',
        explanation:
            'Mars appears red due to iron oxide (rust) on its surface.',
      ),
      Question(
        id: 3,
        question: 'What is the derivative of x² + 3x + 2?',
        options: ['2x + 3', 'x + 3', '2x + 2', 'x² + 3'],
        correctAnswer: 0,
        category: 'Mathematics',
        subcategory: 'Calculus',
        difficulty: 'medium',
        explanation:
            'The derivative of x² is 2x, derivative of 3x is 3, and derivative of constant 2 is 0.',
      ),
      Question(
        id: 4,
        question: 'What is the largest bone in the human body?',
        options: ['Humerus', 'Tibia', 'Femur', 'Fibula'],
        correctAnswer: 2,
        category: 'Biology',
        subcategory: 'Anatomy',
        difficulty: 'easy',
        explanation:
            'The femur (thigh bone) is the longest and strongest bone in the human body.',
      ),
      Question(
        id: 5,
        question: 'What is the time complexity of binary search?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctAnswer: 1,
        category: 'Computer Science',
        subcategory: 'Algorithms',
        difficulty: 'medium',
        explanation:
            'Binary search has O(log n) time complexity as it eliminates half the search space in each iteration.',
      ),
    ];
  }

  void _startQuestion() {
    _questionController.forward();
    _timerController.forward();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timeLeft = gameMode == 'quickfire' ? 15 : 30;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(int index) {
    if (selectedAnswer != -1) return;

    AudioService.instance.playButtonTap();

    setState(() {
      selectedAnswer = index;
      userAnswers[currentQuestion] = index;
    });

    if (index == questions[currentQuestion].correctAnswer) {
      score++;
      AudioService.instance.playCorrectAnswer();
    } else {
      AudioService.instance.playWrongAnswer();
    }

    timer?.cancel();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = -1;
      });
      _questionController.reset();
      _timerController.reset();
      _startQuestion();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    AudioService.instance.playQuizComplete();

    final user = UserSession.instance.currentUser;
    if (user != null) {
      final result = QuizResult(
        userId: user.id, // Pass user.id as String
        score: score,
        totalQuestions: questions.length,
        accuracy: (score / questions.length * 100),
        category: category,
        gameMode: gameMode,
        timeSpent: DateTime.now().difference(startTime).inSeconds,
        questionIds: questions.map((q) => q.id).toList(),
        userAnswers: userAnswers,
        completedAt: DateTime.now(),
      );

      await DatabaseService.instance.saveQuizResult(result);
    }

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'score': score,
        'total': questions.length,
        'percentage': (score / questions.length * 100).round(),
        'questions': questions
            .map((q) => q.toJson())
            .toList(), // Convert Question objects to JSON maps
        'userAnswers': userAnswers,
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _questionController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.electricBlue),
        ),
      );
    }

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
                    Expanded(
                      child: Text(
                        'Question ${currentQuestion + 1}/${questions.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Timer
                AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _timerAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.neonGreen,
                                _timerAnimation.value > 0.3
                                    ? AppTheme.electricBlue
                                    : Colors.red,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${timeLeft}s',
                  style: TextStyle(
                    color: timeLeft > 10 ? AppTheme.neonGreen : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Question
                AnimatedBuilder(
                  animation: _questionAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _questionAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_questionAnimation),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getCategoryColor(
                                              questions[currentQuestion]
                                                  .category)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      questions[currentQuestion].category,
                                      style: TextStyle(
                                        color: AppTheme.getCategoryColor(
                                            questions[currentQuestion]
                                                .category),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    questions[currentQuestion]
                                        .difficulty
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                questions[currentQuestion].question,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Options
                Expanded(
                  child: AnimatedBuilder(
                    animation: _questionAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _questionAnimation,
                        child: ListView.builder(
                          itemCount: questions[currentQuestion].options.length,
                          itemBuilder: (context, index) {
                            return _buildOptionCard(index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = selectedAnswer == index;
    final isCorrect = index == questions[currentQuestion].correctAnswer;
    final showResult = selectedAnswer != -1;

    Color cardColor = AppTheme.cardBackground;
    Color borderColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;

    if (showResult) {
      if (isCorrect) {
        cardColor = AppTheme.neonGreen.withOpacity(0.2);
        borderColor = AppTheme.neonGreen;
      } else if (isSelected) {
        cardColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      cardColor = AppTheme.electricBlue.withOpacity(0.2);
      borderColor = AppTheme.electricBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor != Colors.transparent
                      ? borderColor
                      : AppTheme.textSecondary.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: borderColor != Colors.transparent
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  questions[currentQuestion].options[index],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showResult && isCorrect)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.neonGreen,
                  size: 24,
                ),
              if (showResult && isSelected && !isCorrect)
                const Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
