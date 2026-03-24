import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'setup_trip_screen.dart';
import 'track_trip_screen.dart';
import 'emergency_notification_screen.dart';
import 'emergency_contact_screen.dart';
import 'profile_screen.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  bool _isLoadingTrips = true;
  
  // Active Trip Persistence
  String? _activeTripId;
  String? _activeTripName;
  int? _activeTripTime;
  int? _activeTripEndTime;

  Timer? _homeTimer;
  int _homeSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _homeTimer?.cancel();
    super.dispose();
  }

  // 2. Hàm lấy thông tin người dùng từ SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String storedName = prefs.getString('fullName') ?? "Người dùng";
    final String storedUserId = prefs.getString('userId') ?? "";
    
    final activeTripId = prefs.getString('activeTripId');
    final activeTripName = prefs.getString('activeTripName');
    final activeTripTime = prefs.getInt('activeTripTime') ?? 30;
    final activeTripEndTime = prefs.getInt('activeTripEndTime');

    if (mounted) {
      setState(() {
        userName = storedName;
        _activeTripId = activeTripId;
        _activeTripName = activeTripName;
        _activeTripTime = activeTripTime;
        _activeTripEndTime = activeTripEndTime;
      });
      _startHomeTimer();
      if (storedUserId.isNotEmpty) {
        fetchRecentTrips(storedUserId);
        _updateFCMToken(storedUserId); // Gọi API lưu FCM Token
      } else {
        setState(() {
          _isLoadingTrips = false;
        });
      }
    }
  }

  // ==========================================
  // 3. HÀM MỚI: LẤY LỊCH SỬ THẬT TỪ BACKEND C#
  // ==========================================
  void _startHomeTimer() {
    _homeTimer?.cancel();
    if (_activeTripEndTime != null) {
      _homeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final diffSeconds = (_activeTripEndTime! - nowMs) ~/ 1000;
        if (mounted) {
          setState(() {
            _homeSecondsRemaining = diffSeconds > 0 ? diffSeconds : 0;
          });
        }
        if (diffSeconds <= 0) {
          _homeTimer?.cancel();
        }
      });
    }
  }

  String get _homeTimerString {
    if (_homeSecondsRemaining <= 0) return "00:00";
    int minutes = _homeSecondsRemaining ~/ 60;
    int seconds = _homeSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _updateFCMToken(String userId) async {
    try {
      // Yêu cầu thư viện FirebaseMessaging
      // Đoạn này lấy mã thiết bị để Backend biết đường bắn Push Notification SOS
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await http.put(
          Uri.parse('http://localhost:5134/api/Users/$userId/fcm-token'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"token": token}),
        );
      }
    } catch (e) {
      debugPrint("Không thể lấy FCM Token (Firebase có thể chưa cài đặt file config): $e");
    }
  }

  Future<void> fetchRecentTrips(String currentUserId) async {
    try {
      // Gọi lên Trạm thu phát sóng (API) bằng ID thực tế
      final response = await http.get(Uri.parse('http://localhost:5134/api/Trip/user/$currentUserId'));

      if (response.statusCode == 200) {
        // Giải mã JSON từ C# gửi về
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic>? tripsData = responseData['data']; // Rút lấy mảng "data"

        if (!mounted) return;
        
        setState(() {
          if (tripsData != null && tripsData.isNotEmpty) {
            recentTrips = tripsData.map((trip) => {
              "id": trip['id'].toString(),
              "title": trip['title'] ?? "Không có tên",
              "time": trip['time'] ?? "", 
              "status": trip['status'] ?? "Không rõ",
            }).toList();

            // Đảo ngược danh sách để danh sách mới lên trên
            recentTrips = recentTrips.reversed.toList();
          }
        });
      }
    } catch (e) {
      print("Lỗi khi gọi API Lịch sử: $e");
      if (!mounted) return;
      setState(() { recentTrips = []; }); 
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTrips = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng,';
    } else if (hour < 18) {
      return 'Chào buổi chiều,';
    } else {
      return 'Chào buổi tối,';
    }
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
                        Text(_getGreeting(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          userName, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          userName != "Đang tải..." && userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
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
                        onLongPress: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyNotificationScreen()));
                        },
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhấn giữ 2 giây để gửi SOS!')));
                        },
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
                      const Text('Nhấn giữ 2 giây để gửi báo động khẩn cấp', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                  child: _activeTripId != null
                      ? Column(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 40),
                            const SizedBox(height: 10),
                            Text(_activeTripName ?? 'Không rõ điểm đến', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(_homeTimerString, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 2)),
                            const SizedBox(height: 15),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TrackTripScreen(
                                      tripId: _activeTripId!,
                                      destinationName: _activeTripName ?? '',
                                      estimatedMinutes: _activeTripTime ?? 30,
                                    )),
                                  ).then((_) => _loadUserInfo());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0095FF), foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Tiếp tục hành trình', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const Text('Hiện tại bạn không có chuyến đi nào đang diễn ra', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SetupTripScreen()),
                                ).then((_) => _loadUserInfo()); 
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
                    _buildQuickActionButton(Icons.timer_outlined, 'Hẹn giờ an toàn', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupTripScreen())).then((_) => _loadUserInfo());
                    }),
                    _buildQuickActionButton(Icons.group_outlined, 'Liên hệ khẩn cấp', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyContactScreen()));
                    }),
                  ],
                ),
                const SizedBox(height: 25),

                // === KHỐI 5: GẦN ĐÂY (LỊCH SỬ THỰC TẾ) ===
                const Text('Gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                _isLoadingTrips 
                    ? const Center(child: CircularProgressIndicator())
                    : (recentTrips.isEmpty 
                        ? _buildEmptyHistory() 
                        : Column(
                            children: recentTrips.map((trip) => _buildTripItem(trip)).toList(), 
                          )),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0095FF), size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: const Center(
        child: Text(
          'Bạn chưa có hành trình nào gần đây. Hãy bắt đầu một chuyến đi mới!', 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16)
        ),
      ),
    );
  }

  Widget _buildTripItem(Map<String, dynamic> trip) {
    final status = trip['status'] ?? '';
    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.location_on;
    
    if (status == 'An toàn') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'SOS') {
      statusColor = Colors.red;
      statusIcon = Icons.warning_rounded;
    }

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
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor),
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
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }
}