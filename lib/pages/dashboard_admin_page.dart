import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

final DatabaseReference bookingDatabase = FirebaseDatabase.instance.ref(
  "bookings",
);

final DatabaseReference roomDatabase = FirebaseDatabase.instance.ref("rooms");

final DatabaseReference userDatabase = FirebaseDatabase.instance.ref("users");

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget statCard(IconData icon, String title, String value) {
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: Colors.deepPurple),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 10),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
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
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Map root = snapshot.data!.snapshot.value as Map;

          Map bookings = {};
          Map rooms = {};
          Map users = {};

          if (root["bookings"] != null) {
            bookings = Map.from(root["bookings"]);
          }

          if (root["rooms"] != null) {
            rooms = Map.from(root["rooms"]);
          }

          if (root["users"] != null) {
            users = Map.from(root["users"]);
          }

          int totalRuangan = rooms.length;
          int totalUser = users.length;
          int totalBooking = bookings.length;

          int menunggu = 0;
          int selesai = 0;
          int ditolak = 0;

          bookings.forEach((key, value) {
            if (value["status"] == "Menunggu") {
              menunggu++;
            }

            if (value["status"] == "Selesai") {
              selesai++;
            }

            if (value["status"] == "Ditolak") {
              ditolak++;
            }
          });

          return Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                statCard(Icons.people, "Total User", totalUser.toString()),

                statCard(
                  Icons.meeting_room,
                  "Total Ruangan",
                  totalRuangan.toString(),
                ),

                statCard(
                  Icons.pending_actions,
                  "Menunggu",
                  menunggu.toString(),
                ),

                statCard(Icons.check_circle, "Selesai", selesai.toString()),

                statCard(Icons.cancel, "Ditolak", ditolak.toString()),

                statCard(
                  Icons.assignment,
                  "Total Booking",
                  totalBooking.toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
