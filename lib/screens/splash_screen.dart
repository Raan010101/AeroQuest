import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 20),

                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF135BEC).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        color: Color(0xFF135BEC),
                      ),
                    ),
                    Text(
                      "AeroQuest",
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Skip",
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 40),

                // Engine Image Section
                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF135BEC).withOpacity(0.2),
                          ),
                        ),
                      ),
                      Image.network(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuAJ4RX209fo-So1Zt46y-3u3Ia3Exgs5LYX1J1sgIQmZZGIj8j6KCJPslhM6jfo3DcfzT3q0vFJZpRoI_9UExy1zJFHC7vTfRP1DKBhbcUGFVV5GCZCP9RY1BCy-XLwkvYwTmg2hmQ7b0VuyEj-iHL89C51WKs6RF2i-_ZxgklTHKmHiYvrIjhJeeH847_-uboZehJmXsKoZU03WyBbCnAl5QUCZMF-BJ29Yv87COivdDP0TWgdMFTpAEeL7QwQA37YcqINQwM94P8J",
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  "Track Your Flight Journey",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  "Log hours. Complete training modules. Progress toward your license with confidence.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 60),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF135BEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // We'll connect navigation next
                    },
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Already have an account? Log In",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}