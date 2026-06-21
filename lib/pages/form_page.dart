import 'package:flutter/material.dart';
import '../services/realtime_service.dart';
import '../session.dart';

final realtimeService = RealtimeService();

class FormPage extends StatefulWidget {
  final String namaRuangan; // data dari halaman sebelumnya

  const FormPage({super.key, required this.namaRuangan});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // controller untuk input

  TextEditingController keperluanController = TextEditingController();

  String? errorKeperluan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Peminjaman"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 NAMA RUANGAN (tidak bisa diubah)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Ruangan",
                border: OutlineInputBorder(),
                hintText: widget.namaRuangan,
              ),
            ),

            SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Peminjam",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentUsername ?? "-",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 KEPERLUAN
            TextField(
              controller: keperluanController,
              decoration: InputDecoration(
                labelText: "Keperluan",
                border: OutlineInputBorder(),
                errorText: errorKeperluan,
              ),
            ),

            SizedBox(height: 20),

            // 🔹 TOMBOL SIMPAN
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                setState(() {
                  errorKeperluan = null;
                });
                String nama = currentUsername ?? "";
                String keperluan = keperluanController.text;

                bool valid = true;

                if (keperluan.isEmpty) {
                  errorKeperluan = "Keperluan wajib diisi";
                  valid = false;
                }

                if (!valid) {
                  setState(() {});
                  return;
                }

                // 🔥 simpan ke realtime database dulu
                await realtimeService.tambahBooking(
                  nama: currentUsername ?? "",
                  ruangan: widget.namaRuangan,
                  keperluan: keperluanController.text,
                );

                // 🔥 SNACKBAR
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Peminjaman berhasil diajukan"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // 🔥 delay dikit biar snackbar keliatan
                Future.delayed(Duration(milliseconds: 500), () {
                  Navigator.pop(context, {
                    "ruangan": widget.namaRuangan,
                    "nama": nama,
                    "keperluan": keperluan,
                    "status": "Menunggu",
                  });
                });
              },
              child: Text("Ajukan Peminjaman"),
            ),
          ],
        ),
      ),
    );
  }
}
