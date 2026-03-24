// Mobile/lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ve_si_ao/core/constants/api_constants.dart'; // <--- DÙNG ĐƯỜNG DẪN PACKAGE CHUẨN
import 'register_screen.dart'; 
import '../../../main.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOGIC LƯU THÔNG TIN NGƯỜI DÙNG VÀO MÁY
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userData['id']?.toString() ?? '');
    await prefs.setString('fullName', userData['fullName'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('phoneNumber', userData['phoneNumber'] ?? '');
    await prefs.setString('username', userData['username'] ?? '');
  }

  // LOGIC GỌI API ĐĂNG NHẬP (ĐÃ CHUẨN HÓA)
  Future<void> _handleLogin() async {
    final String identifier = _identifierController.text.trim();
    final String password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // <--- LẤY LINK TỪ TRẠM TRUNG TÂM
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': identifier, 
          'Password': password,
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = {'message': 'Lỗi định dạng phản hồi từ server.'};
      }

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          await _saveUserData(data['user']);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigatorScreen()),
          );
        }
      } else {
        _showErrorDialog(data['message'] ?? "Tài khoản hoặc mật khẩu không chính xác.");
      }
    } catch (e) {
      _showErrorDialog("Lỗi kết nối Server. Hãy chắc chắn Backend đang chạy và IP trong api_constants.dart là đúng!");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0095FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: primaryColor),
        title: const Text('Đăng nhập', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shield_outlined, color: primaryColor, size: 50),
                ),
                const SizedBox(height: 30),
                const Text('SafeTrek Vietnam', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Đăng nhập để tiếp tục', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 40),

                _buildInputLabel('Tên đăng nhập hoặc email'),
                _buildTextField(_identifierController, 'Nhập tên đăng nhập hoặc email'),
                const SizedBox(height: 15),

                _buildInputLabel('Mật khẩu'),
                _buildTextField(_passwordController, 'Nhập mật khẩu', isObscure: true),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text('Đăng ký tài khoản mới', style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 5),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        ),
      ),
    );
  }
}