import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../session.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref("bookings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Peminjaman"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.logout),

          //   onPressed: () {
          //     Navigator.pushReplacement(
          //       context,

          //       MaterialPageRoute(builder: (context) => const LoginPage()),
          //     );
          //   },
          // ),
        ],
      ),

      body: StreamBuilder(
        stream: database.onValue,

        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // kalau kosong
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("Belum ada riwayat"));
          }

          // ambil data
          Map data = snapshot.data!.snapshot.value as Map;

          List bookingList =
              data.entries
                  .where((entry) {
                    var bookingData = entry.value;

                    return bookingData["username"] == currentUsername &&
                        bookingData["status"] != "Menunggu";
                  })
                  .toList()
                  .reversed
                  .toList();

          if (bookingList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Belum ada riwayat peminjaman",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: bookingList.length,

            itemBuilder: (context, index) {
              var booking = bookingList[index];
              var bookingData = booking.value;

              return Card(
                margin: EdgeInsets.all(10),

                child: ListTile(
                  title: Text(bookingData["ruangan"]),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama: ${bookingData["nama"]}"),

                      Text("Keperluan: ${bookingData["keperluan"]}"),

                      Text("Status: ${bookingData["status"]}"),

                      SizedBox(height: 10),

                      bookingData["status"] == "Menunggu"
                          ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),

                            onPressed: () async {
                              await database.child(booking.key).remove();
                            },

                            child: Text("Batalkan"),
                          )
                          : SizedBox(),

                      bookingData["status"] == "Disetujui"
                          ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),

                            onPressed: () async {
                              await database.child(booking.key).update({
                                "status": "Menunggu Konfirmasi",
                              });
                            },

                            child: Text("Selesaikan Peminjaman"),
                          )
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
