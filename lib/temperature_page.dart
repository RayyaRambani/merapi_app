import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturePage extends StatelessWidget {
  final List data;

  const TemperaturePage({super.key, required this.data});

  // ================= DATA =================
  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final temp = (data[i]['temperature'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), temp));
    }

    return spots;
  }

  // ================= STATISTIK =================
  double getMin() {
    return data
        .map((e) => (e['temperature'] ?? 0).toDouble())
        .reduce((a, b) => a < b ? a : b);
  }

  double getMax() {
    return data
        .map((e) => (e['temperature'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double getAvg() {
    final temps = data.map((e) => (e['temperature'] ?? 0).toDouble()).toList();

    return temps.reduce((a, b) => a + b) / temps.length;
  }

  // ================= STATUS =================
  String getStatus() {
    final avg = getAvg();

    if (avg > 80) return "SIAGA";
    if (avg > 50) return "WASPADA";
    return "NORMAL";
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case "SIAGA":
        return Colors.red;
      case "WASPADA":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ================= ANALISIS =================
  String getAnalysis() {
    final avg = getAvg();

    if (avg > 80) {
      return "Terjadi peningkatan suhu signifikan yang dapat mengindikasikan aktivitas vulkanik meningkat.";
    } else if (avg > 50) {
      return "Suhu menunjukkan tren meningkat, perlu pemantauan lebih lanjut.";
    } else {
      return "Suhu berada dalam kondisi normal dan stabil.";
    }
  }

  // ================= UI =================
  @override
  @override
  Widget build(BuildContext context) {
    final avg = getAvg();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Temperature", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= BIG VALUE =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${avg.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getStatus(),
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ================= CHART =================
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getChartData(),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= STATISTIK =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  statBox("Min", getMin()),
                  statBox("Max", getMax()),
                  statBox("Avg", getAvg()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ANALISIS =================
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Analysis",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getAnalysis(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildCard(String title, List<String> content) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...content.map(
            (e) => Text(e, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget buildStatus() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          const Text("Status: ", style: TextStyle(color: Colors.white)),
          Text(
            getStatus(),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget statBox(String title, double value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 6),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
