import 'package:flutter/material.dart';
import '../../core/routes.dart';
import 'liquid_silver_background.dart';

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
                                  "One Day or Day One.",
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