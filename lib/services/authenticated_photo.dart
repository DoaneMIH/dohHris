import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_application/config/api_config.dart';
import '../services/token_manager.dart';

class AuthenticatedProfilePhoto extends StatefulWidget {
  final String? photoUrl;
  final String? baseUrl;
  final String userName;
  final double radius;
  final String? token;
  final String? employeeId; // Add employeeId for update endpoint
  final VoidCallback? onPhotoUpdated; // Callback after successful update

  const AuthenticatedProfilePhoto({
    Key? key,
    this.photoUrl,
    this.baseUrl,
    required this.userName,
    this.radius = 50,
    this.token,
    this.employeeId,
    this.onPhotoUpdated,
  }) : super(key: key);

  @override
  State<AuthenticatedProfilePhoto> createState() =>
      _AuthenticatedProfilePhotoState();
}

class _AuthenticatedProfilePhotoState extends State<AuthenticatedProfilePhoto> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasError = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.photoUrl != null &&
        widget.photoUrl!.isNotEmpty &&
        widget.photoUrl != 'N/A') {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Build full photo URL
      String fullPhotoUrl;
      if (widget.photoUrl!.startsWith('http')) {
        fullPhotoUrl = widget.photoUrl!;
      } else if (widget.photoUrl!.startsWith(ApiConfig.getEmployeePhoto)) {
        fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
      } else {
        fullPhotoUrl =
            '${widget.baseUrl ?? ''}${ApiConfig.getEmployeePhoto}${widget.photoUrl}';
      }

      print('📷 [AuthProfilePhoto] Loading image from: $fullPhotoUrl');

      // Get current token
      final token = TokenManager().token ?? widget.token;

      // Fetch image with authentication
      final response = await http.get(
        Uri.parse(fullPhotoUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📷 [AuthProfilePhoto] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
        print('✅ [AuthProfilePhoto] Image loaded successfully');
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        print(
          '❌ [AuthProfilePhoto] Failed to load image: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('❌ [AuthProfilePhoto] Error loading image: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Show option dialog for camera or gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading
      setState(() {
        _isLoading = true;
      });

      // Upload image
      await _uploadPhoto(image);
    } catch (e) {
      print('❌ [AuthProfilePhoto] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    }
  }

  Future<void> _uploadPhoto(XFile imageFile) async {
    try {
      if (widget.employeeId == null) {
        throw Exception('Employee ID is required to update photo');
      }

      final token = TokenManager().token ?? widget.token;
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final bytes = await imageFile.readAsBytes(); // Read image bytes
      final fileName = imageFile.name; // Get file name

      // UPDATED: Use the same endpoint pattern as employee details update
      final uri = Uri.parse(
        '${widget.baseUrl}${ApiConfig.updateEmployeePhotoEndpoint}${widget.employeeId}',
      );
      print('📷 [AuthProfilePhoto] Upload URI: $uri');

      // Create multipart request
      var request = http.MultipartRequest('PUT', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // UPDATED: Add the photo file with the field name 'photo'
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo', // This is the field name the backend expects
          bytes,
          filename: fileName,
        ),
      );

      print('📤 [AuthProfilePhoto] Uploading photo to: $uri');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        '📷 [AuthProfilePhoto] Upload response status: ${response.statusCode}',
      );
      print('📷 [AuthProfilePhoto] Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successfully uploaded
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Call callback if provided
        widget.onPhotoUpdated?.call();
      } else {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AuthProfilePhoto] Error uploading photo: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the first letter for fallback
    final firstLetter = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: _isLoading
              ? _buildLoadingAvatar()
              : (_hasError || _imageBytes == null)
              ? _buildLetterAvatar(firstLetter)
              : CircleAvatar(
                  radius: widget.radius,
                  backgroundColor: Colors.blue.shade100,
                  child: ClipOval(
                    child: Image.memory(
                      _imageBytes!,
                      width: widget.radius * 2,
                      height: widget.radius * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
        ),
        // Edit icon button
        if (widget.employeeId !=
            null) // Only show edit icon if employeeId is provided
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 0, 114, 4),
                  size: 19,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.blue.shade100,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildLetterAvatar(String letter) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.blue.shade100,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: widget.radius * 0.8,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
