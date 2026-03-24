import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt bảo mật")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Tài khoản", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePassword(context),
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text("Giao diện", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Chế độ tối (Dark Mode)"),
            value: _isDarkMode, 
            onChanged: (v) => setState(() => _isDarkMode = v),
          ),
          const SizedBox(height: 30),
          const Text("Bảo mật hệ thống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text("Xác thực vân tay"),
            subtitle: const Text("Yêu cầu khi xử lý SOS khẩn cấp"),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu hiện tại")),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu mới")),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Xác nhận mật khẩu mới")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Lưu")),
        ],
      ),
    );
  }
}
