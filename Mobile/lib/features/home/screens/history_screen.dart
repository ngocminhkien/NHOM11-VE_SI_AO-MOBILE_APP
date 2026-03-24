import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; 
  List<Map<String, dynamic>> trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips(); // Gọi API ngay khi mở màn hình
  }

  // HÀM GỌI API LẤY LỊCH SỬ
  Future<void> fetchTrips() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5134/api/Trip/user/user-test-001'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> tripsData = responseData['data'];
        
        if (!mounted) return;
        setState(() {
          trips = tripsData.map((trip) => {
            "title": trip['title'] ?? "Không có tên",
            "time": trip['time'] ?? "",
            "status": trip['status'] ?? "Không rõ",
          }).toList().reversed.toList(); // Đảo ngược để chuyến mới nhất lên đầu
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              const Text('Lịch sử', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // === HAI NÚT CHUYỂN TAB ===
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () { setState(() { _selectedTab = 0; }); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? const Color(0xFF0095FF) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('Chuyến đi', style: TextStyle(color: _selectedTab == 0 ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () { setState(() { _selectedTab = 1; }); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFFFF8A8A) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('Cảnh báo', style: TextStyle(color: _selectedTab == 1 ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === KHU VỰC HIỂN THỊ DỮ LIỆU ===
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : (_selectedTab == 0 
                      ? (trips.isEmpty ? _buildEmptyState('Chưa có dữ liệu chuyến đi') : _buildTripList())
                      : _buildEmptyState('Chưa có dữ liệu cảnh báo')), // Tab cảnh báo tạm thời để trống
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(message, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(trip['time'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Text(trip['status'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}