import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturePage extends StatelessWidget {
  final List data;

  const TemperaturePage({super.key, required this.data});

  // ================= DATA =================
  List<FlSpot> getChart() {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final temp = (data[i]['temperature'] ?? 0).toDouble();

      // 🔥 FIX: pakai index (bukan timestamp)
      double x = i.toDouble();

      spots.add(FlSpot(x, temp));
    }

    return spots;
  }

  double getCurrent() => data.isNotEmpty
      ? (data.first['temperature'] as num?)?.toDouble() ?? 0
      : 0;

  double getMin() => data.isNotEmpty
      ? data
            .map((e) => (e['temperature'] ?? 0).toDouble())
            .reduce((a, b) => a < b ? a : b)
      : 0;

  double getMax() => data.isNotEmpty
      ? data
            .map((e) => (e['temperature'] ?? 0).toDouble())
            .reduce((a, b) => a > b ? a : b)
      : 0;

  double getAvg() {
    if (data.isEmpty) return 0;
    final temps = data.map((e) => (e['temperature'] ?? 0).toDouble()).toList();
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  String getStatus(double val) {
    if (val < 30) return "Normal";
    if (val <= 40) return "Elevated";
    return "High";
  }

  Color getColor(double val) {
    if (val < 30) return Colors.green;
    if (val <= 40) return Colors.orange;
    return Colors.red;
  }

  String getAnalysis(double temp, double hum) {
    if (temp < 30 && hum < 80) {
      return "Environmental conditions are stable. No significant thermal anomaly detected.";
    }

    if (temp < 40) {
      return "Temperature shows an increasing trend and should be monitored.";
    }

    return "Significant thermal anomaly detected. Further investigation is recommended.";
  }

  double getUpdateRate() {
    if (data.length < 2) return 0;

    DateTime t1 = DateTime.parse(data[0]['created_at']);
    DateTime t2 = DateTime.parse(data[1]['created_at']);

    return t1.difference(t2).inSeconds.toDouble();
  }

  double getHumidity() {
    if (data.isEmpty) return 0;

    return (data.first['humidity'] as num?)?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();
    final spots = getChart();
    final humidity = getHumidity();

    if (data.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: Text("No Data", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    double minY = getMin() - 5;
    double maxY = getMax() + 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Environmental Conditions",
          style: TextStyle(color: Colors.white),
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
                  colors: [Color(0xFFFF3B30), Color(0xFFFF6A3D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Environmental Conditions",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${current.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Humidity : ${humidity.toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mini("Avg Temp", getAvg()),
                      miniHumidity("Humidity", humidity),
                      statusMini(current),
                    ],
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
                    "Temperature Trend",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: data.length.toDouble(),
                        minY: minY,
                        maxY: maxY,

                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: (maxY - minY) / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(color: Colors.white10);
                          },
                        ),

                        borderData: FlBorderData(show: false),

                        // 🔥 TOOLTIP FIX
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                int index = spot.x.toInt();

                                final rawTime = data[index]['created_at'];

                                DateTime dt;
                                try {
                                  dt = DateTime.parse(rawTime);
                                } catch (e) {
                                  dt = DateTime.now();
                                }

                                return LineTooltipItem(
                                  "${spot.y.toStringAsFixed(1)}°C\n"
                                  "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}",
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (maxY - minY) / 4,
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

                          // 🔥 FIX ANTI BENTROK
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
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
                                  "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}",
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

                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: FlDotData(show: true),
                          ),
                        ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Update Rate",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "${getUpdateRate().toStringAsFixed(0)}s",
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

            // ================= ANALYSIS =================
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Analysis", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    getAnalysis(current, humidity),
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
        Text(v.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget miniHumidity(String title, double value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          "${value.toStringAsFixed(1)}%",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget statusMini(double temp) {
    return Column(
      children: [
        const Text("Status", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          getStatus(temp),
          style: TextStyle(color: getColor(temp), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
