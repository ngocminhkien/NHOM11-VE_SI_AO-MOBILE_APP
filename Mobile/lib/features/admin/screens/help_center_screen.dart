import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trung tâm trợ giúp")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Liên hệ hỗ trợ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildContactItem(Icons.phone, "Hotline", "1900 1234"),
            _buildContactItem(Icons.email, "Email", "support@safetrek.vn"),
            _buildContactItem(Icons.language, "Website", "www.safetrek.vn"),
            const SizedBox(height: 30),
            const Text("Câu hỏi thường gặp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildFAQItem("Làm thế nào để xử lý tín hiệu SOS?", "Bạn có thể xem chi tiết trong tab Cảnh báo và nhấn Giải quyết sau khi đã hỗ trợ người dùng."),
            _buildFAQItem("Tôi có thể xóa tài khoản người dùng không?", "Hiện tại chức năng này chỉ dành cho Admin cấp cao nhất."),
            _buildFAQItem("Làm sao để nhận thông báo thời gian thực?", "Ứng dụng sẽ tự động nhận thông báo khi có kết nối mạng ổn định qua SignalR."),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String val) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {},
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(a, style: const TextStyle(color: Colors.grey)),
        )
      ],
    );
  }
}
