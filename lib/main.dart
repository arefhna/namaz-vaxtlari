import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NamazApp());
}

class NamazApp extends StatelessWidget {
  const NamazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namaz Vaxtları',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
