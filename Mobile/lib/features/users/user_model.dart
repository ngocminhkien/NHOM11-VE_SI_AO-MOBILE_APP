class User {
  final String name;
  final String phone;
  final DateTime createdAt;
  bool isOnline;

  User({
    required this.name, 
    required this.phone, 
    required this.createdAt, 
    this.isOnline = false, // Mặc định offline (xám)
  });
}