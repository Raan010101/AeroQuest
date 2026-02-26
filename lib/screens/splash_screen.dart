import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1220),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 20),

              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.flight_takeoff, color: Colors.blue),
                  Text(
                    "AEROLEARN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "Skip",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              // Image
              SizedBox(
                height: 240,
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAJ4RX209fo-So1Zt46y-3u3Ia3Exgs5LYX1J1sgIQmZZGIj8j6KCJPslhM6jfo3DcfzT3q0vFJZpRoI_9UExy1zJFHC7vTfRP1DKBhbcUGFVV5GCZCP9RY1BCy-XLwkvYwTmg2hmQ7b0VuyEj-iHL89C51WKs6RF2i-_ZxgklTHKmHiYvrIjhJeeH847_-uboZehJmXsKoZU03WyBbCnAl5QUCZMF-BJ29Yv87COivdDP0TWgdMFTpAEeL7QwQA37YcqINQwM94P8J",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Master the Skies",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Dive into complex aeronautical systems with interactive 3D models and expert-led engineering courses.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(true),
                  const SizedBox(width: 6),
                  _dot(false),
                  const SizedBox(width: 6),
                  _dot(false),
                ],
              ),

              const SizedBox(height: 30),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F5EF8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: const Text(
                    "Get Started →",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login text
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dot(bool active) {
    return Container(
      height: 6,
      width: active ? 18 : 6,
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}