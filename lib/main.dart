import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'temperature_page.dart';
import 'gas_page.dart';
import 'pressure_page.dart';
import 'splash_screen.dart'; // 🔥 TAMBAH INI

void main() {
  runApp(const MyApp());
}

// ================= COLORS =================
const bgColor = Color(0xFF0D0D0D);
const cardColor = Color(0xFF1A1A1A);
const lavaRed = Color(0xFFFF3B30);

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const SplashScreen(), // 🔥 FIX DISINI
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
        final newData = jsonDecode(response.body);

        setState(() {
          data = newData;
        });

        // 🔥 ALERT SIAGA
        if (data.isNotEmpty) {
          checkAlert(data[0]);
        }
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= ALERT =================
  void checkAlert(Map latest) {
    final gas = (latest['gas'] ?? 0).toDouble();

    if (gas > 140) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("⚠️ SIAGA", style: TextStyle(color: Colors.red)),
          content: const Text(
            "Gas tinggi terdeteksi!\nPotensi aktivitas meningkat.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // ================= STATUS =================
  String getStatus(Map item) {
    double gas = (item['gas'] ?? 0).toDouble();

    if (gas > 140) return "SIAGA";
    if (gas > 120) return "WASPADA";
    return "NORMAL";
  }

  // ================= SENSOR CARD =================
  Widget sensorCard(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.95, end: 1),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: lavaRed.withOpacity(0.4), blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: lavaRed, size: 30),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= STATUS CARD =================
  Widget statusCard(String status, double gas) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 0.8),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: lavaRed.withOpacity(value), blurRadius: 30),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: const TextStyle(
              color: lavaRed,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text("Gas: $gas", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ================= LORA CARD =================
  Widget loraCard(Map latest) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📡 LoRa Connection",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Distance: ${(latest['distance'] ?? 0).toStringAsFixed(1)} m",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Delay: ${(latest['delay'] ?? 0).toStringAsFixed(2)} s",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final latest = data.isNotEmpty ? data[0] : {};
    final status = getStatus(latest);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Merapi Monitor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: lavaRed,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: data.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada data",
                style: TextStyle(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  statusCard(status, (latest['gas'] ?? 0).toDouble()),

                  Row(
                    children: [
                      sensorCard(
                        "Suhu",
                        "${latest['temperature']}°C",
                        Icons.thermostat,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TemperaturePage(data: data),
                            ),
                          );
                        },
                      ),
                      sensorCard("Gas", "${latest['gas']}", Icons.cloud, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GasPage(data: data),
                          ),
                        );
                      }),
                    ],
                  ),

                  Row(
                    children: [
                      sensorCard(
                        "Pressure",
                        "${latest['pressure']}",
                        Icons.speed,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PressurePage(data: data),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  loraCard(latest),
                ],
              ),
            ),
    );
  }
}
