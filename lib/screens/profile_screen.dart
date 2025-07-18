import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/user_session.dart';
import '../services/database_service.dart';
import '../models/user.dart';
import '../widgets/animated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserSession.instance.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first')),
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
                    const Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.close : Icons.edit,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.electricBlue,
                  child: user.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            user.avatar!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                // User Info
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoCard(
                          'Name',
                          _nameController,
                          Icons.person,
                          _isEditing,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          'Email',
                          _emailController,
                          Icons.email,
                          _isEditing,
                        ),
                        const SizedBox(height: 30),
                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Score',
                                user.totalScore.toString(),
                                Icons.star,
                                AppTheme.neonGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Quizzes',
                                user.quizzesCompleted.toString(),
                                Icons.quiz,
                                AppTheme.electricBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Accuracy',
                                '${user.accuracy.toStringAsFixed(1)}%',
                                Icons.track_changes,
                                AppTheme.softPurple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Member Since',
                                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                                Icons.calendar_today,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        if (_isEditing)
                          AnimatedButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                          ),
                        const SizedBox(height: 16),
                        // Logout Button
                        OutlinedButton(
                          onPressed: _logout,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  Widget _buildInfoCard(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditing,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.electricBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        controller.text,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    final user = UserSession.instance.currentUser;
    if (user != null) {
      final updatedUser = User(
        id: user.id,
        name: _nameController.text,
        email: _emailController.text,
        avatar: user.avatar,
        totalScore: user.totalScore,
        quizzesCompleted: user.quizzesCompleted,
        accuracy: user.accuracy,
        createdAt: user.createdAt,
      );

      final success =
          await DatabaseService.instance.updateUserProfile(updatedUser);
      if (success) {
        UserSession.instance.setUser(updatedUser);
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  void _logout() {
    UserSession.instance.clearUser();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
