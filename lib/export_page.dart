import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart'; // 🔥 WAJIB

const bgColor = Color(0xFF0D0D0D);
const cardColor = Color(0xFF1A1A1A);
const lavaRed = Color(0xFFFF3B30);

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String selectedType = "All";
  String selectedFilter = "date";

  DateTime selectedDate = DateTime.now();
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();

  // ================= DOWNLOAD =================
  Future downloadFile(String url) async {
    try {
      final dir = await getExternalStorageDirectory();

      if (dir == null) throw Exception("Storage tidak ditemukan");

      await FlutterDownloader.enqueue(
        url: url,
        savedDir: dir.path, // 🔥 SAFE PATH
        fileName: "merapi_data_${DateTime.now().millisecondsSinceEpoch}.csv",
        showNotification: true,
        openFileFromNotification: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download dimulai ke: ${dir.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error download: $e")));
    }
  }

  // ================= DATE PICK =================
  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= TYPE CARD =================
  Widget typeCard(String title, IconData icon) {
    final isSelected = selectedType == title;

    return GestureDetector(
      onTap: () => setState(() => selectedType = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? lavaRed.withOpacity(0.2) : Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? lavaRed : Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.check_circle, color: lavaRed, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER TAB =================
  Widget filterTab(String label, String value) {
    final isActive = selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? lavaRed : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // ================= BOX =================
  Widget buildBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: child,
    );
  }

  // ================= EXPORT BUTTON =================
  Widget exportButton(String text) {
    return GestureDetector(
      onTap: () {
        String url = "";

        if (selectedFilter == "date") {
          final date = DateFormat("yyyy-MM-dd").format(selectedDate);
          url =
              "https://merapi-backend-production.up.railway.app/api/v1/export?date=$date";
        }

        if (selectedFilter == "week") {
          final date = DateFormat("yyyy-MM-dd").format(selectedDate);
          url =
              "https://merapi-backend-production.up.railway.app/api/v1/export?date=$date";
        }

        if (selectedFilter == "range") {
          final date = DateFormat("yyyy-MM-dd").format(fromDate);
          url =
              "https://merapi-backend-production.up.railway.app/api/v1/export?date=$date";
        }

        // 🔥 VALIDASI URL
        if (url.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("URL tidak valid")));
          return;
        }

        downloadFile(url);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: lavaRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Export Data", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= SELECT TYPE =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Data Type",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      typeCard("All", Icons.bar_chart),
                      typeCard("Temperature", Icons.thermostat),
                      typeCard("Gas", Icons.cloud),
                      typeCard("Pressure", Icons.speed),
                      typeCard("LoRa", Icons.wifi),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= FILTER + FORM =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        filterTab("By Date", "date"),
                        filterTab("By Week", "week"),
                        filterTab("Date Range", "range"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (selectedFilter == "date") ...[
                    const Text(
                      "Select Date",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    buildBox(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              DateFormat("MMMM d, yyyy").format(selectedDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: pickDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    exportButton("Export Data"),
                  ],

                  if (selectedFilter == "week") ...[
                    const Text(
                      "Select Week",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    buildBox(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Week of ${DateFormat("MMMM d, yyyy").format(selectedDate)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    exportButton("Export Week Data"),
                  ],

                  if (selectedFilter == "range") ...[
                    const Text(
                      "From Date",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    buildBox(
                      child: Text(
                        DateFormat("MMMM d, yyyy").format(fromDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "To Date",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    buildBox(
                      child: Text(
                        DateFormat("MMMM d, yyyy").format(toDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    exportButton("Export Range Data"),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
