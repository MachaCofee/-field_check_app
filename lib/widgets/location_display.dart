import 'package:flutter/material.dart';

class LocationDisplay extends StatelessWidget {
  final bool isLoading;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? errorMessage;

  const LocationDisplay({
    super.key,
    required this.isLoading,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Mendapatkan lokasi...'),
            ],
          ),
          const SizedBox(height: 16),
          _skeletonRow('Latitude'),
          const SizedBox(height: 10),
          _skeletonRow('Longitude'),
          const SizedBox(height: 10),
          _skeletonRow('Accuracy'),
        ],
      );
    }

    if (errorMessage != null) {
      return Text(
        'Ralat: $errorMessage',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (latitude == null || longitude == null) {
      return Text(
        'Lokasi belum diperoleh',
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latitude: ${latitude!.toStringAsFixed(6)}'),
        Text('Longitude: ${longitude!.toStringAsFixed(6)}'),
        if (accuracy != null)
          Text('Ketepatan: ±${accuracy!.toStringAsFixed(1)} m'),
      ],
    );
  }

  // Skeleton bar for a field label while loading (matches wireframe)
  Widget _skeletonRow(String label) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}