import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/emergency_contact_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Lưu/Cập nhật thông tin User
  // Liên kết: Lưu vào collection 'users' với ID là uid
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Lỗi khi lưu User: $e');
    }
  }

  // 2. Thêm liên hệ khẩn cấp (QUAN TRỌNG: Tạo Sub-collection)
  // Liên kết: users -> {userId} -> emergency_contacts -> {contactId}
  Future<void> addEmergencyContact(String userId, EmergencyContactModel contact) async {
    try {
      // Dùng .doc().set() để tự tạo ID nếu contact.id rỗng, hoặc dùng .add()
      final contactRef = _db
          .collection('users')
          .doc(userId) // <-- Đi vào đúng User cha
          .collection('emergency_contacts') // <-- Tạo bảng con
          .doc(); // Tự sinh ID ngẫu nhiên

      // Lưu contact với ID vừa sinh ra
      final newContact = EmergencyContactModel(
        id: contactRef.id, 
        name: contact.name, 
        phoneNumber: contact.phoneNumber, 
        relation: contact.relation
      );

      await contactRef.set(newContact.toMap());
    } catch (e) {
      throw Exception('Lỗi thêm danh bạ: $e');
    }
  }

  // 3. Lấy danh sách liên hệ khẩn cấp của một User
  Stream<List<EmergencyContactModel>> getEmergencyContacts(String userId) {
    return _db
        .collection('users')
        .doc(userId) // <-- Chỉ lấy của User này
        .collection('emergency_contacts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmergencyContactModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}