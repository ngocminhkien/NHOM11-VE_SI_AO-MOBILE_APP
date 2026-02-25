import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Trạng thái tab đang chọn: 0 là Chuyến đi, 1 là Cảnh báo
  int _selectedTab = 0; 

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lịch sử', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 30),
                    onPressed: () {}, // Nút menu mở rộng sau này
                  )
                ],
              ),
              const SizedBox(height: 20),

              // === HAI NÚT CHUYỂN TAB (Chuyến đi / Cảnh báo) ===
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
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Center(
                          child: Text(
                            'Chuyến đi',
                            style: TextStyle(
                              color: _selectedTab == 0 ? Colors.white : Colors.black54,
                              fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16
                            ),
                          ),
                        ),
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
                          color: _selectedTab == 1 ? const Color(0xFFFF8A8A) : Colors.grey[200], // Màu hồng/đỏ nhạt như thiết kế
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Center(
                          child: Text(
                            'Cảnh báo',
                            style: TextStyle(
                              color: _selectedTab == 1 ? Colors.white : Colors.black54,
                              fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // === KHU VỰC HIỂN THỊ TRỐNG ===
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.directions_car_outlined, size: 40, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _selectedTab == 0 ? 'Chưa có dữ liệu chuyến đi' : 'Chưa có dữ liệu cảnh báo',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}