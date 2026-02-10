import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final String role; // Biến này quan trọng để phân quyền

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    this.role = 'user', // Mặc định là user nếu không truyền vào
  });

  // Chuyển từ JSON (Firestore) sang Object (Dart)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      avatarUrl: data['avatarUrl'],
      // Xử lý an toàn cho thời gian
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      role: data['role'] ?? 'user', 
    );
  }

  // Chuyển từ Object (Dart) sang JSON (để lưu lên Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role,
    };
  }
}