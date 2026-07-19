import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMapView extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMapView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenMap(
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: AbsorbPointer(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.field_check_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _FullScreenMap({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.field_check_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 44),
                    ),
                  ],
                ),
              ],
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Double-tap untuk kecilkan',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}