import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AeroQuestApp());
}

class AeroQuestApp extends StatelessWidget {
  const AeroQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}