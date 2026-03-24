import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../users/user_provider.dart';
import '../alerts/alert_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    context.read<UserProvider>().fetchUserStats();
    context.read<AlertProvider>().fetchAlertStats();
  }

  @override
  Widget build(BuildContext context) {
    final userP = context.watch<UserProvider>();
    final alertP = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan hệ thống')),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildStatCard(
                'Cảnh báo trong ngày',
                '${alertP.dailyCount}',
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Cảnh báo trong tháng',
                '${alertP.monthlyCount}',
                Icons.error_outline,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Thành viên mới hôm nay',
                '${userP.newUsersCount}',
                Icons.person_add_alt_1,
                Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text('Kéo xuống để cập nhật dữ liệu mới nhất', 
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 5),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
