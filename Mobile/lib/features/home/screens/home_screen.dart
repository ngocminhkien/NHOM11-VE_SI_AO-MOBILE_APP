import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import 'setup_trip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Trạng thái dữ liệu
  String userName = "Đang tải..."; 
  int _selectedIndex = 0;
  
  // Danh sách lưu lịch sử chuyến đi (Sẽ lấy từ Database)
  List<Map<String, dynamic>> recentTrips = []; 

  @override
  void initState() {
    super.initState();
    fetchUserData(); 
    fetchRecentTrips(); // Gọi API lấy lịch sử thực tế
  }

  // 2. Hàm gọi API C# lấy tên User
  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.usersUrl));
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            userName = users[0]['fullName'];
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { userName = "Người dùng"; });
    }
  }

  // ==========================================
  // 3. HÀM MỚI: LẤY LỊCH SỬ THẬT TỪ BACKEND C#
  // ==========================================
  Future<void> fetchRecentTrips() async {
    try {
      // Gọi lên Trạm thu phát sóng (API) bằng ID test
      final response = await http.get(Uri.parse('${ApiConstants.tripUrl}/user/user-test-001'));

      if (response.statusCode == 200) {
        // Giải mã gói hàng JSON từ C# gửi về
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> tripsData = responseData['data']; // Rút lấy mảng "data"

        if (!mounted) return;
        
        setState(() {
          // Ép kiểu dữ liệu từ API sang dạng mà Giao diện đọc được
          recentTrips = tripsData.map((trip) => <String, dynamic>{
            "id": trip['id'].toString(),
            "title": trip['title'] ?? "Không có tên",
            "time": trip['time'] ?? "",
            "status": trip['status'] ?? "Không rõ",
          }).toList();

          // Đảo ngược danh sách để chuyến đi MỚI NHẤT hiện lên trên cùng
          recentTrips = recentTrips.reversed.toList();
        });
      }
    } catch (e) {
      print("Lỗi khi gọi API Lịch sử: $e");
      if (!mounted) return;
      setState(() { recentTrips = []; }); // Lỗi thì để danh sách trống
    }
  }

  Future<void> _sendSOS() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.alertsUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userName": userName,
          "alertType": "SOS",
          "location": "Vị trí hiện tại", // Cần tích hợp Geolocator nếu muốn tọa độ thật
          "message": "Người dùng $userName đã nhấn nút SOS khẩn cấp!",
          "isHandled": false
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text('Đã gửi tín hiệu SOS tới quản trị viên!'))
        );
      }
    } catch (e) {
      print("Lỗi gửi SOS: $e");
    }
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
                        onTap: () => _sendSOS(),
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
                        // SỬA Ở ĐÂY: Nút bấm đã được nối dây sang màn hình Thiết lập
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SetupTripScreen()),
                          );
                        },
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

                // === KHỐI 5: GẦN ĐÂY (LỊCH SỬ THỰC TẾ) ===
                const Text('Gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                recentTrips.isEmpty 
                    ? _buildEmptyHistory() 
                    : Column(
                        children: recentTrips.map((trip) => _buildTripItem(trip)).toList(), 
                      ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

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