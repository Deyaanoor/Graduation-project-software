import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FreeMapPickerPage extends StatefulWidget {
  final String? initialLocation;
  const FreeMapPickerPage({Key? key, this.initialLocation}) : super(key: key);

  @override
  _FreeMapPickerPageState createState() => _FreeMapPickerPageState();
}

class _FreeMapPickerPageState extends State<FreeMapPickerPage> {
  LatLng? selectedLocation; // بدون قيمة مبدئية
  bool isLoading = true;
  Map<String, dynamic>? locationMap;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      locationMap = jsonDecode(widget.initialLocation!);
      print("initialLocation : ${widget.initialLocation}");
      selectedLocation = LatLng(
        (locationMap!['latitude'] as num).toDouble(),
        (locationMap!['longitude'] as num).toDouble(),
      );
      print("selectedLocation = $selectedLocation");
      isLoading = false;
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Free Map Picker')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (selectedLocation == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Free Map Picker')),
        body: Center(child: Text('تعذر الحصول على الموقع.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // نرجع الموقع المحدد عند الضغط على علامة الصح
              Navigator.pop(context, selectedLocation);
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedLocation!,
          initialZoom: 15.0,
          onTap: widget.initialLocation == null
              ? (tapPosition, point) {
                  setState(() {
                    selectedLocation = point;
                  });
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: selectedLocation!,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
