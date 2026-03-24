import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/users/user_screen.dart';
import '../../features/alerts/alert_screen.dart';
import '../../features/alerts/alert_provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  Timer? _syncTimer;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const UserScreen(),
    const AlertScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        context.read<AlertProvider>().fetchAlerts();
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Người dùng'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_support), label: 'Liên hệ'),
        ],
      ),
    );
  }
}
