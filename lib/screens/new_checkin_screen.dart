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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _takePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Explicitly check permission before opening camera or gallery
    final permission =
    source == ImageSource.camera ? Permission.camera : Permission.photos;

    final status = await permission.status;

    if (status.isDenied) {
      final result = await permission.request();
      if (result.isDenied) {
        _showErrorSnackBar(
          source == ImageSource.camera
              ? 'Camera permission denied.'
              : 'Gallery permission denied.',
        );
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      _showErrorSnackBar(
        source == ImageSource.camera
            ? 'Camera permission permanently denied. Please enable it in Settings.'
            : 'Gallery permission permanently denied. Please enable it in Settings.',
      );
      return;
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
      _showErrorSnackBar('Unable to access the photo. Please try again.');
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
      _showErrorSnackBar('Please take a photo first.');
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showErrorSnackBar('Please get the GPS location first.');
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

  Widget _buildChecklist() {
    final steps = [
      ('Note', _noteController.text.trim().isNotEmpty),
      ('Photo', _photoFile != null),
      ('Location', _latitude != null && _longitude != null),
      ('Save', _photoFile != null && _latitude != null && _longitude != null),
    ];

    const activeColor = Color(0xFF6B2737);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final (label, isDone) = steps[stepIndex];
            final isCurrent = !isDone &&
                (stepIndex == 0 || steps[stepIndex - 1].$2);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? activeColor : Colors.transparent,
                    border: Border.all(
                      color: isDone
                          ? activeColor
                          : (isCurrent ? activeColor : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent ? activeColor : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDone ? activeColor : Colors.grey.shade600,
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            );
          } else {
            final leftStepDone = steps[index ~/ 2].$2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: leftStepDone ? activeColor : Colors.grey.shade300,
              ),
            );
          }
        }),
      ),
    );
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
              _buildChecklist(),
              const Text('Note', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a short note',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Note cannot be empty'
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
                  border: Border.all(
                    color: _locationError != null ? Colors.red.shade400 : Colors.grey.shade400,
                  ),
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