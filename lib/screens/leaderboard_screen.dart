import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/database_service.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  String _selectedPeriod = 'all_time';

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

    _loadLeaderboard();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadLeaderboard() async {
    try {
      final leaderboard =
          await DatabaseService.instance.getLeaderboard(limit: 50);
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      // If database fails, use dummy data
      setState(() {
        _leaderboard = _getDummyLeaderboard();
        _isLoading = false;
      });
    }
  }

  List<LeaderboardEntry> _getDummyLeaderboard() {
    return [
      LeaderboardEntry(
          rank: 1,
          userId: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
          userName: 'Alex Johnson',
          totalScore: 2450,
          quizzesCompleted: 35,
          accuracy: 87.5),
      LeaderboardEntry(
          rank: 2,
          userId: 'b2c3d4e5-f6a7-8901-2345-67890abcdef0',
          userName: 'Sarah Chen',
          totalScore: 2380,
          quizzesCompleted: 32,
          accuracy: 89.2),
      LeaderboardEntry(
          rank: 3,
          userId: 'c3d4e5f6-a7b8-9012-3456-7890abcdef01',
          userName: 'Mike Rodriguez',
          totalScore: 2290,
          quizzesCompleted: 28,
          accuracy: 85.1),
      LeaderboardEntry(
          rank: 4,
          userId: 'd4e5f6a7-b8c9-0123-4567-890abcdef012',
          userName: 'Emma Wilson',
          totalScore: 2150,
          quizzesCompleted: 30,
          accuracy: 82.3),
      LeaderboardEntry(
          rank: 5,
          userId: 'e5f6a7b8-c9d0-1234-5678-90abcdef0123',
          userName: 'David Kim',
          totalScore: 2050,
          quizzesCompleted: 25,
          accuracy: 88.7),
      LeaderboardEntry(
          rank: 6,
          userId: 'f6a7b8c9-d0e1-2345-6789-0abcdef01234',
          userName: 'Lisa Wang',
          totalScore: 1980,
          quizzesCompleted: 22,
          accuracy: 84.6),
      LeaderboardEntry(
          rank: 7,
          userId: 'a7b8c9d0-e1f2-3456-7890-abcdef012345',
          userName: 'John Smith',
          totalScore: 1850,
          quizzesCompleted: 20,
          accuracy: 81.2),
      LeaderboardEntry(
          rank: 8,
          userId: 'b8c9d0e1-f2a3-4567-8901-bcdef0123456',
          userName: 'Maria Garcia',
          totalScore: 1720,
          quizzesCompleted: 18,
          accuracy: 86.3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserSession.instance.currentUser;

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
                          const Expanded(
                            child: Text(
                              'Leaderboard',
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
                      const SizedBox(height: 20),
                      // Period Selector
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      // Top 3 Podium
                      if (!_isLoading &&
                          _leaderboard.isNotEmpty &&
                          _leaderboard.length >= 3)
                        _buildPodium(),
                      const SizedBox(height: 30),
                      // Leaderboard List
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.electricBlue,
                                ),
                              )
                            : _buildLeaderboardList(),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildPeriodTab('All Time', 'all_time'),
          _buildPeriodTab('This Week', 'week'),
          _buildPeriodTab('This Month', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String title, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            // In a real app, you'd reload leaderboard data based on the period
            // For now, this is just UI state.
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.electricBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    // Ensure there are at least 3 entries for the podium
    if (_leaderboard.length < 3) return const SizedBox();

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumPlace(_leaderboard[1], 2, 140, AppTheme.textSecondary),
          const SizedBox(width: 16),
          // 1st Place
          _buildPodiumPlace(_leaderboard[0], 1, 180, AppTheme.neonGreen),
          const SizedBox(width: 16),
          // 3rd Place
          _buildPodiumPlace(_leaderboard[2], 3, 120, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
      LeaderboardEntry entry, int place, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: place == 1 ? 35 : 30,
          backgroundColor: color,
          child: entry.userAvatar != null
              ? ClipOval(
                  child: Image.network(
                    entry.userAvatar!,
                    width: place == 1 ? 70 : 60,
                    height: place == 1 ? 70 : 60,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  entry.userName.isNotEmpty
                      ? entry.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: place == 1 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.userName.split(' ')[0],
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${entry.totalScore} pts',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                place == 1 ? Icons.emoji_events : Icons.military_tech,
                color: Colors.white,
                size: place == 1 ? 32 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                '#$place',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    final currentUser = UserSession.instance.currentUser;

    return ListView.builder(
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        final isCurrentUser =
            currentUser != null && entry.userId == currentUser.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppTheme.electricBlue.withOpacity(0.1)
                : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: isCurrentUser
                ? Border.all(color: AppTheme.electricBlue, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(entry.rank).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      color: _getRankColor(entry.rank),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.electricBlue,
                child: entry.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          entry.userAvatar!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        entry.userName.isNotEmpty
                            ? entry.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.userName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.electricBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.quizzesCompleted} quizzes • ${entry.accuracy.toStringAsFixed(1)}% accuracy',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.totalScore}',
                    style: TextStyle(
                      color: _getRankColor(entry.rank),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.neonGreen;
      case 2:
        return AppTheme.textSecondary;
      case 3:
        return Colors.orange;
      default:
        return AppTheme.electricBlue;
    }
  }
}
