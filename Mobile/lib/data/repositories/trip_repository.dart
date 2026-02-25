import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Bắt đầu chuyến đi mới
  // Liên kết: Lưu userId vào trong document Trip để biết chuyến này của ai
  Future<String> createTrip(TripModel trip) async {
    try {
      DocumentReference docRef = await _db.collection('trips').add(trip.toMap());
      return docRef.id; // Trả về ID chuyến đi để theo dõi tiếp
    } catch (e) {
      throw Exception('Lỗi tạo chuyến đi: $e');
    }
  }

  // 2. Cập nhật vị trí di chuyển (Dùng cho tính năng Theo dõi)
  Future<void> updateTripLocation(String tripId, GeoPoint newLocation) async {
    try {
      await _db.collection('trips').doc(tripId).update({
        // Cập nhật vị trí hiện tại (để người thân xem)
        'currentLocation': newLocation, 
        // Thêm vào lịch sử đường đi (để vẽ line trên bản đồ)
        'routePath': FieldValue.arrayUnion([newLocation]), 
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật vị trí: $e');
    }
  }

  // 3. Bật báo động SOS
  Future<void> triggerSOS(String tripId, String message) async {
    try {
      await _db.collection('trips').doc(tripId).update({
        'status': 'sos', // <-- Đổi trạng thái để App người thân rú chuông
        'sosMessage': message,
        'sosTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi gửi SOS: $e');
    }
  }
  
  // 4. Kết thúc chuyến đi
  Future<void> completeTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(),
    });
  }
}