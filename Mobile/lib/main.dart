import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/home/screens/emergency_contact_screen.dart';
import 'features/home/screens/history_screen.dart';
import 'features/home/screens/profile_screen.dart';
import 'features/auth/login_screen.dart'; 

import 'package:provider/provider.dart';
import 'features/users/user_provider.dart';
import 'features/alerts/alert_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: const VeSiAoApp(),
    ),
  );
}

class VeSiAoApp extends StatelessWidget {
  const VeSiAoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vệ Sĩ Ảo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0095FF),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      // SỬA Ở ĐÂY: Cho app mở màn hình Đăng nhập đầu tiên
      //home: const LoginScreen(), 
      home: const MainNavigatorScreen(),
    );
  }
}

// KHỐI GIAO DIỆN CHÍNH (Sẽ được gọi sau khi đăng nhập thành công)
class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _selectedIndex = 0;

  // Lắp 4 màn hình vào đúng 4 vị trí Tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const EmergencyContactScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Hiển thị màn hình tương ứng

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0095FF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Liên hệ'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}