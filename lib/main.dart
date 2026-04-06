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
import 'volcano_analyzer.dart';
import 'lora_page.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await Permission.storage.request();
  runApp(const MyApp());
}

const bgColor = Color(0xFF0D0D0D);

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
  Timer? timer;

  final String apiUrl =
      "https://merapi-backend-production.up.railway.app/api/v1/data";

  @override
  void initState() {
    super.initState();
    fetchData();

    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String format(dynamic value, {String suffix = ""}) {
    if (value == null) return "-";
    return "${(value as num).toDouble().toStringAsFixed(1)}$suffix";
  }

  // ================= ANALYZER =================
  Map analyzer() {
    if (data.length < 2) {
      return {
        "status": "SAFE",
        "color": Colors.green,
        "analysis": "Menunggu data...",
      };
    }

    final last = data.last;
    final prev = data[data.length - 2];

    double temp = (last['temperature'] ?? 0).toDouble();
    double gas = (last['gas'] ?? 0).toDouble();
    double pressure = (last['pressure'] ?? 0).toDouble();

    double prevTemp = (prev['temperature'] ?? 0).toDouble();
    double prevGas = (prev['gas'] ?? 0).toDouble();
    double prevPressure = (prev['pressure'] ?? 0).toDouble();

    final status = VolcanoAnalyzer.getStatus(
      temp: temp,
      gas: gas,
      pressure: pressure,
      prevTemp: prevTemp,
      prevGas: prevGas,
      prevPressure: prevPressure,
    );

    return {
      "status": status,
      "color": VolcanoAnalyzer.getColor(status),
      "analysis": VolcanoAnalyzer.getAnalysis(
        temp: temp,
        gas: gas,
        pressure: pressure,
        prevTemp: prevTemp,
        prevGas: prevGas,
        prevPressure: prevPressure,
      ),
    };
  }

  // ================= ANALYSIS CARD =================
  Widget analysisCard() {
    final result = analyzer();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            result["color"].withOpacity(0.9),
            result["color"].withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: result["color"].withOpacity(0.4), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "VOLCANO ANALYSIS",
            style: GoogleFonts.orbitron(color: Colors.white70, letterSpacing: 1.5, fontSize: 14,),
          ),

          const SizedBox(height: 10),

          Text(
            result["status"],
            style: GoogleFonts.orbitron(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          Text(result["analysis"], style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mini("Temp", data.last['temperature'], "°C"),
              mini("Gas", data.last['gas'], ""),
              mini("Pressure", data.last['pressure'], "hPa"),
            ],
          ),
        ],
      ),
    );
  }

  Widget mini(String title, dynamic val, String unit) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12,)),
        Text(
          "$val$unit",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ================= LORA =================
  Widget loraCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoraPage()),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF140A0A)],
          ),
          border: Border.all(color: Colors.red.withOpacity(0.4)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.green),
                ),
                const CircleAvatar(radius: 5, backgroundColor: Colors.green),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "LoRa Connection",
              style: GoogleFonts.orbitron(
                color: Colors.white70, fontSize: 12, 
                letterSpacing: 1.5,),
            ),

            const SizedBox(height: 6),

            Text(
              "Connected",
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SENSOR =================
  // ================= SENSOR =================
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
        width: double.infinity, // 🔥 FIX: FULL WIDTH
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          gradient: LinearGradient(
            colors: [const Color(0xFF1A1A1A), color.withOpacity(0.25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          border: Border.all(color: color.withOpacity(0.4)),

          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 🔥 FIX
          children: [
            // 🔥 ICON (PASTI KIRI)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 TITLE
            Text(
              title,
              textAlign: TextAlign.left,
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 8),

            // 🔥 VALUE
            Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EXPORT =================
  Widget exportCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExportPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          // 🔥 DARK CARD
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),

          border: Border.all(color: Colors.red.withOpacity(0.4)),

          boxShadow: [
            BoxShadow(color: Colors.red.withOpacity(0.25), blurRadius: 18),
          ],
        ),

        child: Row(
          children: [
            // ICON BOX
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.download, color: Colors.blue),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Export Data",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Download sensor records",
                    style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // ARROW
            const Icon(Icons.arrow_forward, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final latest = data.isNotEmpty ? data.last : {};

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D3A),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "MERAPI MONITOR",
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4A0000),
                Color(0xFF8B0000),
                Color(0xFFB22222),
                Color(0xFFFF3B3B),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                analysisCard(),
                loraCard(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      sensorCard(
                        "Temperature",
                        format(latest['temperature'], suffix: "°C"),
                        Icons.thermostat,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemperaturePage(data: data),
                          ),
                        ),
                      ),
                      sensorCard(
                        "Gas",
                        format(latest['gas']),
                        Icons.cloud,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GasPage(data: data),
                          ),
                        ),
                      ),
                      sensorCard(
                        "Pressure",
                        format(latest['pressure']),
                        Icons.speed,
                        Colors.blue,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PressurePage(data: data),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                exportCard(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
