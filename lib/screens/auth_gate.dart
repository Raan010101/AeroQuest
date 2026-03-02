import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'student_modules_screen.dart';
import 'lecturer_dashboard.dart';
import 'splash_screen.dart';
import 'login_screen.dart'; // <-- change this to your real file

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  Session? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // initial session
    _session = supabase.auth.currentSession;
    _loading = false;

    // listen for changes
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    // Trigger creates profiles, but just in case it didn't:
    final res = await supabase.from('profiles').select().eq('id', userId).maybeSingle();

    if (res != null) return res;

    // Create minimal profile if missing (RLS allows insert own)
    final user = supabase.auth.currentUser!;
    final inserted = await supabase
        .from('profiles')
        .insert({
          'id': userId,
          'email': user.email,
          'role': 'student',
        })
        .select()
        .single();

    return inserted;
  }

@override
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
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // 🔥 If profile load fails, session is invalid -> sign out
      if (snapshot.hasError) {
        supabase.auth.signOut();
        return const SplashScreen();
      }

      if (!snapshot.hasData) {
        supabase.auth.signOut();
        return const SplashScreen();
      }

      final profile = snapshot.data!;
      final role = (profile['role'] ?? 'student') as String;

      if (role == 'lecturer') return const LecturerDashboard();
      return const StudentDashboard();
    },
  );
}}