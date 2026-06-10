import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PressurePage extends StatelessWidget {
  final List data;

  const PressurePage({super.key, required this.data});

  // ================= DATA =================
  double getValue(Map item) => (item['pressure'] ?? 0).toDouble();

  double getCurrent() => data.isNotEmpty ? getValue(data.first) : 0;

  double getMin() => data.map((e) => getValue(e)).reduce(min);

  double getMax() => data.map((e) => getValue(e)).reduce(max);

  double getAvg() {
    final vals = data.map((e) => getValue(e)).toList();
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  double getChange() {
    if (data.length < 2) return 0;
    return getValue(data.first) - getValue(data.last);
  }

  // ================= STATUS =================
  String getTrend() {
    final change = getChange();
    if (change > 1) return "rising";
    if (change < -1) return "falling";
    return "stable";
  }

  String getCondition() {
    final val = getCurrent();

    if (val < 990) {
      return "Low Pressure";
    }

    if (val > 1025) {
      return "High Pressure";
    }

    return "Normal Pressure";
  }

  String getStability() {
    final diff = getMax() - getMin();
    if (diff < 1) return "Stable";
    if (diff < 3) return "Moderate";
    return "Variable";
  }

  // ================= CHART ================= //
  List<FlSpot> getChart() {
    final chartData = data.reversed.toList();

    List<FlSpot> spots = [];

    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(chartData[i])));
    }

    return spots;
  }

  

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();
    final change = getChange();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pressure Sensor", style: TextStyle(color: Colors.white)),
            Text(
              "Atmospheric monitoring",
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
                  colors: [Color(0xFFF4A62A), Color(0xFFF7C948)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Pressure",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${current.toStringAsFixed(2)} hPa",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTrend(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mini("Average", getAvg()),
                      mini("Max", getMax()),
                      mini("Min", getMin()),
                    ],
                  ),
                ],
              ),
            ),

            

            // ================= TREND =================
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pressure Trend",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "${change >= 0 ? "+" : ""}${change.toStringAsFixed(0)} hPa",
                        style: TextStyle(
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (data.length - 1).toDouble(),

                        lineBarsData: [
                          LineChartBarData(
                            spots: getChart(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],

                        borderData: FlBorderData(show: false),

                        gridData: FlGridData(show: true),

                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int i = value.toInt();
                                if (i >= data.length) {
                                  return const SizedBox();
                                }

                                int step = (data.length / 4).ceil();
                                if (i % step != 0) {
                                  return const SizedBox();
                                }

                                final chartData = data.reversed.toList();

                                final rawTime = chartData[i]['created_at'];

                                DateTime dt = DateTime.parse(rawTime);

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

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
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

            // ================= STATUS =================
            Row(
              children: [
                Expanded(
                  child: card(
                    child: Column(
                      children: [
                        const Text(
                          "Stability",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getStability(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: card(
                    child: Column(
                      children: [
                        const Text(
                          "Condition",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getCondition(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Observation",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    getTrend() == "rising"
                        ? "Atmospheric pressure shows an increasing trend during the observation period."
                        : getTrend() == "falling"
                        ? "Atmospheric pressure shows a decreasing trend during the observation period."
                        : "Atmospheric pressure remains relatively stable during the observation period.",

                    style: const TextStyle(color: Colors.white70, height: 1.5),
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

  Widget mini(String t, double v) {
    return Column(
      children: [
        Text(t, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          "${v.toStringAsFixed(2)} hPa",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
