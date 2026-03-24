import 'package:flutter/material.dart';
// Import màn hình theo dõi để bấm nút chuyển trang
import 'track_trip_screen.dart'; 

class HomeTripOngoingScreen extends StatefulWidget {
  const HomeTripOngoingScreen({super.key});

  @override
  State<HomeTripOngoingScreen> createState() => _HomeTripOngoingScreenState();
}

class _HomeTripOngoingScreenState extends State<HomeTripOngoingScreen> {
  String userName = "Bro"; // Lấy từ API sau
  
  // Dữ liệu giả lập của chuyến đi đang diễn ra
  final String ongoingDestination = "Nhà của bạn";
  final String ongoingStatus = "An toàn";
  final String ongoingEstTime = "30:00";

  @override
  Widget build(BuildContext context) {
    // Scaffold này chỉ chứa nội dung, Bottom Navigation Bar nằm ở main.dart lo rồi
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Safe Trek', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0095FF))), // Logo tạm
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(userName != "Đang tải..." && userName.isNotEmpty ? userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.blue)),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // === KHỐI 1: SOS ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: const Color(0xFFFF8A8A), borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () { print("SOS!"); },
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3F3F), shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: const Center(child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // === KHỐI 2: CHUYẾN ĐI ĐANG DIỄN RA (BẢN CẬP NHẬT) ===
              const Text('Chuyến đi đang diễn ra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Điểm đến: $ongoingDestination', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 10),
                    Text('Trạng thái: $ongoingStatus', style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Text('Thời gian dự kiến: $ongoingEstTime', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 20),
                    // NÚT XEM CHI TIẾT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Chuyển sang màn hình Theo dõi chuyến đi cụ thể
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackTripScreen(
                                tripId: '123', // Tạm thời để '123' hoặc biến id nếu có
                                destinationName: ongoingDestination, // Lấy từ biến ở dòng 82
                                estimatedMinutes: 20, // Điền một con số (ví dụ 20 phút)
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Màu xanh như thiết kế
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}