import 'package:flutter/material.dart';
import 'user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin chi tiết")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.phone, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            const Text("Trạng thái: Offline"),
          ],
        ),
      ),
    );
  }
}