import 'package:flutter/material.dart';

class VolcanoAnalyzer {
  // ================= STATUS =================
  static String getStatus({
    required double temp,
    required double gas,
    required double pressure,
    required double prevTemp,
    required double prevGas,
    required double prevPressure,
  }) {
    // 🔴 1. NILAI EKSTRIM (langsung danger)
    if (temp > 150 || gas > 300 || pressure > 1200) {
      return "DANGER";
    }

    // ⚠️ 2. NILAI MENENGAH
    if (temp > 70 || gas > 100 || pressure < 900) {
      return "SIAGA";
    }

    // 🟡 3. TREND (baru pakai kenaikan)
    bool tempUp = temp > prevTemp;
    bool gasUp = gas > prevGas;

    if (tempUp && gasUp) {
      return "WASPADA";
    }

    // ✅ 4. AMAN
    return "SAFE";
  }

  // ================= COLOR =================
  static Color getColor(String status) {
    switch (status) {
      case "SAFE":
        return Colors.green;
      case "WASPADA":
        return Colors.yellow;
      case "SIAGA":
        return Colors.orange;
      case "DANGER":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================= ANALYSIS =================
  static String getAnalysis({
    required double temp,
    required double gas,
    required double pressure,
    required double prevTemp,
    required double prevGas,
    required double prevPressure,
  }) {
    if (temp > 150) {
      return "Extreme temperature detected. High volcanic activity.";
    }

    if (gas > 300) {
      return "High gas concentration detected. Possible magma release.";
    }

    if (pressure > 1200) {
      return "Pressure anomaly detected.";
    }

    if (temp > 70 && gas > 100) {
      return "Increasing temperature and gas indicate rising volcanic activity.";
    }

    if (temp > prevTemp) {
      return "Temperature is increasing. Early activity suspected.";
    }

    return "All parameters are stable.";
  }
}
