import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import 'screens/security_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/about_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Ảnh đại diện giả lập
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
            
            // Danh sách các tùy chọn cài đặt
            _buildAccountOption(context, Icons.security, "Cài đặt bảo mật", "Đổi mật khẩu, Chế độ tối/sáng", const SecurityScreen()),
            _buildAccountOption(context, Icons.notifications_none, "Thông báo", "Lời cảnh báo mới trong ngày", const NotificationsScreen()),
            _buildAccountOption(context, Icons.help_outline, "Trung tâm trợ giúp", "Thông tin hỗ trợ kỹ thuật", const HelpCenterScreen()),
            _buildAccountOption(context, Icons.info_outline, "Về ứng dụng Safe Trek", "Nguyên lý, Chính sách, Cảm ơn", const AboutScreen()),
            
            const SizedBox(height: 40),
            // Nút đăng xuất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Xử lý Đăng xuất
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const LoginScreen()), 
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context, IconData icon, String title, String subtitle, Widget target) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => target));
      },
    );
  }
}