import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final String? photoUrl;
  final String? baseUrl;
  final String userName;
  final double radius;

  const ProfilePhoto({
    Key? key,
    this.photoUrl,
    this.baseUrl,
    required this.userName,
    this.radius = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('📷 [ProfilePhoto] Building profile photo widget');
    print('📷 [ProfilePhoto] Photo URL: ${photoUrl ?? "No URL provided"}');
    print('📷 [ProfilePhoto] Base URL: ${baseUrl ?? "No base URL"}');
    
    // Get the first letter for fallback
    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    // If no photo URL, show letter avatar
    if (photoUrl == null || photoUrl!.isEmpty) {
      print('📷 [ProfilePhoto] No photo URL, showing letter avatar');
      return _buildLetterAvatar(firstLetter);
    }

    // Build full photo URL
    final fullPhotoUrl = photoUrl!.startsWith('http') 
        ? photoUrl! 
        : '${baseUrl ?? ''}$photoUrl';
    
    print('📷 [ProfilePhoto] Full photo URL: $fullPhotoUrl');

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade100,
      child: ClipOval(
        child: Image.network(
          fullPhotoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ [ProfilePhoto] Photo loaded successfully');
              return child;
            }
            print('⏳ [ProfilePhoto] Loading photo... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes ?? 0}');
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ [ProfilePhoto] Error loading photo: $error');
            return _buildLetterAvatar(firstLetter);
          },
        ),
      ),
    );
  }

  Widget _buildLetterAvatar(String letter) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade100,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: radius * 0.8,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}