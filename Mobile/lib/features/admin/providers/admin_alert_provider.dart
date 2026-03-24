import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_core/signalr_core.dart';
import '../../../core/constants/api_constants.dart';
import '../models/admin_alert_model.dart';

class AdminAlertProvider extends ChangeNotifier {
  List<AdminAlertModel> _alerts = [];
  int _monthlyCount = 0;
  int _dailyCount = 0;
  bool _isLoading = false;
  HubConnection? _hubConnection;

  List<AdminAlertModel> get alerts => _alerts;
  List<AdminAlertModel> get unhandledAlerts => _alerts.where((a) => !a.isHandled).toList();
  int get monthlyCount => _monthlyCount;
  int get dailyCount => _dailyCount;
  bool get isLoading => _isLoading;

  AdminAlertProvider() {
    _initSignalR();
    _startSignalR();
    fetchAlerts();
    fetchUserStats();
  }

  void _initSignalR() {
    _hubConnection = HubConnectionBuilder()
        .withUrl(ApiConstants.alertHubUrl, HttpConnectionOptions(
          logging: (level, message) => print('SignalR: $message'),
        ))
        .build();

    _hubConnection?.onclose((error) => print("SignalR Connection Closed"));

    _hubConnection?.on("ReceiveAlert", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final newAlertJson = arguments[0] as Map<String, dynamic>;
        final newAlert = AdminAlertModel.fromJson(newAlertJson);
        _alerts.insert(0, newAlert);
        notifyListeners();
      }
    });

    // _startSignalR(); // Removed from here as it's called in the constructor now
  }

  Future<void> _startSignalR() async {
    try {
      await _hubConnection?.start();
      print("SignalR Connected");
      await _hubConnection?.invoke("JoinAdminGroup");
    } catch (e) {
      print("SignalR start error: $e");
    }
  }

  Future<void> fetchUserStats() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.usersUrl}/stats"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _monthlyCount = data['monthlyCount'] ?? 0;
        _dailyCount = data['dailyCount'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Fetch user stats error: $e");
    }
  }

  Future<void> fetchAlerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiConstants.unhandledAlertsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _alerts = data.map((json) => AdminAlertModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Fetch alerts error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveAlert(int id) async {
    try {
      final response = await http.put(Uri.parse(ApiConstants.resolveAlertUrl(id)));
      if (response.statusCode == 204) {
        _alerts.removeWhere((a) => a.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Resolve alert error: $e");
    }
  }

  @override
  void dispose() {
    _hubConnection?.stop();
    super.dispose();
  }
}
