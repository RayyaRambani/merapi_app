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
    bool tempUp = temp > prevTemp;
    bool gasUp = gas > prevGas;
    bool pressureUp = pressure > prevPressure;

    if (tempUp && gasUp && pressureUp) {
      return "DANGER";
    }

    if (tempUp && gasUp) {
      return "SIAGA";
    }

    if (tempUp) {
      return "WASPADA";
    }

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
    bool tempUp = temp > prevTemp;
    bool gasUp = gas > prevGas;
    bool pressureUp = pressure > prevPressure;

    if (tempUp && gasUp && pressureUp) {
      return "Temperature, gas, and pressure are all increasing. This indicates magma movement and high eruption potential.";
    }

    if (tempUp && gasUp && !pressureUp) {
      return "Temperature and gas are increasing, but pressure is decreasing. Possible gas release is occurring.";
    }

    if (tempUp && !gasUp) {
      return "Temperature rising without significant gas increase. Early volcanic activity suspected.";
    }

    return "All parameters are stable. No significant volcanic activity detected.";
  }
}
