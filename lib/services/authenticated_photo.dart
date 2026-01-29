import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../services/token_manager.dart';

class AuthenticatedProfilePhoto extends StatefulWidget {
  final String? photoUrl;
  final String? baseUrl;
  final String userName;
  final double radius;
  final String? token;

  const AuthenticatedProfilePhoto({
    Key? key,
    this.photoUrl,
    this.baseUrl,
    required this.userName,
    this.radius = 50,
    this.token,
  }) : super(key: key);

  @override
  State<AuthenticatedProfilePhoto> createState() => _AuthenticatedProfilePhotoState();
}

class _AuthenticatedProfilePhotoState extends State<AuthenticatedProfilePhoto> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasError = false;

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
      } else if (widget.photoUrl!.startsWith('/employee/image/')) {
        fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
      } else {
        fullPhotoUrl = '${widget.baseUrl ?? ''}/employee/image/${widget.photoUrl}';
      }

      print('📷 [AuthProfilePhoto] Loading image from: $fullPhotoUrl');

      // Get current token
      final token = TokenManager().token ?? widget.token;

      // Fetch image with authentication
      final response = await http.get(
        Uri.parse(fullPhotoUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
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
        print('❌ [AuthProfilePhoto] Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('❌ [AuthProfilePhoto] Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the first letter for fallback
    final firstLetter = widget.userName.isNotEmpty 
        ? widget.userName[0].toUpperCase() 
        : 'U';

    if (_isLoading) {
      return _buildLoadingAvatar();
    }

    if (_hasError || _imageBytes == null) {
      return _buildLetterAvatar(firstLetter);
    }

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 236, 236, 236),
      ),
      child: CircleAvatar(
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

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:typed_data';
// import '../services/token_manager.dart';

// class AuthenticatedProfilePhoto extends StatefulWidget {
//   final String? photoUrl;
//   final String? baseUrl;
//   final String userName;
//   final double radius;
//   final String? token;

//   const AuthenticatedProfilePhoto({
//     Key? key,
//     this.photoUrl,
//     this.baseUrl,
//     required this.userName,
//     this.radius = 50,
//     this.token,
//   }) : super(key: key);

//   @override
//   State<AuthenticatedProfilePhoto> createState() => _AuthenticatedProfilePhotoState();
// }

// class _AuthenticatedProfilePhotoState extends State<AuthenticatedProfilePhoto> {
//   Uint8List? _imageBytes;
//   bool _isLoading = false;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.photoUrl != null && 
//         widget.photoUrl!.isNotEmpty && 
//         widget.photoUrl != 'N/A') {
//       _loadImage();
//     }
//   }

//   Future<void> _loadImage() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       // Build full photo URL
//       String fullPhotoUrl;
//       if (widget.photoUrl!.startsWith('http')) {
//         fullPhotoUrl = widget.photoUrl!;
//       } else if (widget.photoUrl!.startsWith('/employee/image/')) {
//         fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
//       } else {
//         fullPhotoUrl = '${widget.baseUrl ?? ''}/employee/image/${widget.photoUrl}';
//       }

//       print('📷 [AuthProfilePhoto] Loading image from: $fullPhotoUrl');

//       // Get current token
//       final token = TokenManager().token ?? widget.token;

//       // Fetch image with authentication
//       final response = await http.get(
//         Uri.parse(fullPhotoUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('📷 [AuthProfilePhoto] Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         setState(() {
//           _imageBytes = response.bodyBytes;
//           _isLoading = false;
//         });
//         print('✅ [AuthProfilePhoto] Image loaded successfully');
//       } else {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//         print('❌ [AuthProfilePhoto] Failed to load image: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//       print('❌ [AuthProfilePhoto] Error loading image: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the first letter for fallback
//     final firstLetter = widget.userName.isNotEmpty 
//         ? widget.userName[0].toUpperCase() 
//         : 'U';

//     if (_isLoading) {
//       return _buildLoadingAvatar();
//     }

//     if (_hasError || _imageBytes == null) {
//       return _buildLetterAvatar(firstLetter);
//     }

//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: Colors.blue.shade100,
//       ),
//       child: Image.memory(
//         _imageBytes!,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget _buildLoadingAvatar() {
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: Colors.blue.shade100,
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//     );
//   }

//   Widget _buildLetterAvatar(String letter) {
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: Colors.blue.shade100,
//       ),
//       child: Center(
//         child: Text(
//           letter,
//           style: TextStyle(
//             fontSize: 40,
//             color: Colors.blue.shade900,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }