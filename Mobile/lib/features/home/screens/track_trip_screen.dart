import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'emergency_notification_screen.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // THƯ VIỆN GPS
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class TrackTripScreen extends StatefulWidget {
  final String tripId;
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
  int _secondsRemaining = 0; 
  bool _isUpdating = false;

  // CÁC BIẾN QUẢN LÝ BẢN ĐỒ VÀ GPS
  final MapController _mapController = MapController();
  LatLng? _currentLocation; // Tọa độ hiện tại
  bool _isLoadingLocation = true; // Cờ báo đang dò GPS

  // TÍNH NĂNG CẢNH BÁO ĐỨNG YÊN
  Timer? _locationCheckTimer;
  Timer? _sosDialogTimer;
  LatLng? _lastMovingLocation;
  DateTime _lastMovingTime = DateTime.now();
  bool _isDialogShowing = false;

  // TÍNH NĂNG CẢNH BÁO VA CHẠM
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  bool _isCollisionWarningShowing = false;
  Timer? _collisionSosTimer;

  @override
  void initState() {
    super.initState();
    _initTimerFromPrefs();
    _determinePosition().then((_) {
      _startStationaryTracking();
    });
    _startCollisionDetection();
  }

  void _startCollisionDetection() {
    _accelerometerSubscription = userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        if (_isUpdating || _secondsRemaining <= 0 || _isCollisionWarningShowing || _isDialogShowing) return;

        double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (magnitude > 30.0) {
          _showCollisionWarningDialog();
        }
      },
      onError: (e) {},
    );
  }

  void _showCollisionWarningDialog() {
    if (!mounted) return;
    setState(() {
      _isCollisionWarningShowing = true;
    });

    _collisionSosTimer = Timer(const Duration(seconds: 30), () {
      if (_isCollisionWarningShowing && mounted) {
        Navigator.pop(context); // Đóng hộp thoại
        _isCollisionWarningShowing = false;
        _updateTripStatus("SOS");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.red[50], // Nền đỏ báo động
          title: const Row(children: [Icon(Icons.report_problem, color: Colors.red, size: 30), SizedBox(width: 10), Expanded(child: Text('Phát hiện va chạm!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)))]),
          content: const Text('Phát hiện va chạm rất mạnh! Bạn vẫn ổn chứ?\n\n(Hệ thống sẽ BÁO ĐỘNG SOS tự động sau 30 GIÂY nếu không có phản hồi)', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () {
                _collisionSosTimer?.cancel();
                _isCollisionWarningShowing = false;
                Navigator.pop(context);
              },
              child: const Text('TÔI ỔN', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                _collisionSosTimer?.cancel();
                _isCollisionWarningShowing = false;
                Navigator.pop(context);
                _updateTripStatus('SOS');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('GỬI SOS NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  void _startStationaryTracking() {
    // Kích hoạt Timer 3 phút (180 giây)
    _locationCheckTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
       if (_isUpdating || _secondsRemaining <= 0) return; // Không check nếu đang lấy api hoặc hết giờ
       
       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
       if (!serviceEnabled) return;

       LocationPermission permission = await Geolocator.checkPermission();
       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       LatLng newLoc = LatLng(position.latitude, position.longitude);

       if (mounted) {
         setState(() {
           _currentLocation = newLoc;
         });
         _mapController.move(newLoc, 16.0);
       }

       if (_lastMovingLocation == null) {
         _lastMovingLocation = newLoc;
         _lastMovingTime = DateTime.now();
         return;
       }

       const distance = Distance();
       final double dist = distance.as(LengthUnit.Meter, _lastMovingLocation!, newLoc);

       if (dist > 20.0) {
         // Di chuyển vượt qua 20m, xem như người dùng vẫn ổn
         _lastMovingLocation = newLoc;
         _lastMovingTime = DateTime.now();
       } else {
         // Nếu đứng yên
         final int minutesStationary = DateTime.now().difference(_lastMovingTime).inMinutes;
         if (minutesStationary >= 10 && !_isDialogShowing) {
           _showStationaryWarningDialog();
         }
       }
    });
  }

  void _showStationaryWarningDialog() {
    if (!mounted) return;
    _isDialogShowing = true;
    _sosDialogTimer = Timer(const Duration(seconds: 60), () {
      if (_isDialogShowing && mounted) {
        Navigator.pop(context); // Đóng hộp thoại
        _isDialogShowing = false;
        _updateTripStatus("SOS");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30), SizedBox(width: 10), Text('Bạn vẫn ổn chứ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
          content: const Text('Bạn đã không di chuyển trong 10 phút. Nếu bạn không phản hồi trong 60 giây, hệ thống sẽ BÁO ĐỘNG SOS tự động cho người thân!', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () {
                _sosDialogTimer?.cancel();
                _isDialogShowing = false;
                _lastMovingTime = DateTime.now(); // Cấp thêm 10 phút nữa
                Navigator.pop(context);
              },
              child: const Text('TÔI VẪN ỔN', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                _sosDialogTimer?.cancel();
                _isDialogShowing = false;
                Navigator.pop(context);
                _updateTripStatus('SOS');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('GỬI SOS NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _initTimerFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? endTimeMs = prefs.getInt('activeTripEndTime');
    if (endTimeMs != null) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final diffSeconds = (endTimeMs - nowMs) ~/ 1000;
      if (diffSeconds > 0) {
        setState(() {
          _secondsRemaining = diffSeconds;
        });
      } else {
        setState(() {
          _secondsRemaining = 0;
        });
      }
    } else {
      setState(() {
        _secondsRemaining = widget.estimatedMinutes * 60;
      });
    }
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _locationCheckTimer?.cancel();
    _sosDialogTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _collisionSosTimer?.cancel();
    super.dispose();
  }

  // ==========================================
  // HÀM XIN QUYỀN VÀ LẤY TỌA ĐỘ GPS
  // ==========================================
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem GPS trên điện thoại có đang bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    // Kiểm tra quyền (Cho phép app dùng vị trí)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    } 

    // Nếu đã có quyền -> Lấy tọa độ và di chuyển bản đồ tới đó
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _lastMovingLocation = _currentLocation;
        _lastMovingTime = DateTime.now();
        _isLoadingLocation = false;
      });
      // Di chuyển ống kính bản đồ về chỗ mình đứng
      _mapController.move(_currentLocation!, 16.0); 
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _updateTripStatus("SOS");
      }
    });
  }

  Future<void> _updateTripStatus(String status) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    _timer?.cancel();
    _locationCheckTimer?.cancel();
    _sosDialogTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _collisionSosTimer?.cancel();

    try {
      final response = await http.put(
        Uri.parse('http://localhost:5134/api/Trip/${widget.tripId}/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "status": status,
          "latitude": _currentLocation?.latitude,
          "longitude": _currentLocation?.longitude
        }),
      );

      if (response.statusCode == 200) {
        _timer?.cancel(); 
        
        // Xoá Active Trip khỏi SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('activeTripId');
        await prefs.remove('activeTripName');
        await prefs.remove('activeTripTime');
        await prefs.remove('activeTripEndTime');

        if (!mounted) return;

        if (status == "An toàn") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật trạng thái An Toàn!')));
          Navigator.pop(context); 
        } else if (status == "SOS") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyNotificationScreen()),
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
          // === KHU VỰC BẢN ĐỒ ===
          Expanded(
            flex: 2,
            child: _isLoadingLocation
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Đang dò tìm vệ tinh GPS..."),
                      ],
                    ),
                  )
                : FlutterMap(
                    mapController: _mapController, // Gắn bộ điều khiển
                    options: MapOptions(
                      // Nếu không có GPS, mặc định chỉ vào Hà Nội
                      initialCenter: _currentLocation ?? const LatLng(21.028511, 105.804817), 
                      initialZoom: 16.0, 
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.vesiao.app',
                      ),
                      if (_currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 60,
                              height: 60,
                              // Hiệu ứng chấm xanh nhấp nháy thường thấy ở app bản đồ
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                                  ),
                                  Container(
                                    width: 15, height: 15,
                                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  ),
                                ],
                              ),
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