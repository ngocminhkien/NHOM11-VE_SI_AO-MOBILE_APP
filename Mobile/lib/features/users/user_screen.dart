import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _searchKeyword = '';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    
    // Filter & Sort
    List<dynamic> filteredUsers = provider.users.where((user) {
      final name = (user['fullName'] ?? '').toLowerCase();
      final phone = (user['phoneNumber'] ?? '').toLowerCase();
      return name.contains(_searchKeyword.toLowerCase()) || phone.contains(_searchKeyword.toLowerCase());
    }).toList();

    filteredUsers.sort((a, b) {
      int result = (a['fullName'] ?? '').compareTo(b['fullName'] ?? '');
      return _isAscending ? result : -result;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng'),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
            onPressed: () => setState(() => _isAscending = !_isAscending),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên hoặc số điện thoại',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchKeyword = val),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('Không tìm thấy người dùng'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(user['fullName']?[0].toUpperCase() ?? 'U')),
                        title: Text(user['fullName'] ?? 'N/A'),
                        subtitle: Text(user['phoneNumber'] ?? 'Không có số'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Xem chi tiết (Chưa cài đặt)
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
