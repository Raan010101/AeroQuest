import 'package:flutter/material.dart';
import '../screens/student/student_dashboard_home.dart';
import '../screens/auth_gate.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
class AppRoutes {
  static const String login = "/login";
  static const String register = "/register";
  static const String dashboardHome = "/dashboard-home";

static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());

    case register:
      return MaterialPageRoute(builder: (_) => const RegisterScreen());

    case dashboardHome:
      return MaterialPageRoute(
        builder: (_) => const StudentDashboardScreen(),
      );

    default:
      return MaterialPageRoute(builder: (_) => const AuthGate());
  }
}
}