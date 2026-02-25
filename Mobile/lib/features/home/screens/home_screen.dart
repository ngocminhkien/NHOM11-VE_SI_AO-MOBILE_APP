import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Trạng thái dữ liệu
  String userName = "Đang tải..."; // Đổi "Bro" thành trạng thái chờ
  int _selectedIndex = 0;
  
  // Danh sách lưu lịch sử chuyến đi
  List<Map<String, dynamic>> recentTrips = []; 

  @override
  void initState() {
    super.initState();
    fetchUserData(); 
    fetchRecentTrips(); // Gọi thêm hàm lấy lịch sử chuyến đi
  }

  // 2. Hàm gọi API C# lấy tên User
  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5134/api/Users'));
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          setState(() {
            // Sau này khi có API Login, ta sẽ lấy đúng User đang đăng nhập thay vì users[0]
            userName = users[0]['fullName'];
          });
        }
      }
    } catch (e) {
      setState(() { userName = "Người dùng"; });
    }
  }

  // 3. Hàm giả lập lấy Lịch sử chuyến đi từ Database
  void fetchRecentTrips() {
    // Giả lập việc chờ API mất 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // --- BẠN CÓ THỂ BẬT/TẮT ĐOẠN NÀY ĐỂ TEST 2 TRƯỜNG HỢP ---
        
        // TRƯỜNG HỢP 1: Đã có chuyến đi (Dữ liệu mẫu)
        recentTrips = [
          {"id": "1", "title": "Về nhà", "time": "25/02/2026 - 19:30", "status": "An toàn"},
          {"id": "2", "title": "Đến công ty", "time": "25/02/2026 - 08:00", "status": "An toàn"},
        ];

        // TRƯỜNG HỢP 2: Chưa có chuyến đi nào (Xóa comment dòng dưới để test)
        // recentTrips = []; 
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === KHỐI 1: THANH CHÀO HỎI ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HELLO,', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          userName, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        userName != "Đang tải..." && userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // === KHỐI 2: NÚT SOS ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text('Nhấn để gửi báo động', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () { print("Đã bấm SOS!"); },
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3F3F), shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 8),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                          ),
                          child: const Center(child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Liên hệ khẩn cấp sẽ được thông báo ngay lập tức', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // === KHỐI 3: CHUYẾN ĐI ĐANG DIỄN RA ===
                const Text('Chuyến đi đang diễn ra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    children: [
                      const Text('Hiện tại bạn không có chuyến đi nào đang diễn ra', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095FF), foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Bắt đầu chuyến đi mới', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // === KHỐI 4: NÚT CHỨC NĂNG ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(Icons.timer_outlined, 'Hẹn giờ an toàn'),
                    _buildQuickActionButton(Icons.group_outlined, 'Liên hệ khẩn cấp'),
                  ],
                ),
                const SizedBox(height: 25),

                // === KHỐI 5: GẦN ĐÂY (LỊCH SỬ THÔNG MINH) ===
                const Text('Gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                // KIỂM TRA LOGIC: CÓ DỮ LIỆU HAY KHÔNG?
                recentTrips.isEmpty 
                    ? _buildEmptyHistory() // Nếu List rỗng -> Hiện khối xám "Chưa có lịch sử"
                    : Column(
                        children: recentTrips.map((trip) => _buildTripItem(trip)).toList(), // Nếu có -> Vẽ danh sách
                      ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // Thanh điều hướng
    
    );
  }

  // Khối vẽ Nút nhanh
  Widget _buildQuickActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF0095FF), size: 30),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  // Khối giao diện khi CHƯA có lịch sử
  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: const Center(
        child: Text('Chưa có lịch sử chuyến đi', style: TextStyle(color: Colors.grey, fontSize: 16)),
      ),
    );
  }

  // Khối giao diện của 1 thẻ chuyến đi (Khi CÓ lịch sử)
  Widget _buildTripItem(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.location_on, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(trip['time'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(trip['status'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }
}