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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌡 Detail Suhu"),
        backgroundColor: Colors.deepOrange,
      ),
      body: data.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ================= CHART =================
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
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= STATISTIK =================
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
                        Text("Min: ${getMin().toStringAsFixed(1)} °C"),
                        Text("Max: ${getMax().toStringAsFixed(1)} °C"),
                        Text("Avg: ${getAvg().toStringAsFixed(1)} °C"),
                      ],
                    ),
                  ),

                  // ================= STATUS =================
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

                  // ================= ANALISIS =================
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
