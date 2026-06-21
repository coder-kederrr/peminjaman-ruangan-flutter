import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref("bookings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approval Page"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        
      ),

      body: StreamBuilder(
        stream: database.onValue,
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // kalau tidak ada data
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("Belum ada booking"));
          }

          // ambil data dari firebase
          Map data = snapshot.data!.snapshot.value as Map;

          List bookingList = data.entries.toList().reversed.toList();

          return ListView.builder(
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              var booking = bookingList[index];
              var bookingData = booking.value;

              return Card(
                margin: EdgeInsets.all(10),

                child: Padding(
                  padding: EdgeInsets.all(10),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookingData["ruangan"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text("Nama: ${bookingData["nama"]}"),
                      Text("Keperluan: ${bookingData["keperluan"]}"),
                      Text("Status: ${bookingData["status"]}"),

                      SizedBox(height: 10),

                      bookingData["status"] == "Menunggu"
                          ? Row(
                            children: [
                              // tombol approve
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () async {
                                  await database.child(booking.key).update({
                                    "status": "Disetujui",
                                  });
                                },

                                child: Text("Approve"),
                              ),

                              SizedBox(width: 10),

                              // tombol tolak
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () async {
                                  await database.child(booking.key).update({
                                    "status": "Ditolak",
                                  });
                                },

                                child: Text("Tolak"),
                              ),
                            ],
                          )
                          : Text(
                            "Booking sudah diproses",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                      bookingData["status"] == "Menunggu Konfirmasi"
                          ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),

                                  onPressed: () async {
                                    await database.child(booking.key).update({
                                      "status": "Selesai",
                                    });
                                  },

                                  child: Text("Konfirmasi Selesai"),
                                ),
                              ),
                            ],
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
