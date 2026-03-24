import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import '../../core/constants/api_constants.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  List<User> get users => _users;
  int _newUsersToday = 0;
  int get newUsersToday => _newUsersToday;
  int _totalTrips = 0;
  int get totalTrips => _totalTrips;
  String _searchQuery = '';
  bool _sortAZ = true;

  String get searchQuery => _searchQuery;
  bool get sortAZ => _sortAZ;

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map((json) => User(
          name: json['fullName'] ?? json['username'],
          phone: json['phoneNumber'] ?? 'Chưa cập nhật',
          createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Users/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _newUsersToday = data['newUsersToday'] ?? 0;
        _totalTrips = data['totalTrips'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user stats: $e");
    }
  }

  void addUser(String name, String phone) {
    // Implement API call if needed, otherwise read-only for admin
  }

  void setSort(bool az) {
    _sortAZ = az;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<User> get filteredUsers {
    List<User> list = _users;
    if (_searchQuery.isNotEmpty) {
      list = list.where((u) => 
        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        u.phone.contains(_searchQuery)).toList();
    }
    list.sort((a, b) => _sortAZ ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return list;
  }
}