import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../alerts/alert_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertProvider>().unHandledAlerts;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo trong ngày")),
      body: alerts.isEmpty
          ? const Center(child: Text("Hôm nay chưa có thông báo mới"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: alerts.length,
              itemBuilder: (context, i) {
                final a = alerts[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.notification_important, color: Colors.red),
                    title: Text("Cảnh báo từ ${a.userName}"),
                    subtitle: Text("${a.alertType} - ${a.createdAt.hour}:${a.createdAt.minute}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to alert resolution or show detail
                    },
                  ),
                );
              },
            ),
    );
  }
}
