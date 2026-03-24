class AdminAlertModel {
  final int id;
  final String userName;
  final String alertType;
  final DateTime createdAt;
  final bool isHandled;
  final String location;
  final String message;

  AdminAlertModel({
    required this.id,
    required this.userName,
    required this.alertType,
    required this.createdAt,
    this.isHandled = false,
    this.location = '',
    this.message = '',
  });

  factory AdminAlertModel.fromJson(Map<String, dynamic> json) {
    return AdminAlertModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      alertType: json['alertType'] ?? 'SOS',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isHandled: json['isHandled'] ?? false,
      location: json['location'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
