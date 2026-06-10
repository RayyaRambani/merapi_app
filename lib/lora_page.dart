import 'package:flutter/material.dart';

const bgColor = Color(0xFF0D0D0D);
const cardColor = Color(0xFF1A1A1A);

class LoraPage extends StatelessWidget {
  final List data;

  const LoraPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final latest = data.isNotEmpty ? data.first : {};

    final int rssi = (latest['rssi'] ?? 0).toInt();

    final double snr = (latest['snr'] ?? 0).toDouble();

    final createdAt = latest.isNotEmpty
        ? DateTime.parse(latest['created_at']).toLocal()
        : DateTime.now();

    final bool connected = DateTime.now().difference(createdAt).inSeconds < 15;

    String quality = "Poor";

    if (rssi > -70) {
      quality = "Excellent";
    } else if (rssi > -90) {
      quality = "Good";
    } else if (rssi > -110) {
      quality = "Fair";
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LoRa Connection", style: TextStyle(color: Colors.white)),
            Text(
              "Network status",
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // ================= STATUS =================
          connectionCard(
            connected,
            rssi,
            snr,
            quality,
          ),

          

          // ================= METRICS =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: smallCard("RSSI", "$rssi dBm", Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                  child: smallCard(
                    "SNR",
                    "${snr.toStringAsFixed(2)} dB",
                    Colors.cyan,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= NETWORK =================
          infoCard("LoRa Information", [
            item("Frequency", "915 MHz"),
            item("Bandwidth", "125 kHz"),
            item("Spreading Factor", "SF7"),
            item("TX Power", "17 dBm"),
            // item("Node ID", "node_1"),
          ]),



          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= CONNECTION CARD =================
  Widget connectionCard(bool connected, int rssi, double snr, String quality) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: connected
              ? [Colors.green.withOpacity(0.9), Colors.green.withOpacity(0.6)]
              : [Colors.red.withOpacity(0.9), Colors.red.withOpacity(0.6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Connection Status",
                style: TextStyle(color: Colors.white70),
              ),
              Icon(
                connected ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            connected ? "Connected" : "Disconnected",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              column("RSSI", "$rssi dBm"),
              column("Quality", quality),
              column("SNR", snr.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================
  

  // ================= SMALL CARD =================
  Widget smallCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
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
    );
  }

  // ================= INFO CARD =================
  Widget infoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ================= ROW ITEM =================
  Widget item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  static Widget column(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
