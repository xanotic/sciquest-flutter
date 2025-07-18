import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/audio_service.dart';
import '../widgets/animated_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.instance.currentUser;

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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/profile'),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: AppTheme.electricBlue,
                                child: Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    user?.name ?? 'User',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Notifications
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppTheme.textPrimary,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Progress Card
                        _buildProgressCard(),
                        const SizedBox(height: 30),
                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedButton(
                                text: 'Start Quiz',
                                onPressed: () {
                                  AudioService.instance.playButtonTap();
                                  Navigator.pushNamed(context, '/quiz');
                                },
                                icon: Icons.play_arrow,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  AudioService.instance.playButtonTap();
                                  Navigator.pushNamed(context, '/game-mode');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppTheme.electricBlue),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Game Modes',
                                  style: TextStyle(
                                    color: AppTheme.electricBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Categories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/progress'),
                              child: const Text(
                                'View Progress',
                                style: TextStyle(color: AppTheme.electricBlue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildCategoryCard(
                                'Mathematics',
                                Icons.calculate,
                                AppTheme.mathematicsColor,
                                85,
                              ),
                              _buildCategoryCard(
                                'Physics',
                                Icons.science,
                                AppTheme.physicsColor,
                                72,
                              ),
                              _buildCategoryCard(
                                'Chemistry',
                                Icons.biotech,
                                AppTheme.chemistryColor,
                                91,
                              ),
                              _buildCategoryCard(
                                'Biology',
                                Icons.eco,
                                AppTheme.biologyColor,
                                68,
                              ),
                              _buildCategoryCard(
                                'Computer Science',
                                Icons.computer,
                                AppTheme.computerScienceColor,
                                78,
                              ),
                              _buildCategoryCard(
                                'Engineering',
                                Icons.engineering,
                                AppTheme.engineeringColor,
                                82,
                              ),
                            ],
                          ),
                        ),
                        // Leaderboard Preview
                        _buildLeaderboardPreview(),
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

  Widget _buildProgressCard() {
    final user = UserSession.instance.currentUser;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/progress'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.electricBlue, AppTheme.softPurple],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.totalScore ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Points Earned',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.quizzesCompleted ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Quizzes Completed',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.accuracy.toStringAsFixed(1) ?? '0.0'}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Accuracy',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, IconData icon, Color color, int progress) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.playButtonTap();
        Navigator.pushNamed(
          context,
          '/category-detail',
          arguments: {'category': title},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$progress% Complete',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/leaderboard'),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.leaderboard, color: AppTheme.neonGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.neonGreen,
                  child: Text('1',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'See where you rank this week!',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: AppTheme.electricBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
