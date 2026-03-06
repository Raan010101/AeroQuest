import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gradient_background.dart';
import 'auth_gate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  String roleValue = "student";
  bool loading = false;

  String _emailFromId(String idNo) => "${idNo.trim()}@aeroquest.local";

  Future<void> signUp() async {
    final fullName = fullNameController.text.trim();
    final idNo = idController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty || idNo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1) Create auth user using "fake email" based on ID number
      final authRes = await supabase.auth.signUp(
        email: _emailFromId(idNo),
        password: password,
      );

      final user = authRes.user;
      if (user == null) {
        throw Exception("Registration failed. Please try again.");
      }

      // 2) Store extra fields in profiles
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': _emailFromId(idNo),
        'name': fullName,
        'id_number': idNo,
        'role': roleValue,
      });

      if (!mounted) return;

      // Go to AuthGate (it will route to correct dashboard)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuthGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/icon-logo.png",
                        width: 70,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Full Name
                            TextField(
                              controller: fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Full Name",
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // ID Number
                            TextField(
                              controller: idController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "ID Number",
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Role dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: roleValue,
                                  dropdownColor: const Color(0xFF0B1220),
                                  iconEnabledColor: Colors.white70,
                                  style: const TextStyle(color: Colors.white),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "student",
                                      child: Text("Student"),
                                    ),
                                    DropdownMenuItem(
                                      value: "lecturer",
                                      child: Text("Lecturer"),
                                    ),
                                  ],
                                  onChanged: loading
                                      ? null
                                      : (v) {
                                          if (v == null) return;
                                          setState(() => roleValue = v);
                                        },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Password
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0B1220),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                onPressed: loading ? null : signUp,
                                child: loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        "Register",
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            TextButton(
                              onPressed: loading ? null : () => Navigator.pop(context),
                              child: const Text(
                                "Already have an account? Login",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}