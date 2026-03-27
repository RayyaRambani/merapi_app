import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// ================= QUALITY =================
String getQuality(double? delay) {
  if (delay == null) return "UNKNOWN";
  if (delay < 1) return "EXCELLENT";
  if (delay < 3) return "GOOD";
  return "POOR";
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
  bool isLoading = true;

  int? lastAlertedId;
  bool isAlertShowing = false;
  Timer? timer;

  final String apiUrl =
      "https://merapi-backend-production.up.railway.app/api/v1/data";

  @override
  void initState() {
    super.initState();

    fetchData();

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final newData = jsonDecode(response.body);

        setState(() {
          data = List.from(newData);
          isLoading = false;
        });

        checkAlert();
      }
    } catch (e) {
      print("ERROR: $e");
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

  // ================= ALERT =================
  void checkAlert() {
    if (data.isEmpty) return;

    final latest = data[0];
    final status = getStatus(latest);
    final currentId = latest['id'];

    if (status == "SIAGA" && currentId != lastAlertedId) {
      lastAlertedId = currentId;

      Future.microtask(() {
        showAlert(latest);
      });
    }
  }

  void showAlert(Map item) {
    if (isAlertShowing) return;

    isAlertShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("⚠️ PERINGATAN SIAGA"),
          content: Text(
            "Gas tinggi!\n\nNode: ${item['node_id']}\nGas: ${item['gas']}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isAlertShowing = false;
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  // ================= UI COMPONENT =================
  Widget bigStatus(Map latest) {
    final status = getStatus(latest);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: getStatusColor(status),
            ),
          ),
          const SizedBox(height: 6),
          Text(status == "SIAGA" ? "Gas tinggi terdeteksi" : "Kondisi normal"),
        ],
      ),
    );
  }

  Widget sensorCard(String title, String value, IconData icon, Color color) {
    return Expanded(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget loraCard(Map latest) {
    final distance = latest['distance'];
    final delay = latest['delay'];

    final quality = getQuality(delay);

    return Container(
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
            "📡 LoRa Connection",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("📏 Distance: ${distance?.toStringAsFixed(1) ?? '-'} m"),
          Text("⏱ Delay: ${delay?.toStringAsFixed(2) ?? '-'} s"),
          Text("📶 Quality: $quality"),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final latest = data.isNotEmpty ? data[0] : {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("🌋 Merapi Monitor"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            bigStatus(latest),

            Row(
              children: [
                sensorCard(
                  "Suhu",
                  "${latest['temperature'] ?? '-'}°C",
                  Icons.thermostat,
                  Colors.orange,
                ),
                sensorCard(
                  "Gas",
                  "${latest['gas'] ?? '-'}",
                  Icons.cloud,
                  Colors.green,
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
                ),
              ],
            ),

            loraCard(latest),

            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text("Download Data"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
