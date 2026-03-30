import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PressurePage extends StatelessWidget {
  final List data;

  const PressurePage({super.key, required this.data});

  // ================= CHART =================
  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['pressure'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  // ================= STATISTIK =================
  double getMin() {
    return data
        .map((e) => (e['pressure'] ?? 0).toDouble())
        .reduce((a, b) => a < b ? a : b);
  }

  double getMax() {
    return data
        .map((e) => (e['pressure'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double getAvg() {
    final values = data.map((e) => (e['pressure'] ?? 0).toDouble()).toList();

    return values.reduce((a, b) => a + b) / values.length;
  }

  // ================= STATUS =================
  String getStatus() {
    final avg = getAvg();

    if (avg < 950) return "SIAGA";
    if (avg < 980) return "WASPADA";
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

    if (avg < 950) {
      return "Tekanan udara rendah signifikan, dapat mengindikasikan aktivitas vulkanik meningkat.";
    } else if (avg < 980) {
      return "Tekanan mulai menurun, perlu pemantauan lebih lanjut.";
    } else {
      return "Tekanan udara stabil dalam kondisi normal.";
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Pressure", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 CHART
            Container(
              height: 250,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getChartData(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            // 📊 STATISTIK
            buildCard("📊 Statistik", [
              "Min: ${getMin().toStringAsFixed(1)} °C",
              "Max: ${getMax().toStringAsFixed(1)} °C",
              "Avg: ${getAvg().toStringAsFixed(1)} °C",
            ]),

            // ⚠️ STATUS
            buildStatus(),

            // 🧠 ANALISIS
            buildCard("🧠 Analisis", [getAnalysis()]),
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
}
