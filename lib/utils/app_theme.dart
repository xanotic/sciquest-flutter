import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBackground = Color(0xFF0A0E27);
  static const Color secondaryBackground = Color(0xFF1A1F3A);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color softPurple = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3B8);
  static const Color cardBackground = Color(0xFF1E2139);

  // Category Colors
  static const Color mathematicsColor = Color(0xFF8B5CF6);
  static const Color physicsColor = Color(0xFF00D4FF);
  static const Color chemistryColor = Color(0xFF39FF14);
  static const Color biologyColor = Color(0xFFFF6B35);
  static const Color computerScienceColor = Color(0xFFFF1744);
  static const Color engineeringColor = Color(0xFFFFD700);
  static const Color earthScienceColor = Color(0xFF4CAF50);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: primaryBackground,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: primaryBackground,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mathematics':
        return mathematicsColor;
      case 'physics':
        return physicsColor;
      case 'chemistry':
        return chemistryColor;
      case 'biology':
        return biologyColor;
      case 'computer science':
        return computerScienceColor;
      case 'engineering':
        return engineeringColor;
      case 'earth science':
        return earthScienceColor;
      default:
        return electricBlue;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.biotech;
      case 'biology':
        return Icons.eco;
      case 'computer science':
        return Icons.computer;
      case 'engineering':
        return Icons.engineering;
      case 'earth science':
        return Icons.public;
      default:
        return Icons.quiz;
    }
  }
}
