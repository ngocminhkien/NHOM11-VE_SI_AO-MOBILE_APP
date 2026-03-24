import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import 'security_settings_screen.dart';
import 'notification_screen.dart';
import 'help_center_screen.dart';
import 'about_app_screen.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.person, size: 65, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Quản trị viên hệ thống", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const Text(
              "admin@safetrek.vn", 
              style: TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 30),
            
            _buildAccountOption(context, Icons.security, "Cài đặt bảo mật", const SecuritySettingsScreen()),
            _buildAccountOption(context, Icons.notifications_none, "Thông báo", const AdminNotificationScreen()),
            _buildAccountOption(context, Icons.help_outline, "Trung tâm trợ giúp", const HelpCenterScreen()),
            _buildAccountOption(context, Icons.info_outline, "Về ứng dụng Safe Trek", const AboutAppScreen()),
            
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Logic đăng xuất
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Phiên bản 1.0.0 (Beta)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
    );
  }
}
