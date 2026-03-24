import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_user_provider.dart';
import '../models/admin_user_model.dart';
import 'user_detail_screen.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();
    return _AdminUserBody(provider: provider);
  }
}

class _AdminUserBody extends StatefulWidget {
  final AdminUserProvider provider;
  const _AdminUserBody({required this.provider});

  @override
  State<_AdminUserBody> createState() => _AdminUserBodyState();
}

class _AdminUserBodyState extends State<_AdminUserBody> {
  String _searchQuery = "";
  String _letterFilter = "";

  List<AdminUserModel> get _filteredUsers {
    var list = widget.provider.users;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) =>
        u.fullName.toLowerCase().contains(q) ||
        u.phoneNumber.contains(q) ||
        u.email.toLowerCase().contains(q)).toList();
    }
    if (_letterFilter.isNotEmpty) {
      list = list.where((u) =>
        u.fullName.toUpperCase().startsWith(_letterFilter)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield, color: Colors.blue),
            SizedBox(width: 8),
            Text('Safe Trek', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 30, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.provider.fetchUsers();
          await widget.provider.fetchUserStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text("Tổng quan người dùng",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              // === STAT GRID (2x2) ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                  children: [
                    _statCard("Tổng người dùng", "${widget.provider.totalCount}",
                        const Color(0xFFE0F4FF), Colors.blue, Icons.people_outline),
                    _statCard("Đang hoạt động", "${widget.provider.activeCount}",
                        const Color(0xFFE6F9EE), Colors.green, Icons.favorite_border),
                    _statCard("Người dùng mới", "${widget.provider.dailyCount}",
                        const Color(0xFFF5F5F5), Colors.grey, Icons.person_add_alt_1_outlined),
                    _statCard("Tài khoản bị chặn", "${widget.provider.blockedCount}",
                        const Color(0xFFFFEEEE), Colors.red, Icons.remove_circle_outline),
                  ],
                ),
              ),

              // === DANH SÁCH HEADER ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Danh sách",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Thêm mới"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // === SEARCH BAR ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: const Icon(Icons.mic_none, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Letter filter dropdown
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _letterFilter.isEmpty ? null : _letterFilter,
                          hint: const Icon(Icons.filter_list, color: Colors.grey),
                          items: [
                            const DropdownMenuItem(value: "", child: Text("Tất cả")),
                            ...List.generate(26, (i) {
                              final l = String.fromCharCode(65 + i);
                              return DropdownMenuItem(value: l, child: Text(l));
                            }),
                          ],
                          onChanged: (v) =>
                              setState(() => _letterFilter = v ?? ""),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // === USER LIST ===
              if (widget.provider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (list.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text("Trống",
                            style: TextStyle(color: Colors.grey, fontSize: 16))))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, i) {
                    final user = list[i];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          user.phoneNumber.isNotEmpty
                              ? user.phoneNumber
                              : user.email,
                          style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AdminUserDetailScreen(user: user))),
                    );
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color bg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Thêm người dùng"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, "Họ và tên"),
                _dialogField(usernameCtrl, "Tên đăng nhập"),
                _dialogField(emailCtrl, "Email"),
                _dialogField(phoneCtrl, "Số điện thoại"),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text("Hủy")),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                      setStateDialog(() => loading = true);
                      final newUser = AdminUserModel(
                        id: '',
                        username: usernameCtrl.text,
                        email: emailCtrl.text,
                        fullName: nameCtrl.text,
                        phoneNumber: phoneCtrl.text,
                        role: 'user',
                      );
                      await widget.provider.addUser(newUser);
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    },
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Thêm"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}
