import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/game_mode_screen.dart';
import 'utils/app_theme.dart';
import 'services/database_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Update the Supabase initialization with your remote URL and Anon Key
  // Replace 'YOUR_REMOTE_SUPABASE_ANON_KEY' with the actual key from your Supabase dashboard.
  await Supabase.initialize(
    url: 'https://hcznjnvscpwbksprzuyl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhjem5qbnZzY3B3YmtzcHJ6dXlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4MTIzODYsImV4cCI6MjA2ODM4ODM4Nn0.cKDsVWRbJUbtpxGrIVafGklaCWUP0glsdjutvBd_bv8', // <-- PASTE YOUR REMOTE SUPABASE ANON KEY HERE
  );

  await AudioService.instance.initialize();
  runApp(const SciquestApp());
}

class SciquestApp extends StatelessWidget {
  const SciquestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Sciquest: STEM Challenge',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/result': (context) => const ResultScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/category-detail': (context) => const CategoryDetailScreen(),
        '/game-mode': (context) => const GameModeScreen(),
      },
    );
  }
}
