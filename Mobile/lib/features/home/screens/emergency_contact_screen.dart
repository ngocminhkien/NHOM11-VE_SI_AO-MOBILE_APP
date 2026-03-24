import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  String userName = "Người dùng"; 
  List<Map<String, dynamic>> contacts = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  bool _isVerified = true;

  @override
  void initState() {
    super.initState();
    fetchContacts(); // Lấy danh bạ khi mở màn hình
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  // HÀM 1: LẤY DANH BẠ TỪ API
  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5134/api/EmergencyContact/user/user-test-001'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        
        if (!mounted) return;
        setState(() {
          contacts = data.map((c) => {
            "name": c['name'] ?? "Không tên",
            "phone": c['phoneNumber'] ?? c['phone'] ?? "Không có số",
            "relation": c['relation'] ?? "Chưa rõ",
            "verified": true, // Tạm mặc định là true
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // HÀM 2: THÊM LIÊN HỆ MỚI LÊN API
  Future<void> _addContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Tên và Số điện thoại!')));
      return;
    }

    Map<String, dynamic> newContact = {
      "name": _nameController.text,
      "phoneNumber": _phoneController.text, // Gửi đúng tên cột trong C#
      "relation": _relationController.text.isNotEmpty ? _relationController.text : "Chưa rõ",
      "userId": "user-test-001"
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5134/api/EmergencyContact/add'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newContact),
      );

      if (response.statusCode == 200) {
        _nameController.clear();
        _phoneController.clear();
        _relationController.clear();
        FocusScope.of(context).unfocus();
        fetchContacts(); // Tải lại danh sách sau khi thêm thành công
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm liên hệ thành công!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối Server!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Liên Hệ Khẩn Cấp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                // KHU VỰC HIỂN THỊ DANH SÁCH
                _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : (contacts.isEmpty ? _buildEmptyState() : _buildContactList()),

                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                // FORM THÊM LIÊN HỆ
                const Text('Thêm liên hệ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                _buildLabel('Tên liên hệ'),
                _buildTextField(_nameController, 'Nhập tên liên hệ'),

                _buildLabel('Số điện thoại'),
                _buildTextField(_phoneController, 'Nhập số điện thoại', isNumber: true),

                _buildLabel('Mối quan hệ'),
                _buildTextField(_relationController, 'Nhập mối quan hệ (Bố, Mẹ, Bạn...)'),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                           _nameController.clear(); _phoneController.clear(); _relationController.clear();
                           FocusScope.of(context).unfocus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300], foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('HỦY', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addContact, // Gọi hàm bắn API
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095FF), foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.people_alt, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text('Chưa có liên hệ khẩn cấp', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: contacts.map((contact) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.person, color: Colors.blue)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${contact['name']} - ${contact['relation']}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    const SizedBox(height: 5),
                    Text(contact['phone'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}