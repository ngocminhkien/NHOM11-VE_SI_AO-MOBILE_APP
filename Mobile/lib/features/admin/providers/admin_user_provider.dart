import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/admin_user_model.dart';

class AdminUserProvider extends ChangeNotifier {
  List<AdminUserModel> _users = [];
  int _totalCount = 0;
  int _activeCount = 0;
  int _dailyCount = 0;
  int _blockedCount = 0;
  bool _isLoading = false;

  List<AdminUserModel> get users => _users;
  int get totalCount => _totalCount;
  int get activeCount => _activeCount;
  int get dailyCount => _dailyCount;
  int get blockedCount => _blockedCount;
  bool get isLoading => _isLoading;

  AdminUserProvider() {
    fetchUsers();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.usersUrl}/stats"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _totalCount = data['totalCount'] ?? 0;
        _activeCount = data['activeCount'] ?? 0;
        _dailyCount = data['dailyCount'] ?? 0;
        _blockedCount = data['blockedCount'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Fetch users stats error: $e");
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiConstants.usersUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((json) => AdminUserModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Fetch users error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUser(AdminUserModel user) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.usersUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 200) {
        fetchUsers();
        fetchUserStats();
        return true;
      }
    } catch (e) {
      print("Add user error: $e");
    }
    return false;
  }

  Future<bool> updateUser(AdminUserModel user) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.usersUrl}/${user.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 204) {
        fetchUsers();
        fetchUserStats();
        return true;
      }
    } catch (e) {
      print("Update user error: $e");
    }
    return false;
  }
}
