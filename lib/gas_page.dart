import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GasPage extends StatelessWidget {
  final List data;

  const GasPage({super.key, required this.data});

  // ================= DATA =================
  double getCurrent() => (data.last['gas'] ?? 0).toDouble();

  List<BarChartGroupData> getBars() {
    List<BarChartGroupData> bars = [];

    for (int i = 0; i < data.length; i++) {
      final val = (data[i]['gas'] ?? 0).toDouble();

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              width: 10,
              borderRadius: BorderRadius.circular(4),
              color: Colors.orange,
            ),
          ],
        ),
      );
    }

    return bars;
  }

  String getStatus(double val) {
    if (val < 50) return "Normal";
    if (val < 80) return "Warning";
    return "High";
  }

  Color getStatusColor(double val) {
    if (val < 50) return Colors.green;
    if (val < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gas Emission Sensor", style: TextStyle(color: Colors.white)),
            Text(
              "SO₂ monitoring",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A3D), Color(0xFFFFB347)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Emission",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${current.toStringAsFixed(0)} ppm",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // hanya SO2
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "SO₂",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "${current.toStringAsFixed(0)} ppm",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= CHART =================
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SO₂ Trend",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        barGroups: getBars(),
                        borderData: FlBorderData(show: false),

                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(color: Colors.white10);
                          },
                        ),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();

                                if (index < 0 || index >= data.length) {
                                  return const SizedBox();
                                }

                                int step = (data.length / 4).ceil();

                                if (index % step != 0) {
                                  return const SizedBox();
                                }

                                final rawTime = data[index]['created_at'];

                                DateTime dt;
                                try {
                                  dt = DateTime.parse(rawTime);
                                } catch (e) {
                                  return const SizedBox();
                                }

                                return Text(
                                  "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),

                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= SAFETY =================
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gas Safety Level",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "SO₂",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        getStatus(current),
                        style: TextStyle(
                          color: getStatusColor(current),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (current / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(
                        getStatusColor(current),
                      ),
                    ),
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
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}
