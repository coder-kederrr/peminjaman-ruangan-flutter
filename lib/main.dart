import 'package:flutter/material.dart';

// import firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

// import halaman utama
import 'pages/login_page.dart';

void main() async {
  // wajib supaya firebase bisa jalan sebelum app dibuka
  WidgetsFlutterBinding.ensureInitialized();

  // koneksi firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseDatabase.instance.databaseURL =
      "https://peminjaman-ruangan-6e7ca-default-rtdb.asia-southeast1.firebasedatabase.app/";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Peminjaman Ruangan',

      theme: ThemeData(primarySwatch: Colors.deepPurple),

      home: LoginPage(),
    );
  }
}
