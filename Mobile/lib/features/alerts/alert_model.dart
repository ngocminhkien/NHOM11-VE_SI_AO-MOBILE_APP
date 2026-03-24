class AlertModel {
  final String id;
  final String userName;
  final String alertType;
  final DateTime createdAt;
  final bool isHandled;
  final String location;
  final String message;

  AlertModel({
    required this.id,
    required this.userName,
    required this.alertType,
    required this.createdAt,
    this.isHandled = false,
    this.location = '',
    this.message = '',
  });
}
