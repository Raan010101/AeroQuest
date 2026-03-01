import 'dart:math';
import 'package:flutter/material.dart';

class LiquidSilverBackground extends StatefulWidget {
  const LiquidSilverBackground({super.key});

  @override
  State<LiquidSilverBackground> createState() => _LiquidSilverBackgroundState();
}

class _LiquidSilverBackgroundState extends State<LiquidSilverBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 2 * pi;

        // Two layers to feel more "liquid wave" and less flat
        return Stack(
          children: [
            // Base dark chrome
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B1220),
                    Color(0xFF0F172A),
                    Color(0xFF111827),
                    Color(0xFF0B1220),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Moving silver wave highlight
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0x00FFFFFF),
                    Color(0x33E5E7EB),
                    Color(0x88F8FAFC),
                    Color(0x33CBD5E1),
                    Color(0x00FFFFFF),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  begin: Alignment(sin(t) * 1.0, -1),
                  end: Alignment(-sin(t) * 1.0, 1),
                ),
              ),
            ),

            // Subtle second wave (different speed/angle)
            Opacity(
              opacity: 0.55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0x00FFFFFF),
                      Color(0x22FFFFFF),
                      Color(0x66D1D5DB),
                      Color(0x22FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    begin: Alignment(cos(t * 0.8) * 1.0, -1),
                    end: Alignment(-cos(t * 0.8) * 1.0, 1),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}