import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({Key? key}) : super(key: key);

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
                        'Game Modes',
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
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildGameModeCard(
                        context,
                        'Science Only',
                        'Physics, Chemistry, Biology',
                        Icons.science,
                        AppTheme.neonGreen,
                        'science',
                      ),
                      _buildGameModeCard(
                        context,
                        'Math Focus',
                        'Algebra, Calculus, Statistics',
                        Icons.calculate,
                        AppTheme.mathematicsColor,
                        'mathematics',
                      ),
                      _buildGameModeCard(
                        context,
                        'Tech Challenge',
                        'Computer Science & Engineering',
                        Icons.computer,
                        AppTheme.computerScienceColor,
                        'technology',
                      ),
                      _buildGameModeCard(
                        context,
                        'Mixed STEM',
                        'All categories combined',
                        Icons.quiz,
                        AppTheme.electricBlue,
                        'mixed',
                      ),
                      _buildGameModeCard(
                        context,
                        'Quick Fire',
                        '30 seconds per question',
                        Icons.timer,
                        Colors.orange,
                        'quickfire',
                      ),
                      _buildGameModeCard(
                        context,
                        'Expert Mode',
                        'Advanced level questions',
                        Icons.emoji_events,
                        AppTheme.softPurple,
                        'expert',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String mode,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/quiz',
          arguments: {'gameMode': mode},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
