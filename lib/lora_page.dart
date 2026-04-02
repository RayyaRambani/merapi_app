import 'package:flutter/material.dart';

const bgColor = Color(0xFF0D0D0D);
const cardColor = Color(0xFF1A1A1A);

class LoraPage extends StatelessWidget {
  const LoraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LoRa Connection"),
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
          connectionCard(),

          // ================= SIGNAL =================
          sectionCard(
            "Signal Strength",
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "87% - Excellent",
                  style: TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // ================= HISTORY =================
          sectionCard(
            "Signal History",
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: const Text(
                "Chart Placeholder",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          // ================= METRICS =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: smallCard("Packets Sent", "12,466", Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(child: smallCard("Packets Lost", "23", Colors.orange)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: smallCard("Success Rate", "99.82%", Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(child: smallCard("Uptime", "47d 13h", Colors.blue)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= NETWORK =================
          infoCard("Network Information", [
            item("Frequency", "915 MHz"),
            item("Bandwidth", "125 kHz"),
            item("Spreading Factor", "SF7"),
            item("Coding Rate", "4/5"),
            item("TX Power", "14 dBm"),
            item("Range", "~15 km"),
          ]),

          // ================= DEVICE =================
          infoCard("Device Information", [
            item("Gateway ID", "VLC-GW-001-A3F2"),
            item("Node Address", "0x26041A7B"),
            item("Network Session", "Active - Encrypted"),
          ]),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= CONNECTION CARD =================
  Widget connectionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.9),
            Colors.green.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Connection Status",
                style: TextStyle(color: Colors.white70),
              ),
              Icon(Icons.check_circle, color: Colors.white),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Connected",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              column("Signal", "87%"),
              column("Quality", "Excellent"),
              column("Rate", "5.47 kbps"),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================
  Widget sectionCard(String title, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          child,
        ],
      ),
    );
  }

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
