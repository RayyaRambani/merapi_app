import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GasPage extends StatelessWidget {
  final List data;

  const GasPage({super.key, required this.data});

  // ================= CHART =================
  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final gas = (data[i]['gas'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), gas));
    }

    return spots;
  }

  // ================= STATISTIK =================
  double getMin() {
    return data
        .map((e) => (e['gas'] ?? 0).toDouble())
        .reduce((a, b) => a < b ? a : b);
  }

  double getMax() {
    return data
        .map((e) => (e['gas'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double getAvg() {
    final values = data.map((e) => (e['gas'] ?? 0).toDouble()).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  // ================= STATUS =================
  String getStatus() {
    final avg = getAvg();

    if (avg > 140) return "SIAGA";
    if (avg > 120) return "WASPADA";
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

    if (avg > 140) {
      return "Kadar gas tinggi, menunjukkan potensi aktivitas vulkanik meningkat.";
    } else if (avg > 120) {
      return "Gas mulai meningkat, perlu pemantauan lebih lanjut.";
    } else {
      return "Kadar gas dalam kondisi normal.";
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌫 Detail Gas"),
        backgroundColor: Colors.deepOrange,
      ),
      body: data.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // CHART
                  Container(
                    height: 250,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: getChartData(),
                            isCurved: true,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // STATISTIK
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📈 Statistik",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text("Min: ${getMin().toStringAsFixed(1)}"),
                        Text("Max: ${getMax().toStringAsFixed(1)}"),
                        Text("Avg: ${getAvg().toStringAsFixed(1)}"),
                      ],
                    ),
                  ),

                  // STATUS
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text("Status: "),
                        Text(
                          getStatus(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ANALISIS
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🧠 Analisis",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(getAnalysis()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
