import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    color: Colors.grey[300], // Nền xám như thiết kế
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF0095FF), // Avatar xanh
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tên người dùng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 5),
                          Text('Số điện thoại', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
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
                      _buildTextField(),
                      const SizedBox(height: 15),
                      
                      _buildTextFieldLabel('Email'),
                      _buildTextField(),
                      const SizedBox(height: 15),
                      
                      _buildTextFieldLabel('Số điện thoại'),
                      _buildTextField(),
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
                    onPressed: () {
                      // Xử lý đăng xuất sau
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Nút đỏ rực rỡ
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

  // Hàm hỗ trợ vẽ Label cho Form
  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }

  // Hàm hỗ trợ vẽ Ô nhập liệu trắng có bóng mờ
  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: TextField(
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

  // Hàm hỗ trợ vẽ từng dòng Menu
  Widget _buildMenuItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward, color: Colors.black87),
      onTap: () {
        // Chuyển trang sau
      },
    );
  }
}