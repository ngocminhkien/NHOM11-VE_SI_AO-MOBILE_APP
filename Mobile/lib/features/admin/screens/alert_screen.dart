import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_alert_provider.dart';
import '../providers/admin_user_provider.dart';
import '../models/admin_alert_model.dart';
import '../models/admin_user_model.dart';
import 'user_detail_screen.dart';

class AdminContactScreen extends StatelessWidget {
  const AdminContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AdminAlertProvider>();
    final userProvider = context.watch<AdminUserProvider>();

    return _AdminContactBody(
        alertProvider: alertProvider, userProvider: userProvider);
  }
}

class _AdminContactBody extends StatefulWidget {
  final AdminAlertProvider alertProvider;
  final AdminUserProvider userProvider;
  const _AdminContactBody(
      {required this.alertProvider, required this.userProvider});

  @override
  State<_AdminContactBody> createState() => _AdminContactBodyState();
}

class _AdminContactBodyState extends State<_AdminContactBody> {
  String _searchQuery = "";

  List<AdminUserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return widget.userProvider.users;
    final q = _searchQuery.toLowerCase();
    return widget.userProvider.users.where((u) =>
        u.fullName.toLowerCase().contains(q) ||
        u.phoneNumber.contains(q) ||
        u.email.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = widget.userProvider.totalCount;
    final newToday = widget.userProvider.dailyCount;
    final unhandledAlerts = widget.alertProvider.unhandledAlerts;
    final userList = _filteredUsers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield, color: Colors.blue),
            SizedBox(width: 8),
            Text('Safe Trek',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                size: 30, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.userProvider.fetchUsers();
          await widget.userProvider.fetchUserStats();
          await widget.alertProvider.fetchAlerts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 2),
                child: Text("Tổng quan liên hệ",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text("Mạng lưới an toàn của bạn",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),

              // === STAT CARDS ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _statCard("Tổng số", "$totalUsers",
                                Colors.grey[200]!, Colors.black87, null)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _statCard("Mới hôm nay", "$newToday",
                                Colors.grey[200]!, Colors.black87, null)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // "Đã xác minh" = totalUsers (same data, per requirements)
                    _statCardWide(
                      "Đã xác minh",
                      "$totalUsers",
                      const Color(0xFFE8F4FF),
                      Colors.blue,
                      0.85,
                    ),
                  ],
                ),
              ),

              // === UNHANDLED ALERT BANNER ===
              if (unhandledAlerts.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Danh sách cảnh báo chưa xử lý: ${unhandledAlerts.length}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // === SOS ALERTS LIST (if any) ===
              if (unhandledAlerts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text("Cảnh báo SOS",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ),
                ...unhandledAlerts.map((alert) => _buildAlertTile(context, alert)),
              ],

              // === CONTACT LIST HEADER ===
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text("Danh sách liên hệ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                    // Filter icon
                    Icon(Icons.filter_list, color: Colors.grey[600]),
                  ],
                ),
              ),

              // === SEARCH ===
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  ],
                ),
              ),

              // === USER CONTACT LIST ===
              if (widget.userProvider.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator()))
              else if (userList.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text("Trống",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16))))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: userList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (ctx, i) {
                    final user = userList[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
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
                          ctx,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AdminUserDetailScreen(user: user))),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, Color bg, Color textColor, Widget? extra) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          if (extra != null) extra,
        ],
      ),
    );
  }

  Widget _statCardWide(String label, String value, Color bg, Color textColor,
      double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text("${(progress * 100).toInt()}%",
                        style: TextStyle(
                            fontSize: 11,
                            color: textColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.blue[100],
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(BuildContext context, AdminAlertModel alert) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.red[50], shape: BoxShape.circle),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
        ),
        title: Text(alert.userName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            alert.location.isNotEmpty ? alert.location : "Đang cập nhật vị trí..."),
        trailing: TextButton(
          onPressed: () => _showResolveDialog(context, alert),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Xử lý"),
        ),
        onTap: () => _showDetailDialog(context, alert),
      ),
    );
  }

  void _showResolveDialog(BuildContext ctx, AdminAlertModel alert) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Xử lý cảnh báo"),
        content:
            Text("Đánh dấu cảnh báo của ${alert.userName} là đã xử lý?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await widget.alertProvider.resolveAlert(alert.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Xác nhận",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext ctx, AdminAlertModel alert) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chi tiết: ${alert.userName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _row("Loại", alert.alertType),
              _row("Thời gian", alert.createdAt.toString()),
              _row("Vị trí",
                  alert.location.isNotEmpty ? alert.location : "10.762622, 106.660172"),
              _row("Tin nhắn",
                  alert.message.isNotEmpty
                      ? alert.message
                      : "Tôi đang gặp nguy hiểm, cần cứu trợ khẩn cấp!"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Đóng")),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () async {
                      await widget.alertProvider.resolveAlert(alert.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text("Đã xử lý ✓",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
