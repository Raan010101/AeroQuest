// import 'package:flutter/material.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1220),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [

//               const SizedBox(height: 20),

//               // Top Bar
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Icon(Icons.flight_takeoff, color: Colors.blue),
//                   Text(
//                     "AEROLEARN",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   Text(
//                     "Skip",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),

//               const Spacer(),

//               // Image
//               SizedBox(
//                 height: 240,
//                 child: Image.network(
//                   "https://lh3.googleusercontent.com/aida-public/AB6AXuAJ4RX209fo-So1Zt46y-3u3Ia3Exgs5LYX1J1sgIQmZZGIj8j6KCJPslhM6jfo3DcfzT3q0vFJZpRoI_9UExy1zJFHC7vTfRP1DKBhbcUGFVV5GCZCP9RY1BCy-XLwkvYwTmg2hmQ7b0VuyEj-iHL89C51WKs6RF2i-_ZxgklTHKmHiYvrIjhJeeH847_-uboZehJmXsKoZU03WyBbCnAl5QUCZMF-BJ29Yv87COivdDP0TWgdMFTpAEeL7QwQA37YcqINQwM94P8J",
//                   fit: BoxFit.contain,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               const Text(
//                 "Master the Skies",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               const Text(
//                 "Dive into complex aeronautical systems with interactive 3D models and expert-led engineering courses.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 14,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Dots indicator
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _dot(true),
//                   const SizedBox(width: 6),
//                   _dot(false),
//                   const SizedBox(width: 6),
//                   _dot(false),
//                 ],
//               ),

//               const SizedBox(height: 30),

//               // Get Started Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3F5EF8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/register");
//                   },
//                   child: const Text(
//                     "Get Started →",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Login text
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(context, "/login");
//                 },
//                 child: const Text.rich(
//                   TextSpan(
//                     text: "Already have an account? ",
//                     style: TextStyle(color: Colors.grey),
//                     children: [
//                       TextSpan(
//                         text: "Log In",
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _dot(bool active) {
//     return Container(
//       height: 6,
//       width: active ? 18 : 6,
//       decoration: BoxDecoration(
//         color: active ? Colors.blue : Colors.grey.shade700,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../core/routes.dart';
import 'liquid_silver_background.dart';
late AnimationController _controller;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _planeController;
  late Animation<double> _planePosition;

  late AnimationController _textController;
  late Animation<double> _textPosition;
  late Animation<double> _textOpacity;

  bool showButtons = false;

  @override
  void initState() {
    super.initState();

    // Plane animation (full screen rise)
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _planePosition = Tween<double>(
        begin: 0,
        end: -1.2,
      ).animate(
        CurvedAnimation(
          parent: _planeController,
          curve: Curves.easeInOutCubic,
        ),
      );

    // Text animation (rise from below)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textPosition = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    // Start sequence
    _planeController.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() => showButtons = true);
    });
  }

  @override
  void dispose() {
    _planeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          const LiquidSilverBackground(),

          Container(color: const Color(0x22000000)),

          // ✈️ FULL SCREEN AIRPLANE
          AnimatedBuilder(
            animation: _planePosition,
            builder: (context, child) {
              return FractionalTranslation(
                translation: Offset(0, _planePosition.value),
                child: SizedBox.expand(
                  child: Image.asset(
                    "assets/images/plane.png",
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // ✨ LOGO COMES FROM BELOW (BIG & PREMIUM)
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textPosition.value),
                        child: Align(
                          alignment: const Alignment(0, -0.05),
                          child: FractionallySizedBox(
                            widthFactor: 0.95,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "EDUCATION. REVOLUTION.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 3,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

          // 🚀 BUTTONS
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showButtons ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [

                  SizedBox(
                    width: 240,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B1220),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.login);
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: 240,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.register);
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}