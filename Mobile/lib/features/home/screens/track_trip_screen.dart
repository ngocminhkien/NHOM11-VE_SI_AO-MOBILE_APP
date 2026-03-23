import 'package:flutter/material.dart';
import 'dart:async'; // Cần cái này để làm đồng hồ

class TrackTripScreen extends StatefulWidget {
  const TrackTripScreen({super.key});

  @override
  State<TrackTripScreen> createState() => _TrackTripScreenState();
}

class _TrackTripScreenState extends State<TrackTripScreen> {
  // === LOGIC ĐỒNG HỒ ĐẾM NGƯỢC ===
  Timer? _timer;
  int _secondsRemaining = 1800; // Giả lập 30 phút = 1800 giây

  @override
  void initState() {
    super.initState();
    startTimer(); // Bắt đầu đếm ngược ngay khi mở màn hình
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy đồng hồ khi đóng màn hình
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        // Xử lý khi hết giờ mà người dùng chưa bấm "Tôi đã đến nơi"
        print("Hết giờ! Tự động gửi SOS!");
      }
    });
  }

  // Hàm định dạng giây thành MM:SS
  String get timerString {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // === APP BAR ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Theo dõi hành trình',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      // === BODY ===
      body: Column(
        children: [
          // === KHỐI 1: KHU VỰC BẢN ĐỒ (GIẢ LẬP) ===
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100], // Nền xám nhạt
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 60, color: Colors.grey), // Biểu tượng MAP
                    SizedBox(height: 10),
                    Text('MAP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),

          // === KHỐI 2: THÔNG TIN ĐẾM NGƯỢC ===
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFE0F7FA), // Màu xanh nhạt của nền đếm ngược
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.black87),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đang di chuyển', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Tên địa điểm', style: TextStyle(color: Colors.black87)),
                          const SizedBox(height: 5),
                          Text('Thời gian dự kiến: 30:00', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // ĐỒNG HỒ ĐẾM NGƯỢC LỚN
                  Text(
                    timerString, // Hiển thị thời gian thật
                    style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2),
                  ),
                  const Text('Thời gian còn lại', style: TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
            ),
          ),

          // === KHỐI 3: HAI NÚT CUỐI CÙNG ===
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context); // Quay lại
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá cây
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Tôi đã đến nơi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý gửi SOS ngay lập tức
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3F3F), // Màu đỏ SOS
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('SOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}