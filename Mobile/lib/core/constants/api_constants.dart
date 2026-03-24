class ApiConstants {
  // === CHỈ SỬA 1 DÒNG NÀY THEO THIẾT BỊ ĐANG DÙNG ===
  // 1. Máy ảo Android: dùng '10.0.2.2'
  // 2. Web hoặc Máy ảo iOS: dùng 'localhost'
  // 3. Điện thoại thật: dùng IP máy tính (ví dụ '192.168.1.5')
  static const String _host = 'localhost';
  static const String _port = '5134';

  static const String baseUrl = 'http://$_host:$_port/api';

  // Danh sách các đường dẫn API
  static const String registerUrl = '$baseUrl/Users/register';
  static const String loginUrl = '$baseUrl/Users/login';
  static const String usersUrl = '$baseUrl/Users';
  static const String alertsUrl = '$baseUrl/Alerts';
  static const String tripUrl = '$baseUrl/Trip';
  static const String unhandledAlertsUrl = '$baseUrl/Alerts/unhandled';
  static const String alertStatsUrl = '$baseUrl/Alerts/stats';
  static const String alertHistoryUrl = '$baseUrl/Alerts/history';
  static String resolveAlertUrl(int id) => '$baseUrl/Alerts/$id/resolve';
  
  static const String alertHubUrl = 'http://$_host:$_port/hubs/alerts';
}
