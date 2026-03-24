import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'alert_model.dart';
import '../../core/constants/api_constants.dart';

class AlertProvider extends ChangeNotifier {
  List<AlertModel> _alerts = [];
  List<AlertModel> _history = [];
  int _monthlyCount = 0;
  int _dailyCount = 0;
  String? _keyword = '';
  DateTimeRange? _timeRange;
  String? _activeAlertId;

  int get monthlyCount => _monthlyCount;
  int get dailyCount => _dailyCount;
  List<AlertModel> get history => _history;
  String? get activeAlertId => _activeAlertId;

  Future<void> fetchAlerts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Alerts/unhandled'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _alerts = data.map((json) => AlertModel(
          id: json['id'].toString(),
          userName: json['userName'] ?? 'Unknown',
          alertType: json['alertType'] ?? 'SOS',
          createdAt: DateTime.parse(json['createdAt']),
          isHandled: json['isHandled'] ?? false,
          location: json['location'] ?? '',
          message: json['message'] ?? '',
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching alerts: $e");
    }
  }

  Future<String?> sendSOS({required String userName}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Alerts'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userName": userName,
          "alertType": "SOS",
          "location": "10.762622, 106.660172",
          "message": "Tôi đang gặp nguy hiểm, cần cứu trợ khẩn cấp!",
          "isHandled": false
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _activeAlertId = data['id'].toString();
        notifyListeners();
        return _activeAlertId;
      }
    } catch (e) {
      print("Error sending SOS: $e");
    }
    return null;
  }

  Future<bool> markAsSafe(String id) async {
    try {
      final response = await http.put(Uri.parse('${ApiConstants.baseUrl}/Alerts/$id/resolve'));
      if (response.statusCode == 204 || response.statusCode == 200) {
        if (_activeAlertId == id) _activeAlertId = null;
        _alerts.removeWhere((a) => a.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error marking as safe: $e");
    }
    return false;
  }

  Future<void> fetchAlertStats() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Alerts/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _monthlyCount = data['monthlyCount'] ?? 0;
        _dailyCount = data['dailyCount'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching alert stats: $e");
    }
  }

  Future<void> fetchAlertHistory() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Alerts/history'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _history = data.map((json) => AlertModel(
          id: json['id'].toString(),
          userName: json['userName'] ?? 'Unknown',
          alertType: json['alertType'] ?? 'SOS',
          createdAt: DateTime.parse(json['createdAt']),
          isHandled: json['isHandled'] ?? false,
          location: json['location'] ?? '',
          message: json['message'] ?? '',
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching alert history: $e");
    }
  }

  Future<void> resolveAlert(String id) async {
    try {
      final response = await http.put(Uri.parse('${ApiConstants.baseUrl}/Alerts/$id/resolve'));
      if (response.statusCode == 204 || response.statusCode == 200) {
        _alerts.removeWhere((a) => a.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error resolving alert: $e");
    }
  }

  List<AlertModel> get unHandledAlerts {
    return _alerts.where((alert) {
      final matchKeyword = alert.userName.toLowerCase().contains(_keyword!.toLowerCase());
      final matchTime = _timeRange == null
          ? true
          : alert.createdAt.isAfter(_timeRange!.start) && alert.createdAt.isBefore(_timeRange!.end);
      return !alert.isHandled && matchKeyword && matchTime;
    }).toList();
  }

  void search(String value) {
    _keyword = value;
    notifyListeners();
  }

  void filterByTime(DateTimeRange? range) {
    _timeRange = range;
    notifyListeners();
  }
}
