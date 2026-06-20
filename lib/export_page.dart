import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

const bgColor = Color(0xFF0D0D0D);
const cardColor = Color(0xFF1A1A1A);
const lavaRed = Color(0xFFFF3B30);

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  DateTime selectedDate = DateTime.now();

  // ================= DOWNLOAD =================
  Future<void> downloadFile(String url) async {
    try {
      final dir = await getExternalStorageDirectory();

      if (dir == null) {
        throw Exception("Penyimpanan Tidak Ditemukan");
      }

      await FlutterDownloader.enqueue(
        url: url,
        savedDir: dir.path,
        fileName: "merapi_data_${DateTime.now().millisecondsSinceEpoch}.csv",
        showNotification: true,
        openFileFromNotification: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text("File disimpan di:\n${dir.path}"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("gagal mengunduh file: $e")));
    }
  }

  // ================= PICK DATE =================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
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
  Widget exportButton() {
    return GestureDetector(
      onTap: () {
        final date = DateFormat("yyyy-MM-dd").format(selectedDate);

        final url =
            "https://merapi-backend-production.up.railway.app/api/v1/export?date=$date";

        downloadFile(url);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: lavaRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "EKSPOR CSV",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ekspor Data", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ================= DATE CARD =================
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
                    "Pilih Tanggal Ekspor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  buildBox(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            DateFormat("dd MMMM yyyy").format(selectedDate),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        IconButton(
                          onPressed: pickDate,
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= CSV CONTENT =================
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Isi DataCSV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "• Temperature (Raw & Kalman)\n"
                    "• Humidity (Raw & Kalman)\n"
                    "• Gas (Raw & Kalman)\n"
                    "• Pressure (Raw & Kalman)\n"
                    "• GPS Coordinates\n"
                    "• Satellites\n"
                    "• RSSI\n"
                    "• SNR\n"
                    "• Timestamp",

                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= EXPORT =================
            exportButton(),

            const SizedBox(height: 12),

            // ================= FILE LOCATION =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final dir = await getExternalStorageDirectory();

                  if (dir == null) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 8),
                      content: Text("Lokasi File:\n${dir.path}"),
                    ),
                  );
                },

                icon: const Icon(Icons.folder),

                label: const Text("TAMPILKAN LOKASI FILE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
