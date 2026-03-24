import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Về chúng tôi')),
      body: const Center(child: Text('Thông tin ứng dụng Vệ Sĩ Ảo')),
    );
  }
}
