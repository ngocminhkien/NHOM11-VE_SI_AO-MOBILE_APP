import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Về ứng dụng Safe Trek")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(Icons.shield, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Vệ Sĩ Ảo - Safe Trek", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Phiên bản 1.0.0 (Beta)", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text(
              "Safe Trek là ứng dụng hỗ trợ an toàn cá nhân, giúp kết nối người dùng với đội ngũ cứu hộ và quản trị viên trong các tình huống khẩn cấp. "
              "Chúng tôi cung cấp các tính năng như gửi tín hiệu SOS thời gian thực, theo dõi vị trí và quản lý liên hệ khẩn cấp.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            const Divider(),
            _buildInfoRow("Ngày phát hành", "24/03/2026"),
            _buildInfoRow("Phát triển bởi", "Nhóm 11 - Vệ Sĩ Ảo"),
            _buildInfoRow("Chính sách bảo mật", "Xem tại đây"),
            _buildInfoRow("Điều khoản sử dụng", "Xem tại đây"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
