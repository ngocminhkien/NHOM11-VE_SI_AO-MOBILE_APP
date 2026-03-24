import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emergency_notification_screen.dart'; // Import màn hình SOS

// Import 2 thư viện bản đồ xịn sò
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackTripScreen extends StatefulWidget {
  final String tripId; // <--- Nhận ID từ màn hình Thiết lập
  final String destinationName;
  final int estimatedMinutes;

  const TrackTripScreen({
    super.key,
    required this.tripId,
    required this.destinationName,
    required this.estimatedMinutes,
  });

  @override
  State<TrackTripScreen> createState() => _TrackTripScreenState();
}

class _TrackTripScreenState extends State<TrackTripScreen> {
  Timer? _timer;
  late int _secondsRemaining; 
  bool _isUpdating = false; // Tránh bấm nút nhiều lần

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.estimatedMinutes * 60;
    startTimer(); 
  }

  @override
  void dispose() {
    _timer?.cancel(); 
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
        // Hết giờ -> Tự động kích hoạt SOS
        _updateTripStatus("SOS");
      }
    });
  }

  // ==========================================
  // HÀM QUYỀN LỰC: BÁO CÁO TRẠNG THÁI LÊN C#
  // ==========================================
  Future<void> _updateTripStatus(String status) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      // Gọi API PUT để cập nhật trạng thái
      final response = await http.put(
        Uri.parse('http://localhost:5134/api/Trip/${widget.tripId}/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        _timer?.cancel(); // Dừng đồng hồ
        if (!mounted) return;

        // Xử lý chuyển trang dựa theo trạng thái
        if (status == "An toàn") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật trạng thái An Toàn!')));
          Navigator.pop(context); // Quay về trang chủ
        } else if (status == "SOS") {
          // Mở tung màn hình Đỏ báo động
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyNotificationScreen(alertId: "TRIP-SOS-ACTIVE")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi cập nhật trạng thái!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối Server!')));
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  String get timerString {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Theo dõi hành trình', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // === KHU VỰC BẢN ĐỒ THẬT (ĐÃ NÂNG CẤP) ===
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(21.028511, 105.804817), // Tọa độ mặc định (Hà Nội)
                initialZoom: 15.0, // Độ zoom
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vesiao.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(21.028511, 105.804817),
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 45), // Ghim đỏ vị trí
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KHU VỰC THÔNG TIN VÀ ĐẾM NGƯỢC
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity, color: const Color(0xFFE0F7FA), padding: const EdgeInsets.all(30),
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
                          Text(widget.destinationName, style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 5),
                          Text('Thời gian dự kiến: ${widget.estimatedMinutes} phút', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(timerString, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2)),
                  const Text('Thời gian còn lại', style: TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
            ),
          ),

          // HAI NÚT HÀNH ĐỘNG
          Container(
            padding: const EdgeInsets.all(20), color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // BẤM NÚT "TÔI ĐÃ ĐẾN NƠI" -> BÁO AN TOÀN LÊN C#
                    onPressed: _isUpdating ? null : () => _updateTripStatus("An toàn"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isUpdating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Tôi đã đến nơi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    // BẤM NÚT "SOS" -> BÁO SOS LÊN C# VÀ CHUYỂN MÀN HÌNH ĐỎ
                    onPressed: _isUpdating ? null : () => _updateTripStatus("SOS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3F3F), foregroundColor: Colors.white,
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