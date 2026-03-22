import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/login_screen.dart'; // Đảm bảo đúng đường dẫn tới file login của bạn

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 1. Khai báo các biến để chứa dữ liệu từ máy
  String _fullName = "";
  String _email = "";
  String _phoneNumber = "";
  
  // Các bộ điều khiển để hiển thị dữ liệu vào ô nhập
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Gọi hàm tải thông tin khi vừa mở màn hình
  }

  // 2. Hàm đọc thông tin từ SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? "Chưa cập nhật";
      _email = prefs.getString('email') ?? "Chưa cập nhật";
      _phoneNumber = prefs.getString('phoneNumber') ?? "Chưa cập nhật";

      // Gán vào controller để hiển thị lên các ô nhập liệu trắng
      _nameController.text = _fullName;
      _emailController.text = _email;
      _phoneController.text = _phoneNumber;
    });
  }

  // 3. Hàm xử lý Đăng xuất
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch dữ liệu đã lưu
    if (mounted) {
      // Quay về màn hình đăng nhập và xóa sạch các trang trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
                // Header
                const Text('Tài khoản', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // === KHỐI 1: THÔNG TIN NGƯỜI DÙNG ===
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF0095FF),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HIỂN THỊ TÊN THẬT
                          Text(_fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          // HIỂN THỊ SĐT THẬT
                          Text(_phoneNumber, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === KHỐI 2: FORM THÔNG TIN CÁ NHÂN ===
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin cá nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      
                      _buildTextFieldLabel('Họ và tên'),
                      _buildTextField(_nameController), // Truyền controller vào
                      const SizedBox(height: 15),
                      
                      _buildTextFieldLabel('Email'),
                      _buildTextField(_emailController),
                      const SizedBox(height: 15),
                      
                      _buildTextFieldLabel('Số điện thoại'),
                      _buildTextField(_phoneController),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === KHỐI 3: MENU CÀI ĐẶT ===
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem('Danh bạ khẩn cấp'),
                      const Divider(color: Colors.black26),
                      _buildMenuItem('Lịch sử chuyến đi'),
                      const Divider(color: Colors.black26),
                      _buildMenuItem('Cài đặt hệ thống'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // === KHỐI 4: NÚT ĐĂNG XUẤT ===
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout, // Gọi hàm đăng xuất khi bấm
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Đăng Xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }

  // Cập nhật hàm này để nhận controller và hiển thị dữ liệu
  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: TextField(
        controller: controller,
        readOnly: true, // Để chế độ chỉ đọc (Profile thường không sửa trực tiếp ở đây)
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
      onTap: () {
        // Xử lý chuyển trang các mục cài đặt
      },
    );
  }
}