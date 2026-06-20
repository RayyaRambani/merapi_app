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
      return "PERUBAHAN SIGNIFIKAN";
    }

    // INCREASED
    if (gasChange > 5 || tempChange > 2) {
      return "MENINGKAT";
    }

    // NORMAL
    return "NORMAL";
  }

  // ================= COLOR =================
  static Color getColor(String status) {
    switch (status) {
      case "NORMAL":
        return Colors.green;

      case "MENINGKAT":
        return Colors.orange;

      case "PERUBAHAN SIGNIFIKAN":
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
      return "Data historis tidak mencukupi untuk analisis.";
    }

    final gasChange = ((gas - avgGas) / avgGas) * 100;

    final tempChange = ((temp - avgTemp) / avgTemp) * 100;

    if (gasChange > 15 || tempChange > 5) {
      return " Terdeteksi perubahan signifikan dibandingkan dengan tren pemantauan terkini.";
    }

    if (gasChange > 5 || tempChange > 2) {
      return " Terdeteksi peningkatan parameter lingkungan selama pemantauan terkini.";
    }

    return "Parameter lingkungan berada dalam rentang normal.";
  }
}
