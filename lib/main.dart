import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DataPage(),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List data = [];
  bool isLoading = true;

  final String apiUrl = "http://192.168.43.67:3000/api/v1/data";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // =========================
  // FETCH DATA
  // =========================
  Future fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // CHART DATA
  // =========================
  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final value = (item['temperature'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  // =========================
  // STATUS LOGIC
  // =========================
  String getStatus(Map item) {
    double gas = (item['gas'] ?? 0).toDouble();

    if (gas > 140) {
      return "SIAGA";
    } else if (gas > 120) {
      return "WASPADA";
    } else {
      return "NORMAL";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "SIAGA":
        return Colors.red;
      case "WASPADA":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitoring Merapi"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📊 CHART
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: getChartData(),
                            isCurved: true,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 📋 LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchData,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final status = getStatus(item);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text("Node: ${item['node_id']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Temp: ${item['temperature']}°C | "
                                  "Gas: ${item['gas']} | "
                                  "Pressure: ${item['pressure']}",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Status: $status",
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
