import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // THÊM THƯ VIỆN KÉT SẮT

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  String userName = "Người dùng"; 
  String currentUserId = ""; // Biến để chứa ID thật
  
  List<Map<String, dynamic>> contacts = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Kênh Email
  final TextEditingController _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData(); // Gọi hàm mở két sắt trước
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  // ==========================================
  // HÀM MỚI: MỞ KÉT SẮT LẤY ID THẬT
  // ==========================================
  Future<void> _loadUserAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentUserId = prefs.getString('userId') ?? "";
      userName = prefs.getString('fullName') ?? "Người dùng"; // Tiện tay lấy luôn Tên thật
    });

    if (currentUserId.isNotEmpty) {
      fetchContacts(); 
    } else {
      setState(() => _isLoading = false);
    }
  }

  // HÀM 1: LẤY DANH BẠ TỪ API BẰNG ID THẬT
  Future<void> fetchContacts() async {
    try {
      // Nhét currentUserId vào đường dẫn
      final response = await http.get(Uri.parse('http://localhost:5134/api/EmergencyContact/user/$currentUserId'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        
        if (!mounted) return;
        setState(() {
          contacts = data.map((c) => {
            "id": c['id']?.toString() ?? "",
            "name": c['name'] ?? "Không tên",
            "phone": c['phoneNumber'] ?? c['phone'] ?? "Không có số",
            "email": c['email'] ?? "",
            "relation": c['relation'] ?? "Chưa rõ",
            "verified": true, 
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // HÀM 2: THÊM LIÊN HỆ BẰNG ID THẬT
  Future<void> _addContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Tên và Số điện thoại!')));
      return;
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (_emailController.text.isNotEmpty && !emailRegex.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email không đúng định dạng!')));
      return;
    }

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin tài khoản!')));
      return;
    }

    Map<String, dynamic> newContact = {
      "name": _nameController.text,
      "phone": _phoneController.text, 
      "email": _emailController.text,
      "relation": _relationController.text.isNotEmpty ? _relationController.text : "Chưa rõ",
      "userId": currentUserId // <--- NHÉT ID THẬT VÀO ĐÂY
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5134/api/EmergencyContact/add'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newContact),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String serverMessage = responseData['message'] ?? 'Đã thêm thành công!';

        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _relationController.clear();
        FocusScope.of(context).unfocus();
        fetchContacts(); 
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(serverMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi Server (${response.statusCode}): ${response.body}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối Server!')));
    }
  }

  // HÀM 3: XÓA LIÊN HỆ
  Future<void> _deleteContact(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa liên hệ này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('HỦY')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('XÓA', style: TextStyle(color: Colors.red))),
        ]
      )
    ) ?? false;
    
    if (!confirm) return;
    
    try {
      final response = await http.delete(Uri.parse('http://localhost:5134/api/EmergencyContact/$id'));
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa liên hệ!')));
        fetchContacts();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối Server!')));
    }
  }

  // HÀM 4: CẬP NHẬT LIÊN HỆ
  Future<void> _updateContact(String id, String name, String phone, String email, String relation) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5134/api/EmergencyContact/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone": phone, "email": email, "relation": relation, "userId": currentUserId}),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật thành công!')));
        fetchContacts();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi cập nhật!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối Server!')));
    }
  }

  void _showEditSheet(Map<String, dynamic> contact) {
    TextEditingController editName = TextEditingController(text: contact['name']);
    TextEditingController editPhone = TextEditingController(text: contact['phone']);
    TextEditingController editEmail = TextEditingController(text: contact['email']);
    TextEditingController editRelation = TextEditingController(text: contact['relation']);

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cập nhật liên hệ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTextField(editName, 'Tên liên hệ'),
              _buildTextField(editPhone, 'Số điện thoại', isNumber: true),
              _buildTextField(editEmail, 'Email (Tuỳ chọn)'),
              _buildTextField(editRelation, 'Mối quan hệ'),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Cập nhật
                    _updateContact(contact['id'].toString(), editName.text, editPhone.text, editEmail.text, editRelation.text);
                    Navigator.pop(context);
                  },
                  child: const Text('LƯU', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  // ... (Phần UI bên dưới)
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
                // Hiện tên thật thay cho "userTest" cũ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Liên Hệ Khẩn Cấp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Xin chào, $userName', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : (contacts.isEmpty ? _buildEmptyState() : _buildContactList()),

                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),

                const Text('Thêm liên hệ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                _buildLabel('Tên liên hệ'),
                _buildTextField(_nameController, 'Nhập tên liên hệ'),

                _buildLabel('Số điện thoại'),
                _buildTextField(_phoneController, 'Nhập số điện thoại', isNumber: true),

                _buildLabel('Email (Nhận Cảnh Báo Gmail)'),
                _buildTextField(_emailController, 'Nhập email (Tùy chọn)'),

                _buildLabel('Mối quan hệ'),
                _buildTextField(_relationController, 'Nhập mối quan hệ (Bố, Mẹ, Bạn...)'),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                           _nameController.clear(); _phoneController.clear(); _emailController.clear(); _relationController.clear();
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
                        onPressed: _addContact,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditSheet(contact)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteContact(contact['id'].toString())),
                ],
              )
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