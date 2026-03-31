import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'temperature_page.dart';
import 'gas_page.dart';
import 'pressure_page.dart';
import 'splash_screen.dart';

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
      home: const SplashScreen(),
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
      }
    } catch (e) {
      print("ERROR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= AVERAGE =================
  double getAverage(Map item) {
    double temp = (item['temperature'] ?? 0).toDouble();
    double gas = (item['gas'] ?? 0).toDouble();
    double pressure = (item['pressure'] ?? 0).toDouble();

    return (temp + gas + pressure) / 3;
  }

  // ================= STATUS =================
  String getStatus(Map item) {
    double avg = getAverage(item);

    if (avg >= 120) return "SIAGA";
    if (avg >= 90) return "WASPADA";
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

  // ================= FORMAT =================
  String format(dynamic value, {String suffix = ""}) {
    if (value == null) return "-";

    try {
      final numVal = (value as num).toDouble();
      return "${numVal.toStringAsFixed(1)}$suffix";
    } catch (e) {
      return "-";
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Merapi Monitor",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text("Real-time Monitoring", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // ================= CONTENT =================
  Widget buildContent(Map latest) {
    return Column(
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              sensorCard(
                "Temperature",
                format(latest['temperature'], suffix: "°C"),
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
                format(latest['gas']),
                Icons.cloud,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GasPage(data: data)),
                  );
                },
              ),
              sensorCard(
                "Pressure",
                format(latest['pressure']),
                Icons.speed,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PressurePage(data: data)),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: loraCard(latest),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ================= LORA =================
  Widget loraCard(Map latest) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Connection",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Distance: ${format(latest['distance'], suffix: " m")}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Delay: ${format(latest['delay'], suffix: " s")}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final latest = data.isNotEmpty ? data[0] as Map : {};
    final status = getStatus(latest);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Merapi Monitor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: buildHeader()),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: StatusHeaderDelegate(status: status),
                ),

                SliverToBoxAdapter(child: buildContent(latest)),
              ],
            ),
    );
  }
}

// ================= STICKY STATUS =================
class StatusHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String status;

  StatusHeaderDelegate({required this.status});

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

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final color = getStatusColor(status);

    return SizedBox.expand(
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "STATUS",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
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

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant oldDelegate) => true;
}
