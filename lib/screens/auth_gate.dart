import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'lecturer_dashboard.dart';
import 'splash_screen.dart';
import 'student/student_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  Session? _session;

  @override
  void initState() {
    super.initState();

    // initial session
    _session = supabase.auth.currentSession;

    // listen for changes
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() => _session = data.session);
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    final res = await supabase
        .from('profiles')
        .select('id, name, id_number, role')
        .eq('id', userId)
        .maybeSingle();

    if (res != null) return res;

    // If profile is missing, create a minimal one.
    // (This is just a safety net. Your Register screen should normally create it.)
    final user = supabase.auth.currentUser!;
    final inserted = await supabase
        .from('profiles')
        .insert({
          'id': userId,
          'role': 'student',
          'name': user.userMetadata?['full_name'] ?? 'Student',
          // keep email internal if you still store it in profiles:
          'email': user.email,
        })
        .select('id, name, id_number, role')
        .single();

    return inserted;
  }

  @override
  Widget build(BuildContext context) {
    // If no session -> show splash
    if (_session == null) {
      return const SplashScreen();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getProfile(_session!.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SessionLoadingScreen();
        }

        // If profile load fails, session is invalid -> sign out
        if (snapshot.hasError || !snapshot.hasData) {
          supabase.auth.signOut();
          return const SplashScreen();
        }

        final profile = snapshot.data!;
        final role = (profile['role'] ?? 'student').toString();

        // ✅ Role lock
        if (role == 'lecturer') {
          return const LecturerDashboard();
        }

        if (role == 'student') {
          return StudentShell(
            name: (profile['name'] ?? 'Student').toString(),
            idNumber: (profile['id_number'] ?? '').toString(),
            role: role,
          );
        }

        // Unknown role -> sign out
        supabase.auth.signOut();
        return const SplashScreen();
      },
    );
  }
}

class _SessionLoadingScreen extends StatelessWidget {
  const _SessionLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}