import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/providers/requestProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EmergencyRequestPage extends ConsumerStatefulWidget {
  const EmergencyRequestPage({super.key});

  @override
  ConsumerState<EmergencyRequestPage> createState() =>
      _EmergencyRequestPageState();
}

bool _isSubmitting = false;

class _EmergencyRequestPageState extends ConsumerState<EmergencyRequestPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedGarageId;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      _showErrorSnackBar('فشل في الحصول على الموقع: ${e.toString()}');
    }
  }

  Map<String, double> _parseLocation(dynamic locationData) {
    try {
      if (locationData is String) {
        final locationJson = jsonDecode(locationData);
        return {
          'latitude': (locationJson['latitude'] as num).toDouble(),
          'longitude': (locationJson['longitude'] as num).toDouble(),
        };
      } else if (locationData is Map<String, dynamic>) {
        return {
          'latitude': (locationData['latitude'] as num).toDouble(),
          'longitude': (locationData['longitude'] as num).toDouble(),
        };
      }
      throw Exception('Invalid location type');
    } catch (e) {
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  double _calculateDistance(dynamic locationData) {
    if (_currentPosition == null) return 0.0;

    final location = _parseLocation(locationData);
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          location['latitude']!,
          location['longitude']!,
        ) /
        1000;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userName =
        userInfo != null ? userInfo['name'] ?? 'بدون اسم' : 'جاري التحميل...';
    final subscribedGarages = ref.watch(clientGaragesProvider(userId!));
    final allGarages = ref.watch(garageLocationsProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : _buildResponsiveLayout(
              allGarages, subscribedGarages, userId, userName, lang),
    );
  }

  Widget _buildResponsiveLayout(
    AsyncValue<List<dynamic>> allGarages,
    AsyncValue<List<dynamic>> subscribedGarages,
    String userId,
    String userName,
    Map<String, dynamic> lang,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Flex(
          direction: isWideScreen ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(child: _buildMapSection(allGarages)),
            Expanded(
                child: _buildContentSection(
                    subscribedGarages, userId, userName, lang)),
          ],
        );
      },
    );
  }

  Widget _buildMapSection(AsyncValue<List<dynamic>> allGarages) {
    return allGarages.when(
      data: (garages) => FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              _buildUserMarker(),
              ..._buildGarageMarkers(garages),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ في الخريطة: $error')),
    );
  }

  Marker _buildUserMarker() {
    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 40,
      height: 40,
      child: const Icon(
        Icons.person_pin_circle,
        color: Colors.blue,
        size: 40,
      ),
    );
  }

  List<Marker> _buildGarageMarkers(List<dynamic> garages) {
    return garages.map((garage) {
      final location = _parseLocation(garage['location']);
      final isSelected = garage['garageId'] == _selectedGarageId;

      return Marker(
        point: LatLng(location['latitude']!, location['longitude']!),
        width: 35,
        height: 35,
        child: Icon(
          Icons.local_car_wash,
          color: isSelected ? Colors.red : Colors.green,
          size: 35,
        ),
      );
    }).toList();
  }

  Widget _buildContentSection(
    AsyncValue<List<dynamic>> subscribedGarages,
    String userId,
    String userName,
    Map<String, dynamic> lang,
  ) {
    return subscribedGarages.when(
      data: (subscribed) =>
          _buildMainContent(subscribed, userId, userName, lang),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ في البيانات: $error')),
    );
  }

  Widget _buildMainContent(List<dynamic> subscribedGarages, String userId,
      String userName, Map<String, dynamic> lang) {
    final allGarages = ref.watch(garageLocationsProvider);
    final subscribedIds = subscribedGarages.map((g) => g['garageId']).toSet();

    return allGarages.when(
      data: (all) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGarageList(all, subscribedIds, lang),
            _buildRequestForm(lang),
            _buildSubmitButton(userId, userName, lang),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ في الكراجات: $error')),
    );
  }

  Widget _buildGarageList(List<dynamic> garages, Set<dynamic> subscribedIds,
      Map<String, dynamic> lang) {
    final sortedGarages = _sortGaragesByDistance(garages);

    return Column(
      children: [
        Text(
          lang['available_garages'] ?? 'الكراجات المتاحة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...sortedGarages
            .map((garage) => _buildGarageTile(garage, subscribedIds)),
      ],
    );
  }

  List<dynamic> _sortGaragesByDistance(List<dynamic> garages) {
    return garages
      ..sort(
        (a, b) => _calculateDistance(a['location'])
            .compareTo(_calculateDistance(b['location'])),
      );
  }

  Widget _buildGarageTile(dynamic garage, Set<dynamic> subscribedIds) {
    final distance = _calculateDistance(garage['location']).toStringAsFixed(1);
    print("subscribedIds: $subscribedIds");
    print("garageId: ${garage['garageId']}");
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(garage['name'] ?? 'بدون اسم'),
        subtitle: Text('المسافة: $distance كم'),
        trailing: subscribedIds.contains(garage['garageId'])
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        selected: _selectedGarageId == garage['garageId'],
        selectedTileColor: Colors.orange.withOpacity(0.1),
        onTap: () => setState(() => _selectedGarageId = garage['garageId']),
      ),
    );
  }

  Widget _buildRequestForm(
    Map<String, dynamic> lang,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        controller: _messageController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: lang['emergency_details'] ?? 'تفاصيل الطوارئ',
          border: OutlineInputBorder(),
          hintText: lang['enter_details'] ?? 'أدخل تفاصيل الطوارئ هنا',
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      String userId, String userName, Map<String, dynamic> lang) {
    return ElevatedButton.icon(
      icon: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send, size: 24),
      label: Text(
        _isSubmitting
            ? (lang['sending'] ?? 'جاري الإرسال...')
            : (lang['submit_request'] ?? 'إرسال الطلب'),
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed:
          _isSubmitting ? null : () => _handleSubmit(userId, userName, lang),
    );
  }

  Future<void> _handleSubmit(
    String userId,
    String userName,
    Map<String, dynamic> lang,
  ) async {
    if (_messageController.text.isEmpty || _selectedGarageId == null) {
      _showErrorSnackBar(
          lang['enter_message'] ?? 'يرجى إدخال رسالة و اختيار كراج');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(addRequestProvider).call({
        'userId': userId,
        'garageId': _selectedGarageId,
        'message': _messageController.text,
        'location': jsonEncode({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        }),
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'معلق',
      });

      await ref.read(notificationsProvider.notifier).sendNotification(
            adminId: userId,
            messageTitle: lang['EmergencyRequest'] ?? 'طلب طوارئ',
            messageBody: _messageController.text,
            garageId: _selectedGarageId,
            senderName: userName,
            type: 'message',
          );

      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang['request_sent'] ?? 'تم إرسال الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(
          '${lang['error_sending_request'] ?? 'حدث خطأ أثناء إرسال الطلب'}: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
