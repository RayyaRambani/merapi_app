import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🔥 BACKGROUND MERAH MENYALA (clean)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A0000),
              Color(0xFF8B0000),
              Color(0xFFB22222),
              Color(0xFFFF3B3B),
            ],
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 LOGO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset("assets/images/merapinobg.png", width: 200),
              ),

              const SizedBox(height: 30),

              // 🔴 TITLE (Orbitron)
              Text(
                "VOLCANIC SURVEILLANCE",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // ⚙️ SUBTITLE (Rajdhani)
              Text(
                "REAL-TIME DATA • IOT • LORA",
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
