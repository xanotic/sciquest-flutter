import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../utils/app_theme.dart';

void main() {
  runApp(const SciquestApp());
}

class SciquestApp extends StatelessWidget {
  const SciquestApp({super.key});

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
      },
    );
  }
}
