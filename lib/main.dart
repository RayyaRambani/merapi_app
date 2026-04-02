import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'temperature_page.dart';
import 'gas_page.dart';
import 'pressure_page.dart';
import 'splash_screen.dart';
import 'export_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await Permission.storage.request();
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

      if (response.statusCode == 200 && response.body.isNotEmpty) {
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

  // ================= SENSOR LIST CARD =================
  Widget sensorListCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),

        // 🔥 GRADIENT BORDER
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.8),
              Colors.deepOrange,
              Colors.red.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        padding: const EdgeInsets.all(1.5),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.2),
                blurRadius: 25,
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP ROW =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ICON SENSOR
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),

                  // 🔥 ICON NAVIGASI (INDIKASI BISA DIKLIK)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white30,
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= TITLE =================
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 6),

              // ================= VALUE =================
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CONTENT =================
  Widget buildContent(Map latest) {
    return Column(
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              sensorListCard(
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
              sensorListCard(
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
              sensorListCard(
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: exportCard(context),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ================= LORA =================
  Widget loraCard(Map latest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      // 🔥 GRADIENT BORDER
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withOpacity(0.8),
            Colors.deepOrange,
            Colors.red.shade900,
          ],
        ),
      ),

      padding: const EdgeInsets.all(1.5),

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.green),
                ),

                // 🔥 TITIK HIJAU (STATUS)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // TITLE
            const Text(
              "LoRa Connection",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 6),

            // STATUS
            const Text(
              "Connected",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Signal Strong",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exportCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExportPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.8),
              Colors.deepOrange,
              Colors.red.shade900,
            ],
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.download, color: Colors.blue),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Export Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Download sensor records",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.blue),
            ],
          ),
        ),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant oldDelegate) => true;
}
