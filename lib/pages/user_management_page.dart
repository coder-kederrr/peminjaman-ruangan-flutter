import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseReference userDatabase = FirebaseDatabase.instance.ref("users");

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void showTambahUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah User"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                await tambahUser();
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> tambahUser() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DataSnapshot snapshot = await userDatabase.get();

    if (snapshot.value != null) {
      Map data = snapshot.value as Map;

      bool sudahAda = false;

      data.forEach((key, value) {
        if (value["username"] == username) {
          sudahAda = true;
        }
      });

      if (sudahAda) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username sudah digunakan"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    await userDatabase.push().set({
      "username": username,
      "password": password,
      "role": "user",
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User berhasil ditambahkan"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> hapusUser(dynamic user) async {
    bool? hapus = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus User"),
          content: Text("Yakin ingin menghapus ${user.value["username"]} ?"),
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
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (hapus == true) {
      await userDatabase.child(user.key.toString()).remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void editUser(dynamic user) {
    usernameController.text = user.value["username"]?.toString() ?? "";

    passwordController.text = user.value["password"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit User"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.trim().isEmpty ||
                    passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua field wajib diisi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await userDatabase.child(user.key.toString()).update({
                  "username": usernameController.text.trim(),
                  "password": passwordController.text.trim(),
                  "role": "user",
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User berhasil diperbarui"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola User"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.person_add, color: Colors.white),

        onPressed: () {
          usernameController.clear();
          passwordController.clear();

          showTambahUser();
        },
      ),

      body: StreamBuilder(
        stream: userDatabase.onValue,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada user"));
          }

          Map data = snapshot.data!.snapshot.value as Map;

          // Hanya tampilkan role user
          List userList =
              data.entries.where((entry) {
                return entry.value["role"] == "user";
              }).toList();

          userList.sort(
            (a, b) => a.value["username"].toString().compareTo(
              b.value["username"].toString(),
            ),
          );

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              var user = userList[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  title: Text(user.value["username"]),

                  subtitle: Text("Role : ${user.value["role"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          editUser(user);
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          hapusUser(user);
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
