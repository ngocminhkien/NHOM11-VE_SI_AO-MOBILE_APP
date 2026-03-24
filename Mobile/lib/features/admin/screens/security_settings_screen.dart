import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isDarkMode = false;
  bool _is2FAEnabled = false;
  bool _isBiometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt bảo mật")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("GIAO DIỆN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text("Chế độ tối (Dark Mode)"),
            subtitle: const Text("Thay đổi giao diện ứng dụng"),
            value: _isDarkMode,
            onChanged: (v) => setState(() => _isDarkMode = v),
            secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.blue),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("BẢO MẬT TÀI KHOẢN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text("Xác thực 2 yếu tố (2FA)"),
            value: _is2FAEnabled,
            onChanged: (v) => setState(() => _is2FAEnabled = v),
            secondary: const Icon(Icons.security, color: Colors.blue),
          ),
          SwitchListTile(
            title: const Text("Sử dụng vân tay/Khuôn mặt"),
            value: _isBiometricEnabled,
            onChanged: (v) => setState(() => _isBiometricEnabled = v),
            secondary: const Icon(Icons.fingerprint, color: Colors.blue),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("THIẾT BỊ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: Colors.blue),
            title: const Text("Thiết bị đang đăng nhập"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
