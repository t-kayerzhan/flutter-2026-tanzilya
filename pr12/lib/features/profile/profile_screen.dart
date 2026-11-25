import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  File? _photo;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = await _prefs.getString('avatarPath');

    if (!mounted || path == null) return;

    final file = File(path);

    if (await file.exists()) {
      if (!mounted) return;
      setState(() => _photo = file);
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _savePhoto(XFile picked) async {
    final directory = await getApplicationDocumentsDirectory();

    final saved = File('${directory.path}/avatar.jpg');

    await saved.writeAsBytes(await picked.readAsBytes(), flush: true);

    await _prefs.setString('avatarPath', saved.path);

    if (!mounted) return;

    setState(() => _photo = saved);

    _message('Profile photo saved');
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );

      // The user can cancel the picker.
      if (picked == null) return;

      if (!mounted) return;

      await _savePhoto(picked);
    } catch (e) {
      _message('Could not select photo: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_busy) return;

    // Ask only when the user taps Take photo.
    final status = await Permission.camera.request();

    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
        await _pickImage(ImageSource.camera);
        break;

      case PermissionStatus.denied:
        _message(
          'Camera permission denied. '
          'You can try again.',
        );
        break;

      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
        break;

      case PermissionStatus.restricted:
        _message('Camera access is restricted on this device.');
        break;

      case PermissionStatus.limited:
        _message('Camera access is limited.');
        break;

      case PermissionStatus.provisional:
        _message('Camera permission is provisional.');
        break;
    }
  }

  Future<void> _showSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Camera permission needed'),
          content: const Text(
            'Camera access was permanently denied. '
            'Open app settings to allow the camera.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final opened = await openAppSettings();

                if (!opened) {
                  _message('Could not open settings');
                }
              },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 65,
                backgroundImage: _photo == null ? null : FileImage(_photo!),
                child: _photo == null
                    ? const Text('P', style: TextStyle(fontSize: 48))
                    : null,
              ),
              const SizedBox(height: 24),
              const Text('Profile photo', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take photo'),
              ),
              if (_busy) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
