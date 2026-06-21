import 'package:flutter/material.dart';
// Removed direct import of LoginPage to avoid missing-file URI error.
// Use named route '/login' when navigating after logout.
import '../session.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  bool? logout = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text(
          "Apakah Anda yakin ingin logout?",
        ),
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
    currentUsername = "";
    currentRole = "";

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}