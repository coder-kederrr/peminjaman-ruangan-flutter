import 'package:flutter/material.dart';
import 'dashboard_admin_page.dart';
import 'approval_page.dart';
import 'room_management_page.dart';
import 'user_management_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardAdminPage(),
      ApprovalPage(),
      RoomManagementPage(),
      UserManagementPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Approval",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: "Ruangan",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.people), label: "User"),
        ],
      ),
    );
  }
}
