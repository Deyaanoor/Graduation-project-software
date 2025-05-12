import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedRequestProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

class RequestDetailsPage extends ConsumerWidget {
  const RequestDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(selectedRequestProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    if (request == null) {
      return Scaffold(
        appBar: isMobile ? _buildAppBar() : null,
        body: const Center(child: Text('لا توجد بيانات للعرض')),
      );
    }

    final location = request['location']?.toString() ?? '';
    final latLng = _extractLatLng(location);

    return Scaffold(
      appBar: isMobile ? _buildAppBar() : null,
      body: _buildBody(context, latLng, request),
      floatingActionButton: isMobile ? null : _buildDesktopFab(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('تفاصيل الطلب'),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade700, Colors.orange.shade400],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pop(context),
      backgroundColor: Colors.orange.shade600,
      child: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  Widget _buildBody(
      BuildContext context, LatLng latLng, Map<String, dynamic> request) {
    if (latLng == const LatLng(0.0, 0.0)) {
      return const Center(child: Text('الموقع غير صالح'));
    }

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white]),
      ),
      child: isDesktop
          ? _buildDesktopLayout(latLng, request)
          : _buildMobileLayout(latLng, request),
    );
  }

  Widget _buildDesktopLayout(LatLng latLng, Map<String, dynamic> request) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildMap(latLng),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: _buildMessage(request, true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(LatLng latLng, Map<String, dynamic> request) {
    return Column(
      children: [
        Expanded(
          child: _buildMap(latLng),
        ),
        _buildMessage(request, false),
      ],
    );
  }

  Widget _buildMap(LatLng latLng) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: latLng,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latLng,
              width: 50.0,
              height: 50.0,
              child: Icon(
                Icons.location_pin,
                color: Colors.red.shade700,
                size: 50.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessage(Map<String, dynamic> request, bool isDesktop) {
    return Container(
      margin: EdgeInsets.all(isDesktop ? 0 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'تفاصيل الطلب',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
                Text(
                  request['message']?.toString() ?? 'لا يوجد رسالة',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                if (!isDesktop) const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static LatLng _extractLatLng(String location) {
    try {
      final matches =
          RegExp(r'Lat:\s*([\d.]+),\s*Lng:\s*([\d.]+)').firstMatch(location);
      if (matches != null && matches.groupCount == 2) {
        return LatLng(
          double.parse(matches.group(1)!),
          double.parse(matches.group(2)!),
        );
      }
    } catch (e) {
      print('خطأ في تحويل الموقع: $e');
    }
    return const LatLng(0.0, 0.0);
  }
}
