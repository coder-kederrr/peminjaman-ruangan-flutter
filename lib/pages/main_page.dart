import 'package:flutter/material.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'riwayat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 🔹 index tab yang aktif
  int _selectedIndex = 0;

  // 🔹 list halaman
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(onBookingSuccess: changeTab), // 🔥 kirim fungsi
      BookingPage(),
      RiwayatPage(),
    ];
  }

  // 🔹 fungsi pindah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 tampilkan halaman sesuai index
      body: _pages[_selectedIndex],

      // 🔹 bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // tab aktif
        onTap: _onItemTapped, // saat diklik

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Peminjaman",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
        ],
      ),
    );
  }
}
