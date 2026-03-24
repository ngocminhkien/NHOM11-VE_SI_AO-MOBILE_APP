import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/home/screens/emergency_contact_screen.dart';
import 'features/home/screens/history_screen.dart';
import 'features/home/screens/profile_screen.dart';
import 'features/auth/login_screen.dart'; 
import 'package:provider/provider.dart';
import 'features/admin/providers/admin_alert_provider.dart';
import 'features/admin/providers/admin_user_provider.dart';
import 'features/admin/providers/admin_trip_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Background Firebase Init Error: $e');
  }
  _playEmergencyAlarmAndVibrate(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _playEmergencyAlarmAndVibrate(RemoteMessage message) async {
  // 1. Rung điện thoại liên tục mô phỏng tín hiệu SOS
  bool? hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator == true) {
    Vibration.vibrate(pattern: [500, 1000, 500, 2000, 500, 1000, 500, 2000, 500, 3000]); 
  }

  // 2. Chèn heads-up Notification (Loud Alarm & Max Priority)
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'sos_channel_id', 'Cảnh báo Khẩn Cấp',
    channelDescription: 'Kênh báo động SOS cường độ cao',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  
  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
  
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? "SOS KHẨN CẤP!",
    message.notification?.body ?? "Phát hiện sự cố! Hãy kiểm tra lộ trình ngay!",
    platformDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // KHỞI TẠO FIREBASE VÀ NOTIFICATION
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initialSettings);

    // Bắt sự kiện khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _playEmergencyAlarmAndVibrate(message);
    });
  } catch (e) {
    debugPrint('Firebase Config Missing or Error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAlertProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => AdminTripProvider()),
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
      home: const LoginScreen(), 
      //home: const MainNavigatorScreen(),
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