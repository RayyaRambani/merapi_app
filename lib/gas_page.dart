import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GasPage extends StatelessWidget {
  final List data;

  const GasPage({super.key, required this.data});

  // ================= DATA =================
  double getCurrent() {
    if (data.isEmpty) return 0;
    return (data.first['gas_kf'] as num?)?.toDouble() ?? 0;
  }
  double getAverage() {
    if (data.isEmpty) return 0;

    final values = data
        .map((e) => (e['gas_kf'] as num?)?.toDouble() ?? 0)
        .toList();

    return values.reduce((a, b) => a + b) / values.length;
  }

  // List<double> getGasValues() {
  //   return data.map((e) => (e['gas'] as num?)?.toDouble() ?? 0).toList();
  // }

  // double getAverage() {
  //   final values = getGasValues();
  //   return values.reduce((a, b) => a + b) / values.length;
  // }

  // double getMaximum() {
  //   final values = getGasValues();
  //   return values.reduce((a, b) => a > b ? a : b);
  // }

  // double getMinimum() {
  //   final values = getGasValues();
  //   return values.reduce((a, b) => a < b ? a : b);
  // }

  
  List<FlSpot> getSpots() {
    final chartData = data.take(30).toList().reversed.toList();

    List<FlSpot> spots = [];

    for (int i = 0; i < chartData.length; i++) {
      final val = (chartData[i]['gas_kf'] as num?)?.toDouble() ?? 0;

      spots.add(FlSpot(i.toDouble(), val));
    }

    return spots;
  }

  String getObservation() {
    final avg = getAverage();

    if (avg == 0) {
      return "Insufficient data available for analysis.";
    }

    final latest = getCurrent();
    final change = ((latest - avg) / avg) * 100;

    if (change > 15) {
      return "A significant increase in gas concentration was detected compared to recent monitoring trends.";
    }

    if (change > 5) {
      return "Gas concentration is increasing compared to recent monitoring trends.";
    }

    return "Gas concentration remains within normal variation ranges.";
  }

  String getStatus(double current, double avg) {
    if (avg == 0) return "Stable";

    final change = ((current - avg) / avg) * 100;

    if (change > 15) {
      return "Significant Increase";
    }

    if (change > 5) {
      return "Rising";
    }

    return "Stable";
  }

  Color getStatusColor(double current, double avg) {
    if (avg == 0) return Colors.green;

    final change = ((current - avg) / avg) * 100;

    if (change > 15) {
      return Colors.red;
    }

    if (change > 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();
    final avgGas = getAverage();
    final chartData = data.take(30).toList().reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gas Activity Monitoring",
              style: TextStyle(color: Colors.white),
            ),
            // Text(
            //   "SO₂ monitoring",
            //   style: TextStyle(color: Colors.white54, fontSize: 12),
            // ),
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
                    "Gas Activity Status",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getStatus(current, avgGas).toUpperCase(),
                    style: TextStyle(
                      color: getStatusColor(current, avgGas),
                      fontSize: 32,
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
                          "Sensor Value",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "${current.toStringAsFixed(0)} ADC Value",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= CHART =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),

              child: Column(
                children: [
                  // CARD TREND
                  card(
                    insidePanel: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gas Sensor Trend",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: chartData.isEmpty ? 0 : (chartData.length - 1).toDouble(),

                              lineBarsData: [
                                LineChartBarData(
                                  spots: getSpots(),
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,

                                  dotData: FlDotData(show: true),

                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.orange.withOpacity(0.15),
                                  ),
                                ),
                              ],

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
                                    reservedSize: 40,
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
                                      final chartData = data.take(30).toList().reversed.toList();

                                      int index = value.toInt();

                                      if (index < 0 ||
                                          index >= chartData.length) {
                                        return const SizedBox();
                                      }

                                      int step = (chartData.length / 4).ceil();

                                      if (index % step != 0) {
                                        return const SizedBox();
                                      }

                                      final rawTime =
                                          chartData[index]['created_at'];

                                      DateTime dt;

                                      try {
                                        dt = DateTime.parse(rawTime).toLocal();
                                      } catch (_) {
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

                  const SizedBox(height: 12),

                  // CARD OBSERVATION
                  card(
                    insidePanel: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Observation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          getObservation(),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget card({required Widget child, bool insidePanel = false}) {
    return Container(
      margin: insidePanel ? EdgeInsets.zero : const EdgeInsets.all(16),
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
