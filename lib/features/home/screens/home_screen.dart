import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Đảm bảo import đúng đường dẫn 3 file này
import '../../../data/models/user_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ID CỦA BẠN (Thay bằng ID thật trên Firebase của bạn) ---
  final String currentUserId = "PuC4cRSmYdq9IhuxsqJi"; 

  final TripRepository _tripRepo = TripRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vệ Sĩ Ảo (Real Data)"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: HIỂN THỊ THÔNG TIN USER ---
            const Text("Thông tin tài khoản:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Kiểm tra trạng thái loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Sửa lỗi !snapshot.exists thành !snapshot.data!.exists
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Lỗi: Không tìm thấy ID này trên Firebase! Hãy kiểm tra lại currentUserId.");
                }

                // 3. Convert dữ liệu an toàn
                try {
                  UserModel user = UserModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>, 
                    snapshot.data!.id
                  );

                  return Card(
                    elevation: 4,
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.role == 'admin' ? 'A' : 'U'),
                      ),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${user.email}"),
                          Text("Chức vụ: ${user.role.toUpperCase()}", style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  return Text("Lỗi đọc dữ liệu: $e");
                }
              },
            ),

            const SizedBox(height: 40),

            // --- PHẦN 2: CHỨC NĂNG TẠO CHUYẾN ĐI ---
            const Text("Chức năng demo:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("BẮT ĐẦU CHUYẾN ĐI MỚI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);

                  try {
                    // Tạo dữ liệu chuyến đi khớp với TripModel bạn đã định nghĩa
                    final newTrip = TripModel(
                      id: "", // Firebase tự sinh
                      userId: currentUserId,
                      // SỬA LỖI: Thêm các tham số bắt buộc còn thiếu
                      startLocationName: "Vị trí hiện tại (Hà Nội)", 
                      endLocationName: "Chưa xác định",
                      // SỬA LỖI: Đổi startLocation thành startCoordinates
                      startCoordinates: const GeoPoint(21.0285, 105.8542), 
                      startTime: DateTime.now(),
                      estimatedDurationMinutes: 0, 
                      status: 'active',
                    );

                    // Gọi Repository
                    String tripId = await _tripRepo.createTrip(newTrip);

                    // Hiển thị thông báo (Sửa lỗi Async gap)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Thành công! ID chuyến đi: $tripId")),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}