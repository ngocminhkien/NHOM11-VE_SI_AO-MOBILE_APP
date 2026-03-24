import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';

class UserProvider extends ChangeNotifier {
  List<dynamic> _users = [];
  int _newUsersCount = 0;

  List<dynamic> get users => _users;
  int get newUsersCount => _newUsersCount;

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Users'));
      if (response.statusCode == 200) {
        _users = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchUserStats() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Users/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _newUsersCount = data['newUsersToday'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user stats: $e");
    }
  }
}
