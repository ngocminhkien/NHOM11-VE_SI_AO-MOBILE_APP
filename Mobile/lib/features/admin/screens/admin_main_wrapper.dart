import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'user_screen.dart';
import 'account_screen.dart';
import 'alert_screen.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});
  @override
  State<AdminMainWrapper> createState() => AdminMainWrapperState();
}

class AdminMainWrapperState extends State<AdminMainWrapper> {
  int _index = 0;

  void goToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    // Pass goToTab callback into the Dashboard so it can switch tabs
    final pages = [
      AdminDashboardScreen(onGoToAlerts: () => goToTab(2)),
      const AdminUserScreen(),
      const AdminContactScreen(),
      const AdminAccountScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Tổng quan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Người dùng"),
          BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined), label: "Tổng quan liên hệ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "Tài khoản"),
        ],
      ),
    );
  }
}
