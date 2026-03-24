import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // THƯ VIỆN GỌI ĐIỆN/NHẮN TIN

class EmergencyNotificationScreen extends StatefulWidget {
  const EmergencyNotificationScreen({super.key});

  @override
  State<EmergencyNotificationScreen> createState() => _EmergencyNotificationScreenState();
}

class _EmergencyNotificationScreenState extends State<EmergencyNotificationScreen> {
  bool _isLoading = true;
  String _userName = "Người dùng";
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadDataAndSendSOS(); // Tự động chạy khi vừa mở màn hình
  }

  // ==========================================
  // HÀM 1: LẤY DANH BẠ TỪ C#
  // ==========================================
  Future<void> _loadDataAndSendSOS() async {
    try {
      // 1. Mở két sắt lấy thông tin
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('userId') ?? "";
      _userName = prefs.getString('fullName') ?? "Người dùng";

      if (userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Gọi API lấy danh bạ
      final response = await http.get(Uri.parse('http://localhost:5134/api/EmergencyContact/user/$userId'));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        
        setState(() {
          _contacts = data.map((c) => {
            "name": c['name'] ?? "Không tên",
            "phone": c['phoneNumber'] ?? c['phone'] ?? "",
            "relation": c['relation'] ?? "Người thân",
          }).toList();
          _isLoading = false;
        });

        // 3. Tự động bật App nhắn tin nếu có danh bạ
        if (_contacts.isNotEmpty) {
          _openSMSApp();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải danh bạ từ Server.')));
      }
    }
  }

  // ==========================================
  // HÀM 2: MỞ APP TIN NHẮN VÀ SOẠN SẴN NỘI DUNG
  // ==========================================
  Future<void> _openSMSApp() async {
    if (_contacts.isEmpty) return;

    // Gom tất cả số điện thoại lại (cách nhau dấu phẩy)
    List<String> phones = _contacts.map((c) => c['phone'].toString()).toList();
    String phoneNumbers = phones.join(',');

    // Soạn tin nhắn khẩn cấp
    String message = "SOS KHẨN CẤP!!!\nTôi là $_userName. Hiện tại tôi đang gặp nguy hiểm. Vui lòng liên hệ với tôi ngay lập tức!";

    // Cấu trúc Uri cho SMS
    final Uri smsUri = Uri.parse('sms:$phoneNumbers?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điện thoại của bạn không hỗ trợ mở App tin nhắn.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi khi mở App tin nhắn.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F), // Màu đỏ nền khẩn cấp
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('CẢNH BÁO SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // === KHỐI 1: BIỂU TƯỢNG BÁO ĐỘNG ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[300]!.withOpacity(0.5), shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.priority_high, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            const Text('Đang phát tín hiệu SOS...', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // NÚT MỞ APP TIN NHẮN (Dành cho trường hợp nó không tự bật)
            ElevatedButton.icon(
              onPressed: _openSMSApp,
              icon: const Icon(Icons.sms, color: Color(0xFFD32F2F)),
              label: const Text('GỬI TIN NHẮN SMS NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const Spacer(),

            // === KHỐI 2: HIỂN THỊ DANH SÁCH NGƯỜI THÂN ĐANG GỌI ===
            Container(
              width: double.infinity, margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Đang gửi tin nhắn khẩn cấp tới:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  
                  // Khu vực đổ dữ liệu danh bạ
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : (_contacts.isEmpty ? _buildEmptyContacts() : _buildContactList()),
                  
                  const SizedBox(height: 25),
                  
                  // NÚT TÔI ĐÃ AN TOÀN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Sau này có thể gọi thêm API đổi Status chuyến đi về "An Toàn" ở đây
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Tôi đã an toàn (Hủy SOS)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContacts() {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text('Chưa có liên hệ nào được thiết lập.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: _contacts.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Text('${c['name']} (${c['relation']})', style: const TextStyle(fontSize: 16)),
          ],
        ),
      )).toList(),
    );
  }
}