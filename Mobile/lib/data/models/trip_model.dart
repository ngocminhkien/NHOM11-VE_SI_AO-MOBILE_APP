import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String startLocationName; // Tên điểm đi
  final String endLocationName;   // Tên điểm đến
  final GeoPoint? startCoordinates; // Tọa độ đi (Lat, Long)
  final GeoPoint? endCoordinates;   // Tọa độ đến
  final DateTime startTime;
  final int estimatedDurationMinutes; // Thời gian dự kiến (phút)
  final String status; // 'active', 'completed', 'sos'
  final List<GeoPoint> routePath; // Mảng lưu lịch sử di chuyển để vẽ lại đường

  TripModel({
    required this.id,
    required this.userId,
    required this.startLocationName,
    required this.endLocationName,
    this.startCoordinates,
    this.endCoordinates,
    required this.startTime,
    required this.estimatedDurationMinutes,
    this.status = 'active',
    this.routePath = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startLocationName': startLocationName,
      'endLocationName': endLocationName,
      'startCoordinates': startCoordinates,
      'endCoordinates': endCoordinates,
      'startTime': Timestamp.fromDate(startTime),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'status': status,
      // Chuyển List<GeoPoint> thành List<Map> nếu cần, nhưng Firestore hỗ trợ Array GeoPoint
      'routePath': routePath, 
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> data, String id) {
    return TripModel(
      id: id,
      userId: data['userId'] ?? '',
      startLocationName: data['startLocationName'] ?? '',
      endLocationName: data['endLocationName'] ?? '',
      startCoordinates: data['startCoordinates'],
      endCoordinates: data['endCoordinates'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      estimatedDurationMinutes: data['estimatedDurationMinutes'] ?? 0,
      status: data['status'] ?? 'active',
      routePath: List<GeoPoint>.from(data['routePath'] ?? []),
    );
  }
}