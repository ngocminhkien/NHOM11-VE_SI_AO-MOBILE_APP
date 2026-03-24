import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/api_constants.dart';
import 'track_trip_screen.dart'; 
import 'map_picker_screen.dart';

class SetupTripScreen extends StatefulWidget {
  const SetupTripScreen({super.key});

  @override
  State<SetupTripScreen> createState() => _SetupTripScreenState();
}

class _SetupTripScreenState extends State<SetupTripScreen> {
  final TextEditingController _destinationNameController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = false; 
  bool _isTimeCalculated = false;

  @override
  void dispose() {
    _destinationNameController.dispose();
    _destinationAddressController.dispose();
    _estimatedTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _startTripToAPI() async {
    if (_destinationNameController.text.isEmpty || _estimatedTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Điểm đến và Thời gian!')));
      return;
    }

    setState(() => _isLoading = true);

    // ==========================================
    // 1. MỞ KÉT SẮT LẤY ID THẬT CỦA NGƯỜI DÙNG
    // ==========================================
    final prefs = await SharedPreferences.getInstance();
    final String currentUserId = prefs.getString('userId') ?? "";

    if (currentUserId.isEmpty) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin tài khoản! Vui lòng đăng nhập lại.')));
      return;
    }

    // 2. NHÉT ID THẬT VÀO GÓI HÀNG
    Map<String, dynamic> tripData = {
      "title": _destinationNameController.text, 
      "time": "${_estimatedTimeController.text} phút", 
      "userId": currentUserId // <--- ID THẬT NẰM Ở ĐÂY
    };

    try {
      var url = Uri.parse('${ApiConstants.tripUrl}/start');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 200) {
        // CHỤP LẤY ID CHUYẾN ĐI TỪ BACKEND TRẢ VỀ
        final responseData = jsonDecode(response.body);
        final String newTripId = responseData['data']['id']; 

        int minutes = int.tryParse(_estimatedTimeController.text) ?? 30;
        int endTimeMs = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;

        // Lưu Active Trip vào SharedPreferences
        await prefs.setString('activeTripId', newTripId);
        await prefs.setString('activeTripName', _destinationNameController.text);
        await prefs.setInt('activeTripTime', minutes);
        await prefs.setInt('activeTripEndTime', endTimeMs);

        if (!mounted) return;
        // TRUYỀN ID SANG MÀN HÌNH THEO DÕI
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => TrackTripScreen(
              tripId: newTripId, 
              destinationName: _destinationNameController.text, 
              estimatedMinutes: minutes,
            )
          )
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi từ Server: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không kết nối được với Server. Hãy chắc chắn Backend đang chạy!')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Thiết lập hành trình', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin chuyến đi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 15),

              _buildLabel('Tên điểm đến'),
              _buildTextField(_destinationNameController, 'VD: Về nhà, Đến công ty'),

              _buildLabel('Địa chỉ điểm đến'),
              _buildTextField(
                _destinationAddressController, 
                'Nhập địa chỉ cụ thể',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: () async {
                    // Kiểm tra GPS trước khi mở bản đồ
                    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng bật GPS (Dịch vụ vị trí) trước khi mở bản đồ!')));
                      await Geolocator.openLocationSettings();
                      return;
                    }

                    LocationPermission permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng cấp quyền vị trí để sử dụng bản đồ!')));
                        return;
                      }
                    }

                    if (permission == LocationPermission.deniedForever) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quyền vị trí bị từ chối vĩnh viễn. Hãy vào cài đặt để bật.')));
                      await Geolocator.openAppSettings();
                      return;
                    }

                    if (!context.mounted) return;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        _destinationAddressController.text = result['address'];
                        if (result['minutes'] != null) {
                          _estimatedTimeController.text = result['minutes'].toString();
                          _isTimeCalculated = true;
                        }
                      });
                    }
                  },
                ),
              ),

              _buildLabel('Thời gian dự kiến (phút)'),
              _buildTextField(
                _estimatedTimeController, 
                'Nhập thời gian (VD: 30)', 
                isNumber: true,
                readOnly: _isTimeCalculated,
              ),

              _buildLabel('Chi chú'),
              _buildTextField(_noteController, 'Nhập chi chú (nếu có)', isLongText: true),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startTripToAPI, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095FF), padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Bắt đầu chuyến đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isLongText = false, bool readOnly = false, Widget? suffixIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
      child: TextField(
        controller: controller, 
        keyboardType: isNumber ? TextInputType.number : (isLongText ? TextInputType.multiline : TextInputType.text),
        maxLines: isLongText ? 4 : 1,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}