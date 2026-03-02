import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gradient_background.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> signUp() async {
    setState(() => loading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'full_name': fullNameController.text.trim(),
        },
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
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

                          TextField(
                            controller: fullNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Full Name",
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor:
                                  Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor:
                                  Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor:
                                  Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
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
                                foregroundColor:
                                    const Color(0xFF0B1220),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: loading ? null : signUp,
                              child: loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Register",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Already have an account? Login",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
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
}} //test