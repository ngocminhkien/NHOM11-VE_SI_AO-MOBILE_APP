import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trung tâm hỗ trợ")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Hỗ trợ kỹ thuật Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildContactItem(Icons.email, "Email hỗ trợ", "support@safetrek.vn"),
          _buildContactItem(Icons.phone, "Hotline kỹ thuật", "1900 8888"),
          _buildContactItem(Icons.web, "Cổng thông tin nội bộ", "https://admin.safetrek.vn/docs"),
          const SizedBox(height: 40),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Icon(Icons.lock_clock, size: 40, color: Colors.orange),
                  SizedBox(height: 10),
                  Text("Giờ làm việc: 8:00 - 22:00", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Tất cả các ngày trong tuần", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String val) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: const Icon(Icons.copy, size: 16),
      onTap: () {},
    );
  }
}
