import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import '../../core/constants/app_colors.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        title: const Text("Quản lý người dùng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTopSummary(provider),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Danh sách thành viên", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton.filled(
                        onPressed: () => _showAddDialog(context),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(backgroundColor: Colors.blue),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSearchBar(provider),
                  const SizedBox(height: 10),
                  Expanded(child: _buildUserList(provider)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopSummary(UserProvider p) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _smallStatBox("Tổng", "${p.users.length}", AppColors.accentBlue),
          const SizedBox(width: 10),
          _smallStatBox("Mới (24h)", "${p.newUsersToday}", AppColors.accentOrange),
          const SizedBox(width: 10),
          _smallStatBox("Chặn", "0", AppColors.accentRed),
        ],
      ),
    );
  }

  Widget _smallStatBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(UserProvider p) {
    return TextField(
      onChanged: (v) => p.setSearch(v),
      decoration: InputDecoration(
        hintText: "Tìm theo tên hoặc SĐT...",
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(p.sortAZ ? Icons.sort_by_alpha : Icons.sort_by_alpha_sharp, color: Colors.blue),
          onPressed: () => p.setSort(!p.sortAZ),
        ),
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildUserList(UserProvider p) {
    final list = p.filteredUsers;
    if (list.isEmpty) return const Center(child: Text("Chưa có dữ liệu"));
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
      itemBuilder: (context, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.bgLight,
          child: Text(list[i].name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        title: Text(list[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("${list[i].phone}\nTham gia: ${list[i].createdAt.day}/${list[i].createdAt.month}/${list[i].createdAt.year}", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.circle, size: 8, color: Colors.green),
        isThreeLine: true,
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Thêm thành viên"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: n, decoration: const InputDecoration(labelText: "Họ tên")),
            TextField(controller: p, decoration: const InputDecoration(labelText: "Số điện thoại")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () {
            if (n.text.isNotEmpty) {
              context.read<UserProvider>().addUser(n.text, p.text);
              Navigator.pop(context);
            }
          }, child: const Text("Lưu")),
        ],
      ),
    );
  }
}