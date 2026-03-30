import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DataPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("MERAPI |", style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text(
              "VOLKANIK AKTIFITAS MONITOR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Real-time Volcano Monitoring",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
