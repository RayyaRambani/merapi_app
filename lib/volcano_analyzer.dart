import 'package:flutter/material.dart';

class VolcanoAnalyzer {
  // ================= STATUS =================
  static String getStatus({
    required double temp,
    required double gas,
    required double pressure,
    required double avgTemp,
    required double avgGas,
    required double avgPressure,
  }) {
    if (avgTemp == 0 || avgGas == 0) {
      return "NORMAL";
    }

    final gasChange = ((gas - avgGas) / avgGas) * 100;

    final tempChange = ((temp - avgTemp) / avgTemp) * 100;

    // HIGH
    if (gasChange > 15 || tempChange > 5) {
      return "HIGH";
    }

    // INCREASED
    if (gasChange > 5 || tempChange > 2) {
      return "INCREASED";
    }

    // NORMAL
    return "NORMAL";
  }

  // ================= COLOR =================
  static Color getColor(String status) {
    switch (status) {
      case "NORMAL":
        return Colors.green;

      case "INCREASED":
        return Colors.orange;

      case "HIGH":
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
    required double avgTemp,
    required double avgGas,
    required double avgPressure,
  }) {
    if (avgTemp == 0 || avgGas == 0) {
      return "Insufficient historical data for analysis.";
    }

    final gasChange = ((gas - avgGas) / avgGas) * 100;

    final tempChange = ((temp - avgTemp) / avgTemp) * 100;

    if (gasChange > 15 || tempChange > 5) {
      return "A significant increase was detected compared to recent monitoring trends.";
    }

    if (gasChange > 5 || tempChange > 2) {
      return "An increase in environmental parameters was detected during recent monitoring.";
    }

    return "Monitoring parameters remain within normal variation ranges.";
  }
}
