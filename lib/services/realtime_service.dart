import 'package:firebase_database/firebase_database.dart';
import '../session.dart';

class RealtimeService {
  final DatabaseReference database = FirebaseDatabase.instance.ref("bookings");

  Future<void> tambahBooking({
    required String nama,
    required String ruangan,
    required String keperluan,
  }) async {
    try {
      final newBooking = database.push();

      await newBooking.set({
        "id": newBooking.key,
        "username": currentUsername,
        "nama": nama,
        "ruangan": ruangan,
        "keperluan": keperluan,
        "status": "Menunggu",
      });

      print("DATA BERHASIL DISIMPAN");
    } catch (e) {
      print("ERROR DATABASE: $e");
    }
  }
}
