import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Về ứng dụng Safe Trek")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.shield_rounded, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              "Safe Trek Vietnam",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Dẫn đầu trong giải pháp bảo vệ an toàn cá nhân tại Việt Nam.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 40),
            const Text(
              "Nguyên lý hoạt động:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hệ thống giám sát hành trình của bạn thông qua GPS. Khi phát hiện bất thường hoặc khi bạn nhấn nút SOS, tín hiệu sẽ ngay lập tức được gửi tới Trung tâm Quản trị và những người liên hệ khẩn cấp.",
            ),
            const SizedBox(height: 20),
            const Text(
              "Tác dụng:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Hỗ trợ cứu hộ kịp thời.\n• Giám sát an toàn chuyến đi ban đêm.\n• Kết nối mạng lưới vệ sĩ ảo quanh bạn.",
            ),
            const SizedBox(height: 30),
            const Text(
              "Lời cảm ơn:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cảm ơn bạn đã tin tưởng sử dụng Safe Trek. Chúng tôi cam kết không ngừng cải thiện để mang lại trải nghiệm an toàn nhất cho mọi hành trình của bạn.",
            ),
            const SizedBox(height: 50),
            const Center(
              child: Text("© 2026 Safe Trek Team. All rights reserved.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}
