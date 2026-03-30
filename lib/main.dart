import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'temperature_page.dart';

void main() {
  runApp(const MyApp());
}

// ================= APP =================
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

// ================= PAGE =================
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List data = [];
  bool isLoading = false;
  Timer? timer;

  final String apiUrl =
      "https://merapi-backend-production.up.railway.app/api/v1/data";

  @override
  void initState() {
    super.initState();
    fetchData();

    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= FETCH =================
  Future fetchData() async {
    try {
      setState(() => isLoading = true);

      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= STATUS =================
  String getStatus(Map item) {
    double gas = (item['gas'] ?? 0).toDouble();

    if (gas > 140) return "SIAGA";
    if (gas > 120) return "WASPADA";
    return "NORMAL";
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

  // ================= SENSOR CARD =================
  Widget sensorCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final latest = data.isNotEmpty ? data[0] : {};
    final status = getStatus(latest);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("🌋 Merapi Monitor"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: data.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // STATUS BESAR
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(status),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Gas: ${latest['gas'] ?? '-'}"),
                      ],
                    ),
                  ),

                  // SENSOR
                  Row(
                    children: [
                      sensorCard(
                        "Suhu",
                        "${latest['temperature'] ?? '-'}°C",
                        Icons.thermostat,
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TemperaturePage(data: data),
                            ),
                          );
                        },
                      ),
                      sensorCard(
                        "Gas",
                        "${latest['gas'] ?? '-'}",
                        Icons.cloud,
                        Colors.green,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Halaman Gas belum dibuat"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      sensorCard(
                        "Pressure",
                        "${latest['pressure'] ?? '-'}",
                        Icons.speed,
                        Colors.blue,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Halaman Pressure belum dibuat"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // LORA INFO
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
                          "📡 LoRa Info",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Distance: ${(latest['distance'] ?? 0).toStringAsFixed(1)} m",
                        ),
                        Text(
                          "Delay: ${(latest['delay'] ?? 0).toStringAsFixed(2)} s",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
