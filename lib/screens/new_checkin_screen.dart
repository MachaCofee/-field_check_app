import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/checkin.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../widgets/location_display.dart';
import '../widgets/location_map_view.dart';

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  File? _photoFile;
  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String? _locationError;
  bool _isSaving = false;

  Future<void> _takePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Gambar'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Fail'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Check permission kamera secara eksplisit sebelum buka
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;

      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kebenaran kamera ditolak.')),
          );
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kebenaran kamera ditolak selamanya. Aktifkan dalam Settings.'),
          ),
        );
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final XFile? picked =
      await picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

      setState(() => _photoFile = savedImage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tak dapat mengakses gambar. Sila cuba lagi.')),
      );
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      final result = await LocationService.getCurrentLocation();
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _accuracy = result.accuracy;
      });
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photoFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sila ambil gambar dahulu.')));
      return;
    }
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sila dapatkan lokasi GPS dahulu.')));
      return;
    }

    setState(() => _isSaving = true);

    final checkIn = CheckIn(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      note: _noteController.text.trim(),
      photoPath: _photoFile!.path,
      latitude: _latitude!,
      longitude: _longitude!,
      accuracy: _accuracy!,
      createdAt: DateTime.now(),
    );

    await StorageService.addCheckIn(checkIn);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Check-In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a short note',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Note tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _photoFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_photoFile!, fit: BoxFit.cover),
                )
                    : Center(
                  child: Text('IMG / ✕', style: TextStyle(color: Colors.grey.shade500)),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _isFetchingLocation ? null : _getLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Get Location'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LocationDisplay(
                  isLoading: _isFetchingLocation,
                  latitude: _latitude,
                  longitude: _longitude,
                  accuracy: _accuracy,
                  errorMessage: _locationError,
                ),
              ),
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 12),
                LocationMapView(latitude: _latitude!, longitude: _longitude!),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}