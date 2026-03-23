import 'package:flutter/material.dart';

class SetupTripScreen extends StatefulWidget {
  const SetupTripScreen({super.key});

  @override
  State<SetupTripScreen> createState() => _SetupTripScreenState();
}

class _SetupTripScreenState extends State<SetupTripScreen> {
  // Controllers cho các ô nhập liệu
  final TextEditingController _destinationNameController = TextEditingController();
  final TextEditingController _destinationAddressController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _destinationNameController.dispose();
    _destinationAddressController.dispose();
    _estimatedTimeController.dispose();
    _noteController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context), // Quay lại màn hình trước
        ),
        title: const Text(
          'Thiết lập hành trình',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      // === BODY ===
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === KHỐI 1: THIẾT LẬP LIÊN HỆ ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Màu xám nhạt như thiết kế
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.people_outline, size: 30, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Thiết lập liên hệ',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // === KHỐI 2: THÔNG TIN CHUYẾN ĐI ===
              const Text(
                'Thông tin chuyến đi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
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

              // === KHỐI 3: NÚT BẮT ĐẦU ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý bắt đầu chuyến đi và chuyển sang màn hình theo dõi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095FF), // Màu xanh dương
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Bắt đầu chuyến đi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }

  // Hàm hỗ trợ vẽ TextField trắng có bóng mờ
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isLongText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isLongText ? TextInputType.multiline : TextInputType.text),
        maxLines: isLongText ? 4 : 1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}