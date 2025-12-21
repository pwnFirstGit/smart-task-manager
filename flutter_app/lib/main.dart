import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/task_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SmartTaskManagerApp(),
    ),
  );
}

class SmartTaskManagerApp extends StatelessWidget {
  const SmartTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const TaskDashboardScreen(),
    );
  }
}
