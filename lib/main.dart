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
  int persistenceCounter = 0;
  final int persistenceLimit = 5;

  final String apiUrl =
      "https://merapi-backend-production.up.railway.app/api/v1/data";

  @override
  void initState() {
    super.initState();
    fetchData();

    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
        if (result["status"] == "PERUBAHAN SIGNIFIKAN") {
          persistenceCounter++;
          if (persistenceCounter >= persistenceLimit) {
            if (dangerTimer == null) {
              dangerTimer = Timer.periodic(Duration(seconds: 5), (_) {
                NotificationService.showDangerNotification();
              });
            }
          }
          // kalau belum ada timer → mulai
        } else {
          // kalau bukan danger → stop alarm
          persistenceCounter = 0;
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

    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }

  double averageLog(String key) {
    final count = data.length > 10 ? 10 : data.length;

    double sum = 0;

    for (int i = 0; i < count; i++) {
      sum += (data[i][key] as num?)?.toDouble() ?? 0;
    }

    return sum / count;
  }

  // ================= ANALYZER =================
  Map analyzer() {
    if (data.length < 2) {
      return {
        "status": "Memuat",
        "color": Colors.green,
        "analysis": "Menunggu data...",
      };
    }

    final last = data.first;

    double average(String key) {
      if (data.isEmpty) return 0;

      final count = data.length > 10 ? 10 : data.length;

      double sum = 0;

      for (int i = 0; i < count; i++) {
        sum += (data[i][key] as num?)?.toDouble() ?? 0;
      }

      return sum / count;
    }

    double temp = (last['temperature_kf'] ?? 0).toDouble();
    double gas = (last['gas_kf'] ?? 0).toDouble();
    double pressure = (last['pressure_kf'] ?? 0).toDouble();

    final avgTemp = average('temperature_kf');

    final avgGas = average('gas_kf');

    final avgPressure = average('pressure_kf');

    final status = VolcanoAnalyzer.getStatus(
      temp: temp,
      gas: gas,
      pressure: pressure,
      avgTemp: avgTemp,
      avgGas: avgGas,
      avgPressure: avgPressure,
    );

    return {
      "status": status,
      "color": VolcanoAnalyzer.getColor(status),
      "analysis": VolcanoAnalyzer.getAnalysis(
        temp: temp,
        gas: gas,
        pressure: pressure,
        avgTemp: avgTemp,
        avgGas: avgGas,
        avgPressure: avgPressure,
      ),
    };
  }

  // ================= ANALYSIS CARD =================
  Widget analysisCard() {
    if (data.isEmpty) {
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
              const SizedBox(width: 12),
              Text(
                "STATUS LINGKUNGAN",
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
        ],
      ),
    );
  }

  ////////MULTICHART////////
  // Widget buildMultiChart() {
  //   if (data.isEmpty) return SizedBox();

  //   final points = data.take(10).toList().reversed.toList();

  //   List<FlSpot> tempSpots = [];
  //   List<FlSpot> gasSpots = [];
  //   List<FlSpot> pressureSpots = [];

  //   for (int i = 0; i < points.length; i++) {
  //     final d = points[i];

  //     tempSpots.add(FlSpot(i.toDouble(), (d['temperature'] ?? 0).toDouble()));
  //     gasSpots.add(FlSpot(i.toDouble(), (d['gas'] ?? 0).toDouble()));
  //     pressureSpots.add(FlSpot(i.toDouble(), (d['pressure'] ?? 0).toDouble()));
  //   }

  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(24),
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
  //       ),
  //       border: Border.all(color: Colors.red.withOpacity(0.3)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "SENSOR TREND",
  //           style: GoogleFonts.orbitron(color: Colors.white),
  //         ),

  //         SizedBox(height: 10),

  //         // 🔥 LEGEND
  //         Row(
  //           children: [
  //             legend("Temp", Colors.red),
  //             SizedBox(width: 10),
  //             legend("Gas", Colors.orange),
  //             SizedBox(width: 10),
  //             legend("Pressure", Colors.blue),
  //           ],
  //         ),

  //         SizedBox(height: 10),

  //         SizedBox(
  //           height: 160,
  //           child: LineChart(
  //             LineChartData(
  //               titlesData: FlTitlesData(show: false),
  //               gridData: FlGridData(show: false),
  //               borderData: FlBorderData(show: false),

  //               lineBarsData: [
  //                 // 🔴 TEMP
  //                 LineChartBarData(
  //                   spots: tempSpots,
  //                   isCurved: true,
  //                   color: Colors.red,
  //                   barWidth: 3,
  //                   dotData: FlDotData(show: false),
  //                 ),

  //                 // 🟠 GAS
  //                 LineChartBarData(
  //                   spots: gasSpots,
  //                   isCurved: true,
  //                   color: Colors.orange,
  //                   barWidth: 3,
  //                   dotData: FlDotData(show: false),
  //                 ),

  //                 // 🔵 PRESSURE
  //                 LineChartBarData(
  //                   spots: pressureSpots,
  //                   isCurved: true,
  //                   color: Colors.blue,
  //                   barWidth: 3,
  //                   dotData: FlDotData(show: false),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
        ),
        border: Border.all(color: Colors.white12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "RIWAYAT DATA",
            style: GoogleFonts.orbitron(color: Colors.white),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 280,

            child: ListView.builder(
              itemCount: data.length > 10 ? 10 : data.length,

              itemBuilder: (context, index) {
                final d = data[index];

                final time = DateTime.parse(d['created_at']).toLocal();

                final avgTemp = averageLog('temperature_kf');
                final avgGas = averageLog('gas_kf');
                final avgPressure = averageLog('pressure_kf');

                final status = VolcanoAnalyzer.getStatus(
                  temp: (d['temperature_kf'] ?? 0).toDouble(),

                  gas: (d['gas_kf'] ?? 0).toDouble(),

                  pressure: (d['pressure_kf'] ?? 0).toDouble(),

                  avgTemp: avgTemp,

                  avgGas: avgGas,

                  avgPressure: avgPressure,
                );

                final statusColor = VolcanoAnalyzer.getColor(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}",
                            style: GoogleFonts.rajdhani(color: Colors.white70),
                          ),

                          Text(
                            status,
                            style: GoogleFonts.orbitron(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Suhu : ${((d['temperature_kf'] ?? 0) as num).toStringAsFixed(2)} °C",
                        style: GoogleFonts.rajdhani(color: Colors.white),
                      ),

                      Text(
                        "Kelembapan : ${((d['humidity_kf'] ?? 0) as num).toStringAsFixed(2)} %",
                        style: GoogleFonts.rajdhani(color: Colors.white),
                      ),

                      Text(
                        "Gas : ${((d['gas_kf'] ?? 0) as num).toStringAsFixed(2)} ADC",
                        style: GoogleFonts.rajdhani(color: Colors.white),
                      ),

                      Text(
                        "Tekanan : ${((d['pressure_kf'] ?? 0) as num).toStringAsFixed(2)} hPa",
                        style: GoogleFonts.rajdhani(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    if (data.isEmpty) return SizedBox();

    final latest = data.first;

    final double lat = (latest['lat'] as num?)?.toDouble() ?? 0.0;
    final double lon = (latest['lon'] as num?)?.toDouble() ?? 0.0;

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
                userAgentPackageName: 'com.example.merapi_app',
                subdomains: ['a', 'b', 'c', 'd'],
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

  Widget miniSensorCard(
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
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [const Color(0xFF1A1A1A), color.withOpacity(0.25)],
            ),
            border: Border.all(color: color.withOpacity(0.4)),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),

              const Spacer(),

              Text(title, style: GoogleFonts.rajdhani(color: Colors.white70)),

              const SizedBox(height: 8),

              Text(
                value,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LORA =================
  Widget loraCard() {
    if (data.isEmpty) return const SizedBox();

    final latest = data.first;

    final createdAt = DateTime.parse(latest['created_at']).toLocal();

    final connected = DateTime.now().difference(createdAt).inSeconds < 15;

    final rssi = (latest['rssi'] ?? 0).toInt();

    String quality = "Buruk";

    if (rssi > -70) {
      quality = "Sangat Baik";
    } else if (rssi > -90) {
      quality = "Baik";
    } else if (rssi > -110) {
      quality = "Cukup";
    }

    final displayQuality = connected ? quality : "Tidak Ada Sinyal";

    final displayRssi = connected ? "$rssi dBm" : "--";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoraPage(data: data)),
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
          border: Border.all(
            color: connected
                ? Colors.green.withOpacity(0.4)
                : Colors.red.withOpacity(0.4),
          ),
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
                    color: connected
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.wifi,
                    color: connected ? Colors.green : Colors.red,
                  ),
                ),
                CircleAvatar(
                  radius: 5,
                  backgroundColor: connected ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Koneksi LoRa",
              style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              connected ? "TERHUBUNG" : "TIDAK TERHUBUNG",
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "Kualitas Sinyal: $displayQuality",
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),

            Text(
              "RSSI: $displayRssi",
              style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 12),
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
        // margin: const EdgeInsets.only(bottom: 18),
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

  Widget temperatureCard(Map latest) {
    final double humidity = (latest['humidity_kf'] as num?)?.toDouble() ?? 0;

    final double temp = (latest['temperature_kf'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TemperaturePage(data: data)),
        );
      },

      child: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          gradient: LinearGradient(
            colors: [const Color(0xFF1A1A1A), Colors.orange.withOpacity(0.25)],
          ),

          border: Border.all(color: Colors.white24, width: 1.5),

          // boxShadow: [
          //   BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20),
          // ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.thermostat,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Suhu",
                        style: GoogleFonts.rajdhani(color: Colors.white70),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${temp.toStringAsFixed(1)}°C",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.lightBlue,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Kelembapan",
                        style: GoogleFonts.rajdhani(color: Colors.white70),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.lightBlue.withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${humidity.toStringAsFixed(1)}%",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    "Ekspor Data",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Unduh data hasil pemantauan",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
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
          "MONITORING AKTIVITAS VULKANIK",
          style: GoogleFonts.orbitron(
            fontSize: 14,
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
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                    ),

                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.radar, color: Colors.green),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DATA TERAKHIR",
                              style: GoogleFonts.orbitron(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              getLastUpdate(),
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                analysisCard(),
                loraCard(),

                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),

                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(color: Colors.white12, width: 1),
                        ),

                        child: Column(
                          children: [
                            temperatureCard(latest),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                miniSensorCard(
                                  "Gas",
                                  "${(latest['gas_kf'] ?? 0).toStringAsFixed(2)} ADC",
                                  Icons.cloud,
                                  Colors.purple,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GasPage(data: data),
                                    ),
                                  ),
                                ),

                                miniSensorCard(
                                  "Tekanan",
                                  "${format(latest['pressure_kf'])} hPa",
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 📈 CHART
                // buildMultiChart(),
                // 📜 LOG
                buildLog(),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "LOKASI NODE SENSOR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                // 📍 MAP
                buildMap(),

                exportCard(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
