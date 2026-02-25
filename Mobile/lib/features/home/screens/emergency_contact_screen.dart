import 'package:flutter/material.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  String userName = "userTest"; // Lấy từ API sau
  List<Map<String, dynamic>> contacts = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  bool _isVerified = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        contacts.add({
          "name": _nameController.text,
          "phone": _phoneController.text,
          "relation": _relationController.text.isNotEmpty ? _relationController.text : "Chưa rõ",
          "verified": _isVerified,
        });
        _nameController.clear();
        _phoneController.clear();
        _relationController.clear();
      });
      FocusScope.of(context).unfocus(); // Ẩn bàn phím
    }
  }

  @override
  Widget build(BuildContext context) {
    // KHÔNG dùng bottomNavigationBar ở đây nữa
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Liên Hệ Khẩn Cấp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('xin chào, $userName', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Color(0xFF0095FF), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          // Focus vào ô nhập tên khi bấm dấu +
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                // Khu vực hiển thị danh sách
                contacts.isEmpty ? _buildEmptyState() : _buildContactList(),

                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                // Form thêm liên hệ
                const Text('Thêm liên hệ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                _buildLabel('Tên liên hệ'),
                _buildTextField(_nameController, 'Nhập tên liên hệ'),

                _buildLabel('Số điện thoại'),
                _buildTextField(_phoneController, 'Nhập số điện thoại', isNumber: true),

                _buildLabel('Mối quan hệ'),
                _buildTextField(_relationController, 'Nhập mối quan hệ'),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đã xác minh', style: TextStyle(fontSize: 14, color: Colors.black87)),
                    Switch(
                      value: _isVerified,
                      onChanged: (value) {
                        setState(() { _isVerified = value; });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF0095FF),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                           _nameController.clear();
                           _phoneController.clear();
                           _relationController.clear();
                           FocusScope.of(context).unfocus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('HỦY', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.people_alt, size: 50, color: Colors.grey[500]),
          const SizedBox(height: 15),
          const Text('Chưa có liên hệ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Thêm liên hệ khẩn cấp để họ có thể\nnhận thông báo khi bạn cần trợ giúp',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: contacts.map((contact) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${contact['name']} - ${contact['relation']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contact['phone'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (contact['verified'])
                const Icon(Icons.verified, color: Colors.blue, size: 20)
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}