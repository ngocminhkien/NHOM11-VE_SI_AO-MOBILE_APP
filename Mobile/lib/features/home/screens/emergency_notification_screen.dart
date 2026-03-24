import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../alerts/alert_provider.dart';

class EmergencyNotificationScreen extends StatefulWidget {
  final String alertId;
  const EmergencyNotificationScreen({super.key, required this.alertId});

  @override
  State<EmergencyNotificationScreen> createState() => _EmergencyNotificationScreenState();
}

class _EmergencyNotificationScreenState extends State<EmergencyNotificationScreen> {
  bool hasSignal = true;

  @override
  Widget build(BuildContext context) {
    final alertP = context.watch<AlertProvider>();

    return Scaffold(
      backgroundColor: hasSignal ? const Color(0xFFD32F2F) : Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo khẩn cấp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildSignalStatus(),
            const SizedBox(height: 20),
            Text(
              hasSignal ? 'Đang gửi tín hiệu qua vệ tinh...' : 'Mất sóng - Gửi tín hiệu thất bại',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (!hasSignal) ...[
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => setState(() => hasSignal = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Thử lại ngay'),
              ),
            ],
            const Spacer(),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Đang thông báo tới:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 15),
                  
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: const Icon(Icons.shield, color: Colors.blue),
                    ),
                    title: const Text("Hệ thống Quản trị (Admin)", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Đang kết nối trực tiếp..."),
                    trailing: Checkbox(value: true, onChanged: (_) {}),
                  ),

                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await alertP.markAsSafe(widget.alertId);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã báo an toàn. Tín hiệu SOS đã được gỡ bỏ.")),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Tôi đã an toàn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStatus() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (hasSignal)
          TweenAnimationBuilder(
            tween: Tween(begin: 1.0, end: 2.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                width: 80 * value,
                height: 80 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2 / value),
                ),
              );
            },
          ),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: hasSignal ? Colors.red[400] : Colors.grey[700],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            hasSignal ? Icons.wifi_tethering : Icons.priority_high,
            size: 60,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}