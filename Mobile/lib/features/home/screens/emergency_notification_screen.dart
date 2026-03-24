import 'package:flutter/material.dart';

class EmergencyNotificationScreen extends StatelessWidget {
  const EmergencyNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F), // Màu đỏ nền khẩn cấp
      // === APP BAR ===
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Trong suốt để thấy nền đỏ
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông báo khẩn cấp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      // === BODY ===
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // === KHỐI 1: BIỂU TƯỢNG CHẤM THAN (!) LỚN ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[300]!.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.priority_high, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gửi tín hiệu thất bại',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            // NÚT THỬ LẠI NGAY
            ElevatedButton(
              onPressed: () {
                // Xử lý gửi lại SOS
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Thử lại ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),

            // === KHỐI 2: ĐANG THÔNG BÁO TỚI ===
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
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Chưa có liên hệ nào được thiết lập', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // NÚT TÔI ĐÃ AN TOÀN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý hủy SOS, báo an toàn
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Màu xám nhạt như thiết kế
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
}