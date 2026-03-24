import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  final LatLng _defaultLocation = const LatLng(21.0285, 105.8542); // Default Hanoi
  bool _isLoadingLocation = true;
  bool _isConfirming = false;
  
  // Variables for Address Debouncing
  Timer? _debounce;
  String _currentSelectedAddress = "Đang tải địa chỉ...";
  bool _isFetchingAddress = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // Quyền đã được kiểm tra ở màn SetupTripScreen, chỉ việc lấy vị trí
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentLocation!, 15.0);
        _fetchAddressForCenter(_currentLocation!); // Tải địa chỉ ngay từ vị trí đầu
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi lấy vị trí hiện tại.');
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _onMapMoved(MapCamera camera) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Đợi 500ms khi người dùng nhả tay / ngừng kéo bản đồ
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAddressForCenter(camera.center);
    });
  }

  Future<void> _fetchAddressForCenter(LatLng center) async {
    if (!mounted) return;
    setState(() {
      _isFetchingAddress = true;
      _currentSelectedAddress = "Đang tải địa chỉ...";
    });
    
    try {
      final addressUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${center.latitude}&lon=${center.longitude}&zoom=18&addressdetails=1'
      );
      final response = await http.get(addressUrl, headers: {
        'User-Agent': 'SafeTrekVietnamApp/1.0',
        'Accept-Language': 'vi'
      }).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _currentSelectedAddress = decoded['display_name'] ?? "Địa chỉ không xác định";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentSelectedAddress = "Không thể lấy địa chỉ";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentSelectedAddress = "Lỗi kết nối mạng khi tải địa chỉ";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onConfirmLocation() async {
    if (_currentLocation == null) {
      _showErrorSnackBar('Chưa xác định được vị trí hiện tại của bạn.');
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    try {
      final targetLocation = _mapController.camera.center;
      final targetLat = targetLocation.latitude;
      final targetLng = targetLocation.longitude;
      final currentLat = _currentLocation!.latitude;
      final currentLng = _currentLocation!.longitude;

      // Tính thời gian từ OSRM API (OSRM nhận tham số lon,lat)
      final osrmUrl = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$currentLng,$currentLat;$targetLng,$targetLat?overview=false'
      );
      final osrmResponse = await http.get(osrmUrl).timeout(const Duration(seconds: 10));
      
      int? minutes;
      if (osrmResponse.statusCode == 200) {
        final decodedRoute = jsonDecode(osrmResponse.body);
        
        // Bắt lỗi không tìm thấy lộ trình đường bộ
        if (decodedRoute['code'] == 'NoRoute') {
          _showErrorSnackBar('Không tìm thấy lộ trình đường bộ đến vị trí này.');
          setState(() => _isConfirming = false);
          return;
        }

        if (decodedRoute['routes'] != null && decodedRoute['routes'].isNotEmpty) {
          double durationSeconds = decodedRoute['routes'][0]['duration'] + 0.0;
          minutes = (durationSeconds / 60).ceil();
        }
      }

      if (minutes == null) {
        _showErrorSnackBar('Lỗi kết nối bộ định tuyến. Vui lòng thử lại sau.');
        setState(() => _isConfirming = false);
        return;
      }

      if (!mounted) return;
      // Trả về địa chỉ đã lấy qua Debounce và số phút
      Navigator.pop(context, {
        'address': _currentSelectedAddress,
        'minutes': minutes
      });
      
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra, vui lòng kiểm tra kết nối mạng.');
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn địa điểm đích', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 15.0,
              // Lắng nghe sự kiện di chuyển bản đồ để debounce gọi Nominatim
              onPositionChanged: (MapCamera camera, bool hasGesture) {
                if (hasGesture) {
                  _onMapMoved(camera);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ve_si_ao',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    )
                  ],
                ),
            ],
          ),
          
          // Crosshair pointer in center
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), 
              child: Icon(Icons.location_on, size: 40, color: Colors.red),
            ),
          ),
          
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
            
          // Khung hiển thị địa chỉ hiện hành
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Row(
                children: [
                   const Icon(Icons.location_city, color: Colors.redAccent, size: 24),
                   const SizedBox(width: 10),
                   Expanded(
                     child: Text(
                       _currentSelectedAddress,
                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   if (_isFetchingAddress)
                     const Padding(
                       padding: EdgeInsets.only(left: 10),
                       child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                     )
                ],
              )
            )
          ),
          
          // Nút quay về vị trí hiện tại
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, 15.0);
                  _onMapMoved(_mapController.camera); // update địa chỉ ngay
                }
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            )
          ),
          
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: (_isConfirming || _currentLocation == null) ? null : _onConfirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0095FF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isConfirming
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Xác nhận vị trí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
