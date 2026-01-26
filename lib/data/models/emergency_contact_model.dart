class EmergencyContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String relation; // Bố, Mẹ, Bạn bè...
  final bool isVerified; // Đã xác thực số chưa

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relation,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relation': relation,
      'isVerified': isVerified,
    };
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> data, String id) {
    return EmergencyContactModel(
      id: id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      relation: data['relation'] ?? '',
      isVerified: data['isVerified'] ?? false,
    );
  }
}