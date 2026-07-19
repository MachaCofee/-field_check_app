import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}

class LocationService {
  static Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('GPS tidak aktif. Sila hidupkan lokasi.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Kebenaran lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Kebenaran lokasi ditolak selamanya. Aktifkan dalam Settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException {
      throw LocationException(
        'Gagal mendapatkan lokasi dalam masa yang ditetapkan. Sila cuba lagi di kawasan lapang.',
      );
    }
  }
}