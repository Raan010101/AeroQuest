import 'package:flutter/material.dart';
import '../screens/auth_gate.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/qr_scan_screen.dart';
import '../screens/quest_detail_screen.dart';
import '../screens/streak_screen.dart';
class AppRoutes {
  static const String root = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String qrScan = "/qr-scan";
  static const String questDetail = "/quest-detail";
  static const String quests = "/quests";
    static const String learn = "/learn";
    static const String streak = "/streak";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthGate());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case qrScan:
        return MaterialPageRoute(builder: (_) => const QRScanScreen());

      case questDetail:
        final quest = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestDetailScreen(quest: quest),
        );
        
      case streak:
        return MaterialPageRoute(builder: (_) => const StreakScreen());

      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}