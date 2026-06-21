import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref("bookings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Peminjaman Saya"),
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
            return Center(child: Text("Belum ada peminjaman"));
          }

          // ambil data firebase
          Map data = snapshot.data!.snapshot.value as Map;

          List bookingList =
              data.entries
                  .where((entry) {
                    var bookingData = entry.value;

                    // hanya tampil yang masih menunggu
                    return bookingData["status"] == "Menunggu";
                  })
                  .toList()
                  .reversed
                  .toList();

          // kalau kosong
          if (bookingList.isEmpty) {
            return Center(child: Text("Tidak ada peminjaman aktif"));
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

                  subtitle: Text(
                    "${bookingData["nama"]} - ${bookingData["keperluan"]}",
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        bookingData["status"],
                        style: TextStyle(color: Colors.orange),
                      ),

                      SizedBox(width: 10),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),

                        onPressed: () async {
                          try {
                            await database
                                .child(booking.key.toString())
                                .remove();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Peminjaman dibatalkan"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            print("ERROR HAPUS: $e");
                          }
                        },
                      ),
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
