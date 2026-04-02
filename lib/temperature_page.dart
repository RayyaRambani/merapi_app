import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturePage extends StatelessWidget {
  final List data;

  const TemperaturePage({super.key, required this.data});

  double getCurrent() => (data.last['temperature'] ?? 0).toDouble();

  double getMin() => data
      .map((e) => (e['temperature'] ?? 0).toDouble())
      .reduce((a, b) => a < b ? a : b);

  double getMax() => data
      .map((e) => (e['temperature'] ?? 0).toDouble())
      .reduce((a, b) => a > b ? a : b);

  double getAvg() {
    final temps = data.map((e) => (e['temperature'] ?? 0).toDouble()).toList();
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  String getStatus(double val) {
    if (val < 850) return "Safe";
    if (val <= 900) return "Elevated";
    return "Danger";
  }

  Color getColor(double val) {
    if (val < 850) return Colors.green;
    if (val <= 900) return Colors.orange;
    return Colors.red;
  }

  String getAnalysis(double val) {
    if (val < 850) {
      return "Temperature is stable and within safe limits.";
    } else if (val <= 900) {
      return "Temperature shows increasing volcanic activity. Monitoring required.";
    } else {
      return "Temperature indicates dangerous volcanic activity.";
    }
  }

  List<FlSpot> getChart() {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i]['temperature'] ?? 0).toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Temperature Sensor",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3B30), Color(0xFFFF6A3D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Temperature",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${current.toStringAsFixed(0)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mini("Avg", getAvg()),
                      mini("Max", getMax()),
                      mini("Min", getMin()),
                    ],
                  ),
                ],
              ),
            ),

            // 🔥 CHART
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Temperature Trend",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: getChart(),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 STATUS
            Row(
              children: [
                Expanded(
                  child: card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Update Rate",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "3s",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          getStatus(current),
                          style: TextStyle(
                            color: getColor(current),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🔥 ANALYSIS
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Analysis", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    getAnalysis(current),
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

  Widget card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget mini(String t, double v) {
    return Column(
      children: [
        Text(t, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          "${v.toStringAsFixed(0)}°C",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
