import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class AdminTripProvider extends ChangeNotifier {
  int _todayTrips = 0;  // chuyến đi hôm nay
  int _totalTrips = 0;  // tổng tất cả chuyến đi
  bool _isLoading = false;

  int get todayTrips => _todayTrips;
  int get totalTrips => _totalTrips;
  bool get isLoading => _isLoading;

  AdminTripProvider() {
    fetchTripStats();
  }

  Future<void> fetchTripStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${ApiConstants.tripUrl}/stats/today'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _todayTrips = data['todayCount'] ?? 0;
        _totalTrips = data['totalCount'] ?? 0;
      }
    } catch (e) {
      print('Fetch trip stats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Keep old name for backwards compat
  Future<void> fetchTotalTrips() => fetchTripStats();
}
