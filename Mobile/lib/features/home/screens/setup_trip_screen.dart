import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'track_trip_screen.dart'; 

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

    Map<String, dynamic> tripData = {
      "title": _destinationNameController.text, 
      "time": "${_estimatedTimeController.text} phút", 
      "userId": "user-test-001" 
    };

    try {
      var url = Uri.parse('http://localhost:5134/api/Trip/start');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 200) {
        // 1. CHỤP LẤY ID CHUYẾN ĐI TỪ BACKEND TRẢ VỀ
        final responseData = jsonDecode(response.body);
        final String newTripId = responseData['data']['id']; 

        int minutes = int.tryParse(_estimatedTimeController.text) ?? 30;

        if (!mounted) return;
        // 2. TRUYỀN ID SANG MÀN HÌNH THEO DÕI
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => TrackTripScreen(
              tripId: newTripId, // <--- Truyền ID vào đây
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không kết nối được với Server.')));
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
              _buildTextField(_destinationAddressController, 'Nhập địa chỉ cụ thể'),

              _buildLabel('Thời gian dự kiến (phút)'),
              _buildTextField(_estimatedTimeController, 'Nhập thời gian (VD: 30)', isNumber: true),

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
                    ? const CircularProgressIndicator(color: Colors.white) 
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isLongText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.number : (isLongText ? TextInputType.multiline : TextInputType.text),
        maxLines: isLongText ? 4 : 1,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}