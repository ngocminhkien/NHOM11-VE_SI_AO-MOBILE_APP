import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/users/user_screen.dart';
import '../../features/contacts/contact_screen.dart';
import '../../features/account/account_screen.dart';
import 'package:provider/provider.dart';
import '../../features/users/user_provider.dart';
import '../../features/alerts/alert_provider.dart';
import 'dart:async';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _index = 0;
  Timer? _timer;
  final _pages = [
    const DashboardScreen(),
    const UserScreen(),
    const ContactScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProvider>().fetchUsers();
        context.read<UserProvider>().fetchStats();
        context.read<AlertProvider>().fetchAlerts();
        context.read<AlertProvider>().fetchAlertStats();
        context.read<AlertProvider>().fetchAlertHistory();
      }
    });

    // Cài đặt Refresh tự động mỗi 5 giây để nhận cảnh báo mới (Real-time sync)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        context.read<AlertProvider>().fetchAlerts();
        context.read<AlertProvider>().fetchAlertStats();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Tổng quan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Người dùng"),
          BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: "Liên hệ"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Tài khoản"),
        ],
      ),
    );
  }
}