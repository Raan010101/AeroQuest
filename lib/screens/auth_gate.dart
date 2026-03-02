import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_dashboard.dart';
import 'lecturer_dashboard.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    if (session == null) {
      return const SplashScreen();
    }

    return FutureBuilder(
      future: supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data as Map<String, dynamic>;

        if (profile['role'] == 'lecturer') {
          return const LecturerDashboard();
        } else {
          return const StudentDashboard();
        }
      },
    );
  }
}