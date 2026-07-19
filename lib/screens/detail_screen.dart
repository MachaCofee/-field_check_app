import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/checkin.dart';
import '../widgets/location_map_view.dart';

class DetailScreen extends StatelessWidget {
  final CheckIn checkIn;
  const DetailScreen({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 240,
              child: File(checkIn.photoPath).existsSync()
                  ? Image.file(File(checkIn.photoPath), fit: BoxFit.cover)
                  : Container(
                color: Colors.grey.shade300,
                child: const Center(child: Text('IMG / ✕')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOTE',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(checkIn.note, style: const TextStyle(fontSize: 16)),
                  const Divider(height: 32),
                  _row('Latitude', checkIn.latitude.toStringAsFixed(6)),
                  _row('Longitude', checkIn.longitude.toStringAsFixed(6)),
                  _row('Accuracy', '${checkIn.accuracy.toStringAsFixed(1)} m'),
                  _row('Created At',
                      DateFormat('dd MMM yyyy, HH:mm').format(checkIn.createdAt)),
                  const Divider(height: 32),
                  Text('LOCATION',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LocationMapView(
                    latitude: checkIn.latitude,
                    longitude: checkIn.longitude,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}