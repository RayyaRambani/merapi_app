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
import 'notification_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await Permission.storage.request();
  await NotificationService.init();
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
  Timer? dangerTimer;
 // detik

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
    dangerTimer?.cancel();
    super.dispose();
  }

  
  Future fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Status:${response.statusCode}");
      print("Body : ${response.body}");


      if (response.statusCode == 200) {
        setState(() {
          data = List.from(jsonDecode(response.body));
        });

        // 🔥 STEP 4 TARUH DI SINI (SETELAH setState)
        final result = analyzer();

        // 🔴 MODE ALARM (LOOP)
        if (result["status"] == "DANGER") {
          // kalau belum ada timer → mulai
          if (dangerTimer == null) {
            dangerTimer = Timer.periodic(Duration(seconds: 5), (_) {
              NotificationService.showDangerNotification();
            });
          }
        } else {
          // kalau bukan danger → stop alarm
          dangerTimer?.cancel();
          dangerTimer = null;
        }

        
      }
    } catch (e) {
      print(e);
    }
  }

  String format(dynamic value, {String suffix = ""}) {
    if (value == null) return "-";
    return "${(value as num).toDouble().toStringAsFixed(1)}$suffix";
  }
  //lastupdateicon//
  String getLastUpdate() {
    if (data.isEmpty) return "-";

    final time = DateTime.parse(data.first['created_at']).toLocal();

    return "${time.hour}:${time.minute}:${time.second}";
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

    final last = data.first;
    final prev = data.length > 1 ? data[1]:data.first;

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
    if (data.isEmpty){
      return Center(child: CircularProgressIndicator());
    }
    final result = analyzer();

    bool isDanger = result["status"] == "DANGER";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        // 🔥 GRADIENT LEBIH DALAM
        gradient: LinearGradient(
          colors: [result["color"].withOpacity(0.9), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        // 🔥 GLOW LEBIH HIDUP
        boxShadow: [
          BoxShadow(
            color: result["color"].withOpacity(0.7),
            blurRadius: isDanger ? 40 : 25,
            spreadRadius: isDanger ? 3 : 1,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔴 HEADER + STATUS DOT
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: result["color"],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "SYSTEM STATUS",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔥 STATUS BESAR
          Text(
            result["status"],
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: result["color"],
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 10),

          // 🧠 ANALYSIS TEXT
          Text(
            result["analysis"],
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
          ),

          const SizedBox(height: 18),

          // 📊 MINI DATA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mini("Temp", data.first['temperature'], "°C"),
              mini("Gas", data.first['gas'], ""),
              mini("Pressure", data.first['pressure'], "hPa"),
            ],
          ),
        ],
      ),
    );
  }

////////MULTICHART////////
  Widget buildMultiChart() {
    if (data.isEmpty) return SizedBox();

    final points = data.take(10).toList().reversed.toList();

    List<FlSpot> tempSpots = [];
    List<FlSpot> gasSpots = [];
    List<FlSpot> pressureSpots = [];

    for (int i = 0; i < points.length; i++) {
      final d = points[i];

      tempSpots.add(FlSpot(i.toDouble(), (d['temperature'] ?? 0).toDouble()));
      gasSpots.add(FlSpot(i.toDouble(), (d['gas'] ?? 0).toDouble()));
      pressureSpots.add(FlSpot(i.toDouble(), (d['pressure'] ?? 0).toDouble()));
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
        ),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SENSOR TREND",
            style: GoogleFonts.orbitron(color: Colors.white),
          ),

          SizedBox(height: 10),

          // 🔥 LEGEND
          Row(
            children: [
              legend("Temp", Colors.red),
              SizedBox(width: 10),
              legend("Gas", Colors.orange),
              SizedBox(width: 10),
              legend("Pressure", Colors.blue),
            ],
          ),

          SizedBox(height: 10),

          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                lineBarsData: [
                  // 🔴 TEMP
                  LineChartBarData(
                    spots: tempSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),

                  // 🟠 GAS
                  LineChartBarData(
                    spots: gasSpots,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),

                  // 🔵 PRESSURE
                  LineChartBarData(
                    spots: pressureSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget legend(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget buildLog() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("DATA LOG", style: GoogleFonts.orbitron(color: Colors.white)),
          SizedBox(height: 10),
          ...data
              .take(5)
              .map(
                (d) => Text(
                  "${d['temperature']}°C | Gas ${d['gas']} | ${d['pressure']} hPa",
                  style: GoogleFonts.rajdhani(color: Colors.white70),
                ),
              ),
        ],
      ),
    );
  }

  Widget buildMap() {
    if (data.isEmpty) return SizedBox();

    final lat = data.first['lat'];
    final lon = data.first['lon'];

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lon),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName:'com.example.merapi_app',
                subdomains:['a','b','c','d'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lon),
                    child: Icon(Icons.location_on, color: Colors.red, size: 30),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final latest = data.isNotEmpty ? data.first : {};

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D3A),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "VULCANO SURVEILLANCE",
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    "Last Update: ${getLastUpdate()}",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
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

                // 📈 CHART
              buildMultiChart(),
                // 📜 LOG
                buildLog(),

                // 📍 MAP
                buildMap(),

                exportCard(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
