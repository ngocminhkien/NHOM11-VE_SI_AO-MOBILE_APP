import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../alerts/alert_provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // Controller để điều khiển việc đóng mở Sheet bằng code
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  
  // Biến kiểm tra trạng thái đang mở hay đóng để đổi icon mũi tên
  bool _isExpanded = false;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi ấn vào thanh tiêu đề
  void _toggleSheet() {
    if (_isExpanded) {
      // Nếu đang mở -> Thu nhỏ về 0.15 (15% màn hình)
      _sheetController.animateTo(
        0.15,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Nếu đang đóng -> Mở rộng lên 0.85 (85% màn hình)
      _sheetController.animateTo(
        0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Cập nhật biến trạng thái
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertP = context.watch<AlertProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lịch sử cảnh báo (Liên hệ)"),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // --- LỚP 1: PHẦN NỀN (THỐNG KÊ) ---
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStaticSummary(alertP),
                      _buildStaticSummary(alertP),
                    ],
                  ),
                ),
              ),

              // --- LỚP 2: SHEET GHI ĐÈ (CÓ THỂ ẤN ĐƯỢC) ---
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.15, // Kích thước ban đầu (nhỏ)
                minChildSize: 0.15,     // Kích thước nhỏ nhất
                maxChildSize: 0.85,     // Kích thước lớn nhất
                snap: true,             // Tự động hít vào mốc
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, -2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // --- NÚT BẤM (HEADER) ---
                        // Bọc toàn bộ phần Header bằng InkWell để bắt sự kiện click
                        InkWell(
                          onTap: _toggleSheet, // Gán hàm toggle vào đây
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            child: Column(
                              children: [
                                // Thanh gạch ngang trang trí
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                // Nội dung Header
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Danh sách liên hệ",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 5),
                                          // Mũi tên chỉ hướng thay đổi theo trạng thái
                                          Icon(
                                            _isExpanded 
                                              ? Icons.keyboard_arrow_down_rounded 
                                              : Icons.keyboard_arrow_up_rounded,
                                            color: Colors.blue,
                                          )
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${alertP.history.length} báo cáo",
                                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                              ],
                            ),
                          ),
                        ),

                        // --- DANH SÁCH (LIST VIEW) ---
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController, // Vẫn giữ kết nối scroll
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: alertP.history.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final a = alertP.history[i];
                              return _buildSwipeableItem(context, a, i);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }
      ),
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ (Giữ nguyên) ---
  Widget _buildStaticSummary(AlertProvider p) {
    return Column(
      children: [
        Row(
          children: [
            _summaryBox("Tổng tháng qua", "${p.monthlyCount}", Colors.blue),
            const SizedBox(width: 15),
            _summaryBox("Mới hôm nay", "${p.dailyCount}", Colors.orange),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _summaryBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }



    Widget _buildSwipeableItem(BuildContext context, dynamic a, int index) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.orange[50],
          child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        ),
        title: Text(a.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("${a.alertType} • ${a.createdAt.day}/${a.createdAt.month}"),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () {
          // Show details
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Chi tiết: ${a.userName}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loại: ${a.alertType}"),
                  Text("Thời gian: ${a.createdAt}"),
                  Text("Vị trí: ${a.location}"),
                  Text("Lời nhắn: ${a.message}"),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))
              ],
            )
          );
        },
      );
    }
}