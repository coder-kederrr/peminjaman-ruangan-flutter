import 'package:flutter/material.dart';
import 'form_page.dart'; // nanti buat tambah ruangan
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onBookingSuccess;

  const HomePage({super.key, required this.onBookingSuccess});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference bookingDatabase = FirebaseDatabase.instance.ref(
    "bookings",
  );

  final DatabaseReference roomDatabase = FirebaseDatabase.instance.ref("rooms");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 APPBAR
      appBar: AppBar(
        title: Text("Daftar Ruangan"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              bool? logout = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),

                    content: const Text("Apakah Anda yakin ingin logout?"),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Batal"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),

                        onPressed: () {
                          Navigator.pop(context, true);
                        },

                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (logout == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),

      // 🔹 LIST RUANGAN
      body: StreamBuilder(
        stream: roomDatabase.onValue,
        builder: (context, roomSnapshot) {
          if (!roomSnapshot.hasData ||
              roomSnapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada ruangan"));
          }

          Map roomData = roomSnapshot.data!.snapshot.value as Map;

          List roomList = roomData.entries.toList();
          roomList.sort(
            (a, b) => a.value["nama"].toString().compareTo(
              b.value["nama"].toString(),
            ),
          );

          return StreamBuilder(
            stream: bookingDatabase.onValue,
            builder: (context, bookingSnapshot) {
              Map bookingData = {};

              if (bookingSnapshot.hasData &&
                  bookingSnapshot.data!.snapshot.value != null) {
                bookingData = bookingSnapshot.data!.snapshot.value as Map;
              }

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: roomList.length,

                itemBuilder: (context, index) {
                  var room = roomList[index].value;

                  // cek apakah ruangan sudah dipinjam
                  bool dipakai = false;

                  bookingData.forEach((key, value) {
                    if (value["ruangan"] == room["nama"] &&
                        (value["status"] == "Disetujui" ||
                            value["status"] == "Menunggu Konfirmasi")) {
                      dipakai = true;
                    }
                  });

                  return Card(
                    elevation: 4,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),

                    margin: EdgeInsets.symmetric(vertical: 8),

                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(10),

                          leading: Icon(
                            Icons.meeting_room,
                            color: Colors.deepPurple,
                          ),

                          title: Text(
                            room["nama"]!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("Lokasi: ${room["lokasi"]}"),

                              Text("Kapasitas: ${room["kapasitas"]} orang"),

                              Text(
                                dipakai
                                    ? "Status: Dipakai"
                                    : "Status: Tersedia",

                                style: TextStyle(
                                  color: dipakai ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 10),

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  dipakai ? Colors.grey : Colors.deepPurple,

                              foregroundColor: Colors.white,
                            ),

                            onPressed:
                                dipakai
                                    ? null
                                    : () async {
                                      final result = await Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder:
                                              (context) => FormPage(
                                                namaRuangan: room["nama"]!,
                                              ),
                                        ),
                                      );

                                      if (result != null) {
                                        // bookings.add(result);

                                        widget.onBookingSuccess(1);
                                      }
                                    },

                            child: Text(dipakai ? "Sudah Dipinjam" : "Pinjam"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
