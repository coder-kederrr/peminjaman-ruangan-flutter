import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomManagementPage extends StatefulWidget {
  const RoomManagementPage({super.key});

  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  final DatabaseReference roomDatabase = FirebaseDatabase.instance.ref("rooms");
  final TextEditingController namaController = TextEditingController();

  final TextEditingController lokasiController = TextEditingController();

  final TextEditingController kapasitasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Ruangan"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),

        //     onPressed: () {
        //       // nanti isi tambah ruangan
        //     },
        //   ),
        // ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,

        child: const Icon(Icons.add, color: Colors.white),

        onPressed: () {
          showDialog(
            context: context,

            builder: (context) {
              return AlertDialog(
                title: const Text("Tambah Ruangan"),

                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Ruangan",
                        ),
                      ),

                      TextField(
                        controller: lokasiController,
                        decoration: const InputDecoration(labelText: "Lokasi"),
                      ),

                      TextField(
                        controller: kapasitasController,
                        decoration: const InputDecoration(
                          labelText: "Kapasitas",
                        ),
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
                      if (namaController.text.trim().isEmpty ||
                          lokasiController.text.trim().isEmpty ||
                          kapasitasController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Semua field wajib diisi"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (int.tryParse(kapasitasController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Kapasitas harus berupa angka"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      await roomDatabase.push().set({
                        "nama": namaController.text.trim(),
                        "lokasi": lokasiController.text.trim(),
                        "kapasitas": kapasitasController.text.trim(),
                      });

                      namaController.clear();
                      lokasiController.clear();
                      kapasitasController.clear();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ruangan berhasil ditambahkan"),
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
        },
      ),

      body: StreamBuilder(
        stream: roomDatabase.onValue,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada ruangan"));
          }

          Map data = snapshot.data!.snapshot.value as Map;

          List roomList = data.entries.toList();

          roomList.sort(
            (a, b) => a.value["nama"].toString().compareTo(
              b.value["nama"].toString(),
            ),
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Jumlah Ruangan",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "${roomList.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: roomList.length,
                  itemBuilder: (context, index) {
                    var room = roomList[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.meeting_room,
                          color: Colors.deepPurple,
                        ),
                        title: Text(room.value["nama"]),
                        subtitle: Text(
                          "${room.value["lokasi"]} | Kapasitas ${room.value["kapasitas"]}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                namaController.text = room.value["nama"];
                                lokasiController.text = room.value["lokasi"];
                                kapasitasController.text =
                                    room.value["kapasitas"];

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Ruangan"),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: namaController,
                                              decoration: const InputDecoration(
                                                labelText: "Nama Ruangan",
                                              ),
                                            ),
                                            TextField(
                                              controller: lokasiController,
                                              decoration: const InputDecoration(
                                                labelText: "Lokasi",
                                              ),
                                            ),
                                            TextField(
                                              controller: kapasitasController,
                                              decoration: const InputDecoration(
                                                labelText: "Kapasitas",
                                              ),
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
                                            if (namaController.text
                                                    .trim()
                                                    .isEmpty ||
                                                lokasiController.text
                                                    .trim()
                                                    .isEmpty ||
                                                kapasitasController.text
                                                    .trim()
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Semua data wajib diisi",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            int? kapasitas = int.tryParse(
                                              kapasitasController.text,
                                            );

                                            if (kapasitas == null ||
                                                kapasitas <= 0) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Kapasitas harus berupa angka lebih dari 0",
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            await roomDatabase
                                                .child(room.key.toString())
                                                .update({
                                                  "nama": namaController.text,
                                                  "lokasi":
                                                      lokasiController.text,
                                                  "kapasitas":
                                                      kapasitasController.text,
                                                });
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Simpan"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? hapus = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Hapus Ruangan"),
                                      content: Text(
                                        "Yakin ingin menghapus ${room.value["nama"]} ?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Batal"),
                                        ),
                                        ElevatedButton(
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
                                  await roomDatabase
                                      .child(room.key.toString())
                                      .remove();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
