import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_alert_provider.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AdminAlertProvider>().alerts;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo hệ thống")),
      body: alerts.isEmpty
          ? const Center(child: Text("Không có thông báo mới", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final alert = alerts[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: alert.isHandled ? Colors.grey[200] : Colors.red[50],
                    child: Icon(
                      alert.isHandled ? Icons.done : Icons.warning_amber_rounded,
                      color: alert.isHandled ? Colors.grey : Colors.red,
                    ),
                  ),
                  title: Text("Tín hiệu SOS từ ${alert.userName}"),
                  subtitle: Text("${alert.alertType} • ${alert.createdAt.toString().split('.')[0]}"),
                  trailing: alert.isHandled 
                    ? const Text("Đã xử lý", style: TextStyle(fontSize: 12, color: Colors.grey))
                    : const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                );
              },
            ),
    );
  }
}
