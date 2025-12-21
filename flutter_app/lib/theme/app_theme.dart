import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1976D2); // Deep Blue
  static const Color secondaryColor = Color(0xFF00897B); // Teal
  static const Color errorColor = Color(0xFFD32F2F); // Red
  
  // Category colors
  static const Color schedulingColor = Color(0xFF7C4DFF); // Purple
  static const Color financeColor = Color(0xFF00C853); // Green
  static const Color technicalColor = Color(0xFFFF6F00); // Orange
  static const Color safetyColor = Color(0xFFD32F2F); // Red
  static const Color generalColor = Color(0xFF757575); // Grey
  
  // Priority colors
  static const Color highPriorityColor = Color(0xFFD32F2F); // Red
  static const Color mediumPriorityColor = Color(0xFFFF6F00); // Orange
  static const Color lowPriorityColor = Color(0xFF388E3C); // Green
  
  // Status colors
  static const Color pendingColor = Color(0xFFFF6F00); // Orange
  static const Color inProgressColor = Color(0xFF1976D2); // Blue
  static const Color completedColor = Color(0xFF388E3C); // Green

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'scheduling':
        return schedulingColor;
      case 'finance':
        return financeColor;
      case 'technical':
        return technicalColor;
      case 'safety':
        return safetyColor;
      default:
        return generalColor;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return highPriorityColor;
      case 'medium':
        return mediumPriorityColor;
      default:
        return lowPriorityColor;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'in_progress':
        return inProgressColor;
      default:
        return completedColor;
    }
  }

  static IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.low_priority;
      default:
        return Icons.arrow_downward;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.play_circle_outline;
      default:
        return Icons.check_circle;
    }
  }
}
