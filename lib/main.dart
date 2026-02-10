import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Để dùng biến kIsWeb
import 'features/home/screens/home_screen.dart'; // Import màn hình Home

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình Firebase (Giữ nguyên key của bạn)
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAPfML6-VMm6A833kR6gxMzH1t6Pv_EJ8M",
        authDomain: "ve-si-ao-nhom11.firebaseapp.com",
        projectId: "ve-si-ao-nhom11",
        storageBucket: "ve-si-ao-nhom11.firebasestorage.app",
        messagingSenderId: "64838673170",
        appId: "1:64838673170:web:230d5533a684e3bb8249cb",
        measurementId: "G-21FE8QCMJ7",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vệ Sĩ Ảo',
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // --- PHẦN QUAN TRỌNG ĐÃ SỬA ---
      // Chạy thẳng vào màn hình Home thay vì hiện chữ Welcome
      home: const HomeScreen(), 
    );
  }
}