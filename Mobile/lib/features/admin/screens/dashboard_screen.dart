import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_user_provider.dart';
import '../providers/admin_alert_provider.dart';
import '../providers/admin_trip_provider.dart';
import 'alert_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback? onGoToAlerts;
  const AdminDashboardScreen({super.key, this.onGoToAlerts});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<AdminUserProvider>();
    final alertProvider = context.watch<AdminAlertProvider>();
    final tripProvider = context.watch<AdminTripProvider>();

    final unhandledCount = alertProvider.unhandledAlerts.length;
    final todayTrips = tripProvider.todayTrips;
    final totalUsers = userProvider.totalCount;

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
          await Future.wait([
            alertProvider.fetchAlerts(),
            userProvider.fetchUsers(),
            tripProvider.fetchTripStats(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Trang chủ quản trị viên",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // === EMERGENCY ALERT CARD ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Text("Cảnh báo khẩn cấp",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text(
                      "$unhandledCount",
                      style: const TextStyle(
                          fontSize: 72, fontWeight: FontWeight.bold, color: Colors.red, height: 1),
                    ),
                    const SizedBox(height: 8),
                    const Text("Cần xử lý ngay", style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        if (onGoToAlerts != null) {
                          onGoToAlerts!();
                        } else {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminContactScreen()));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      ),
                      child: const Text("Xử lý cảnh báo →"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // === SECONDARY STATS ===
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Chuyến đi hôm nay",
                      "$todayTrips",
                      Colors.grey[200]!,
                      Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "Tổng người dùng",
                      "$totalUsers",
                      Colors.grey[200]!,
                      Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // === SAFETY STATUS ===
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trạng thái an toàn",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text("Ổn định",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // === SYSTEM PERFORMANCE ===
              const Text("Hiệu suất hệ thống",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}

