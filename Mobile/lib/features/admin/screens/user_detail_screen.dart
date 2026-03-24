import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final AdminUserModel user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin chi tiết")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 20),
              Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user.username, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildDetailItem(Icons.email, "Email", user.email),
              _buildDetailItem(Icons.phone, "Số điện thoại", user.phoneNumber),
              _buildDetailItem(Icons.work, "Vai trò", user.role),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}
