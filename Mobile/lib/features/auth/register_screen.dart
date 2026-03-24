// Mobile/lib/features/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ve_si_ao/core/constants/api_constants.dart'; 
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty || _emailController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ các thông tin bắt buộc (*)");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl), // Hết đỏ dòng này
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': _usernameController.text.trim(),
          'FullName': _fullNameController.text.trim(),
          'Email': _emailController.text.trim(),
          'PlaintextPassword': _passwordController.text,
          'PhoneNumber': _phoneController.text.trim(),
          'Role': 'user'
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = {'message': 'Server phản hồi không đúng định dạng.'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog("Đăng ký thành công! Bạn có thể dùng Tên đăng nhập để đăng nhập.");
      } else {
        _showErrorDialog(data['message'] ?? "Đăng ký thất bại.");
      }
    } catch (e) {
      _showErrorDialog("Lỗi kết nối: Kiểm tra IP trong api_constants.dart và đảm bảo Backend đã bật!");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thành công', style: TextStyle(color: Colors.green)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            }, 
            child: const Text('ĐĂNG NHẬP NGAY')
          )
        ],
      ),
    );
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
        leading: const BackButton(color: Colors.black),
        title: const Text('Đăng ký', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shield_outlined, color: primaryColor, size: 45),
                ),
                const SizedBox(height: 25),
                const Text('SafeTrek Vietnam', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 35),

                _buildInputLabelWithStar('Tên đăng nhập'),
                _buildTextField(_usernameController, 'Nhập tên đăng nhập'),
                const SizedBox(height: 15),

                _buildInputLabelWithStar('Mật khẩu'),
                _buildTextField(_passwordController, 'Nhập mật khẩu', isObscure: true),
                const SizedBox(height: 15),

                _buildInputLabel('Họ và tên'),
                _buildTextField(_fullNameController, 'Nhập họ và tên'),
                const SizedBox(height: 15),

                _buildInputLabelWithStar('Email'),
                _buildTextField(_emailController, 'Nhập email'),
                const SizedBox(height: 15),

                _buildInputLabel('Số điện thoại'),
                _buildTextField(_phoneController, 'Nhập số điện thoại', isNumber: true),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('XÁC NHẬN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabelWithStar(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 5),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool isObscure = false, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
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