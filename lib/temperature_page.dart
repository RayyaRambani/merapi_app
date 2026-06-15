import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturePage extends StatelessWidget {
  final List data;

  const TemperaturePage({super.key, required this.data});

  // ================= DATA =================
  List<FlSpot> getTemperatureChart() {
    final chartData = data.reversed.toList();

    List<FlSpot> spots = [];

    for (int i = 0; i < chartData.length; i++) {
      final temp = (chartData[i]['temperature_kf'] ?? 0).toDouble();

      spots.add(FlSpot(i.toDouble(), temp));
    }

    return spots;
  }
  List<FlSpot> getHumidityChart() {
    final chartData = data.reversed.toList();

    List<FlSpot> spots = [];

    for (int i = 0; i < chartData.length; i++) {
      final hum = (chartData[i]['humidity_kf'] ?? 0).toDouble();

      spots.add(FlSpot(i.toDouble(), hum));
    }

    return spots;
  }

  double getMinHumidity() => data.isNotEmpty
      ? data
            .map((e) => (e['humidity_kf'] ?? 0).toDouble())
            .reduce((a, b) => a < b ? a : b)
      : 0;

  double getMaxHumidity() => data.isNotEmpty
      ? data
            .map((e) => (e['humidity_kf'] ?? 0).toDouble())
            .reduce((a, b) => a > b ? a : b)
      : 0;

  double getCurrent() => data.isNotEmpty
      ? (data.first['temperature_kf'] as num?)?.toDouble() ?? 0
      : 0;

  double getMin() => data.isNotEmpty
      ? data
            .map((e) => (e['temperature_kf'] ?? 0).toDouble())
            .reduce((a, b) => a < b ? a : b)
      : 0;

  double getMax() => data.isNotEmpty
      ? data
            .map((e) => (e['temperature_kf'] ?? 0).toDouble())
            .reduce((a, b) => a > b ? a : b)
      : 0;

  double getAvg() {
    if (data.isEmpty) return 0;
    final temps = data
        .map((e) => (e['temperature_kf'] ?? 0).toDouble())
        .toList();
    return temps.reduce((a, b) => a + b) / temps.length;
  }
  double getAvgHumidity() {
    if (data.isEmpty) return 0;

    final hums = data.map((e) => (e['humidity_kf'] ?? 0).toDouble()).toList();

    return hums.reduce((a, b) => a + b) / hums.length;
  }

  String getStatus(double temp, double avgTemp, double hum, double avgHum) {
    double tempDiff = (temp - avgTemp).abs();
    double humDiff = (hum - avgHum).abs();

    if (tempDiff >= 3 || humDiff >= 3) {
      return "Significant Change";
    }

    if (tempDiff >= 1 || humDiff >= 1) {
      return "Increasing";
    }

    return "Stable";
  }

  Color getColor(double temp, double avgTemp, double hum, double avgHum) {
    double tempDiff = (temp - avgTemp).abs();
    double humDiff = (hum - avgHum).abs();

    if (tempDiff >= 3 || humDiff >= 3) {
      return Colors.red;
    }

    if (tempDiff >= 1 || humDiff >= 1) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String getAnalysis(double temp, double avgTemp, double hum, double avgHum) {
    double tempDiff = (temp - avgTemp).abs();
    double humDiff = (hum - avgHum).abs();

    if (tempDiff >= 3 || humDiff >= 3) {
      return "Significant variations were detected in environmental conditions compared to recent monitoring averages.";
    }

    if (tempDiff >= 1 || humDiff >= 1) {
      return "Moderate environmental variations were detected during recent monitoring.";
    }

    return "Temperature and humidity remain within normal variation ranges.";
  }

  double getUpdateRate() {
    if (data.length < 2) return 0;

    DateTime t1 = DateTime.parse(data[0]['created_at']).toLocal();
    DateTime t2 = DateTime.parse(data[1]['created_at']).toLocal();

    return t1.difference(t2).inSeconds.toDouble();
  }

  double getHumidity() {
    if (data.isEmpty) return 0;

    return (data.first['humidity_kf'] as num?)?.toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = getCurrent();
    final chartData = data.reversed.toList();
    final tempSpots = getTemperatureChart();
    final humSpots = getHumidityChart();
    final humidity = getHumidity();
    final avgHumidity = getAvgHumidity();
    final avgTemp = getAvg();
    double minHum = getMinHumidity() - 5;

    double maxHum = getMaxHumidity() + 5;

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
                      miniHumidity("Avg Hum", getAvgHumidity()),
                      
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
                        maxX: data.isEmpty ? 0 : (data.length - 1).toDouble(),
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
                                if (index < 0 || index >= chartData.length) {
                                  return null;
                                }

                                final rawTime = chartData[index]['created_at'];

                                DateTime dt;
                                try {
                                  dt = DateTime.parse(rawTime).toLocal();
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

                                final rawTime = chartData[index]['created_at'];

                                DateTime dt;
                                try {
                                  dt = DateTime.parse(rawTime).toLocal();
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
                          // Temperature
                          LineChartBarData(
                            spots: tempSpots,
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
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Humidity Trend",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,

                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: data.isEmpty ? 0:(data.length - 1).toDouble(),

                        minY: minHum,
                        maxY: maxHum,

                        borderData: FlBorderData(show: false),

                        gridData: FlGridData(show: true),

                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                int index = spot.x.toInt();
                                if (index < 0 || index >= chartData.length) {
                                  return null;
                                }

                                final rawTime = chartData[index]['created_at'];

                                DateTime dt;
                                try {
                                  dt = DateTime.parse(rawTime).toLocal();
                                } catch (e) {
                                  dt = DateTime.now();
                                }

                                return LineTooltipItem(
                                  "${spot.y.toStringAsFixed(1)}%\n"
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
                              interval: (maxHum - minHum) / 4,
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
                              reservedSize: 30,

                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();

                                if (index < 0 || index >= chartData.length) {
                                  return const SizedBox();
                                }

                                int step = (chartData.length / 4).ceil();

                                if (index % step != 0) {
                                  return const SizedBox();
                                }

                                final rawTime = chartData[index]['created_at'];

                                DateTime dt;

                                try {
                                  dt = DateTime.parse(rawTime).toLocal();
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

                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: humSpots,

                            isCurved: true,

                            color: Colors.blue,

                            barWidth: 3,

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
                          getStatus(current, avgTemp, humidity, avgHumidity).toUpperCase(),
                          style: TextStyle(
                            color: getColor(current, avgTemp, humidity, avgHumidity),
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
                    getAnalysis(current, avgTemp, humidity, avgHumidity),
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

  
}
