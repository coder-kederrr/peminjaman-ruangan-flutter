import 'package:flutter/material.dart';
// import halaman home biar bisa pindah halaman
import 'main_page.dart';
import 'package:firebase_database/firebase_database.dart';
import '../session.dart';
import 'admin_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorUsername;
  String? errorPassword;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final DatabaseReference userDatabase = FirebaseDatabase.instance.ref("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background utama (ungu)
      backgroundColor: Colors.deepPurple,

      body: SafeArea(
        // biar nggak ketabrak notch / status bar HP
        child: Center(
          child: SingleChildScrollView(
            // biar bisa di-scroll kalau layar kecil
            child: Padding(
              padding: EdgeInsets.all(24), // jarak dari pinggir layar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // full lebar
                children: [
                  // 🔹 JUDUL APLIKASI
                  Text(
                    "Peminjaman Ruangan",
                    textAlign: TextAlign.center, // rata tengah
                    style: TextStyle(
                      color: Colors.white, // warna teks putih
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 40), // jarak ke bawah
                  // 🔹 CONTAINER (CARD PUTIH)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, // background putih
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // sudut melengkung
                    ),

                    child: Column(
                      children: [
                        // 🔹 INPUT EMAIL
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(),
                            errorText: errorUsername,
                          ),
                        ),

                        SizedBox(height: 15),

                        // 🔹 INPUT PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                            errorText: errorPassword,
                          ),
                        ),

                        SizedBox(height: 20),

                        // 🔹 TOMBOL LOGIN
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // warna tombol
                            foregroundColor: Colors.white, // warna teks
                            minimumSize: Size(
                              double.infinity,
                              50,
                            ), // full lebar
                          ),
                          onPressed: () async {
                            String username = usernameController.text.trim();
                            String password = passwordController.text.trim();

                            // validasi kosong
                            // reset error dulu
                            setState(() {
                              errorUsername = null;
                              errorPassword = null;
                            });

                            bool valid = true;

                            // validasi username
                            if (username.isEmpty) {
                              errorUsername = "Username wajib diisi";
                              valid = false;
                            }

                            // validasi password
                            if (password.isEmpty) {
                              errorPassword = "Password wajib diisi";
                              valid = false;
                            }

                            // kalau tidak valid
                            if (!valid) {
                              setState(() {});
                              return;
                            }

                            // Login Admin
                            if (username == "admin" && password == "admin123") {
                              currentUsername = "admin";
                              currentRole = "admin";

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminMainPage(),
                                ),
                              );

                              return;
                            }

                            // Cek user di Firebase
                            DataSnapshot snapshot = await userDatabase.get();

                            if (snapshot.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data user tidak ditemukan"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Map data = snapshot.value as Map;

                            bool ditemukan = false;

                            for (var item in data.entries) {
                              if (item.value["username"] == username) {
                                ditemukan = true;

                                if (item.value["password"] == password) {
                                  currentUsername = item.value["username"];
                                  currentRole = item.value["role"];

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainPage(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Password salah"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }

                                break;
                              }
                            }

                            if (!ditemukan) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Username tidak ditemukan"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
