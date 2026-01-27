
// // import 'package:flutter/material.dart';
// // import '../services/user_service.dart';
// // import '../widgets/info_card.dart';
// // import 'login_page.dart';

// // class UserDetailsPage extends StatefulWidget {
// //   final String token;
// //   final String baseUrl;

// //   const UserDetailsPage({
// //     Key? key,
// //     required this.token,
// //     required this.baseUrl,
// //   }) : super(key: key);

// //   @override
// //   State<UserDetailsPage> createState() => _UserDetailsPageState();
// // }

// // class _UserDetailsPageState extends State<UserDetailsPage> {
// //   final _userService = UserService();
// //   Map<String, dynamic>? _userDetails;
// //   bool _isLoading = true;
// //   String? _error;

// //   @override
// //   void initState() {
// //     super.initState();
// //     print('\n📄 [UserDetailsPage] Page initialized');
// //     print('🎫 [UserDetailsPage] Token: ${widget.token.substring(0, 20)}...');
// //     print('🌐 [UserDetailsPage] Base URL: ${widget.baseUrl}');
// //     _fetchUserDetails();
// //   }

// //   Future<void> _fetchUserDetails() async {
// //     print('⏳ [UserDetailsPage] Fetching user profile with token...');
    
// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     final result = await _userService.getUserDetails(widget.token);

// //     print('📦 [UserDetailsPage] Result received from UserService');
// //     print('📦 [UserDetailsPage] Success: ${result['success']}');

// //     setState(() {
// //       if (result['success']) {
// //         _userDetails = result['data'];
// //         print('✅ [UserDetailsPage] User profile loaded successfully');
// //         print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
// //       } else {
// //         _error = result['error'];
// //         print('❌ [UserDetailsPage] Error loading user profile: $_error');
// //       }
// //       _isLoading = false;
// //     });
    
// //     print('🏁 [UserDetailsPage] Fetch user profile completed\n');
// //   }

// //   void _logout() {
// //     print('🚪 [UserDetailsPage] Logout button pressed');
// //     print('🔄 [UserDetailsPage] Navigating back to LoginPage...');
    
// //     Navigator.pushReplacement(
// //       context,
// //       MaterialPageRoute(builder: (context) => const LoginPage()),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('User Profile'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: _logout,
// //             tooltip: 'Logout',
// //           ),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _error != null
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
// //                       const SizedBox(height: 16),
// //                       Text(_error!, textAlign: TextAlign.center),
// //                       const SizedBox(height: 16),
// //                       ElevatedButton(
// //                         onPressed: _fetchUserDetails,
// //                         child: const Text('Retry'),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : SingleChildScrollView(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Column(
// //                     children: [
// //                       Card(
// //                         elevation: 4,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(16),
// //                         ),
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(24.0),
// //                           child: Column(
// //                             children: [
// //                               CircleAvatar(
// //                                 radius: 50,
// //                                 backgroundColor: Colors.blue.shade100,
// //                                 child: Text(
// //                                   _userDetails?['name']?.substring(0, 1).toUpperCase() ?? 'U',
// //                                   style: TextStyle(
// //                                     fontSize: 40,
// //                                     color: Colors.blue.shade900,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 16),
// //                               Text(
// //                                 _userDetails?['name'] ?? 'N/A',
// //                                 style: const TextStyle(
// //                                   fontSize: 24,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 8),
// //                               Text(
// //                                 _userDetails?['email'] ?? 'N/A',
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.grey.shade600,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                       InfoCard(
// //                         title: 'Personal Information',
// //                         items: {
// //                           'User ID': '${_userDetails?['id'] ?? 'N/A'}',
// //                           'Email': _userDetails?['email'] ?? 'N/A',
// //                           'Name': _userDetails?['name'] ?? 'N/A',
// //                         },
// //                       ),
// //                       const SizedBox(height: 16),
// //                       if (_userDetails?['employee'] != null) ...[
// //                         InfoCard(
// //                           title: 'Employee Information',
// //                           items: {
// //                             'Employee ID': _userDetails!['employee']['employeeId'] ?? 'N/A',
// //                             'First Name': _userDetails!['employee']['firstName'] ?? 'N/A',
// //                             'Last Name': _userDetails!['employee']['lastName'] ?? 'N/A',
// //                             'Middle Name': _userDetails!['employee']['middleName'] ?? 'N/A',
// //                             'Suffix': _userDetails!['employee']['suffix'] ?? 'N/A',
// //                           },
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:mobile_application/pages/profile_photo.dart';
// import '../services/user_service.dart';
// import '../widgets/info_card.dart';
// import 'login_page.dart';

// class UserDetailsPage extends StatefulWidget {
//   final String token;
//   final String baseUrl;

//   const UserDetailsPage({
//     Key? key,
//     required this.token,
//     required this.baseUrl,
//   }) : super(key: key);

//   @override
//   State<UserDetailsPage> createState() => _UserDetailsPageState();
// }

// class _UserDetailsPageState extends State<UserDetailsPage> {
//   final _userService = UserService();
//   Map<String, dynamic>? _userDetails;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     print('\n📄 [UserDetailsPage] Page initialized');
//     print('🎫 [UserDetailsPage] Token: ${widget.token.substring(0, 20)}...');
//     print('🌐 [UserDetailsPage] Base URL: ${widget.baseUrl}');
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     print('⏳ [UserDetailsPage] Fetching user profile with token...');
    
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     final result = await _userService.getUserDetails(widget.token);

//     print('📦 [UserDetailsPage] Result received from UserService');
//     print('📦 [UserDetailsPage] Success: ${result['success']}');

//     setState(() {
//       if (result['success']) {
//         _userDetails = result['data'];
//         print('✅ [UserDetailsPage] User profile loaded successfully');
//         print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
//         print('📷 [UserDetailsPage] Profile photo: ${_userDetails?['photoUrl'] ?? 'No photo'}');
//       } else {
//         _error = result['error'];
//         print('❌ [UserDetailsPage] Error loading user profile: $_error');
//       }
//       _isLoading = false;
//     });
    
//     print('🏁 [UserDetailsPage] Fetch user profile completed\n');
//   }

//   void _logout() {
//     print('🚪 [UserDetailsPage] Logout button pressed');
//     print('🔄 [UserDetailsPage] Navigating back to LoginPage...');
    
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('User Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
//                       const SizedBox(height: 16),
//                       Text(_error!, textAlign: TextAlign.center),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _fetchUserDetails,
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(24.0),
//                           child: Column(
//                             children: [
//                               // Profile Photo with smart loading
//                               ProfilePhoto(
//                                 photoUrl: _userDetails!['employee']['photoUrl'] ?? 'N/A',
//                                 baseUrl: widget.baseUrl,
//                                 userName: _userDetails?['name'] ?? 'User',
//                                 radius: 50,
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 _userDetails?['name'] ?? 'N/A',
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 _userDetails?['email'] ?? 'N/A',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       InfoCard(
//                         title: 'Personal Information',
//                         items: {
//                           'User ID': '${_userDetails?['id'] ?? 'N/A'}',
//                           'Email': _userDetails?['email'] ?? 'N/A',
//                           'Name': _userDetails?['name'] ?? 'N/A',
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       if (_userDetails?['employee'] != null) ...[
//                         InfoCard(
//                           title: 'Employee Information',
//                           items: {
//                             'Employee ID': _userDetails!['employee']['employeeId'] ?? 'N/A',
//                             'First Name': _userDetails!['employee']['firstName'] ?? 'N/A',
//                             'Last Name': _userDetails!['employee']['lastName'] ?? 'N/A',
//                             'Middle Name': _userDetails!['employee']['middleName'] ?? 'N/A',
//                             'Suffix': _userDetails!['employee']['suffix'] ?? 'N/A',
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_application/pages/profile_photo.dart';
import '../services/user_service.dart';
import '../services/token_manager.dart';
import '../widgets/info_card.dart';
import 'login_page.dart';

class UserDetailsPage extends StatefulWidget {
  final String token;
  final String baseUrl;

  const UserDetailsPage({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _suffixController;
  
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _suffixController = TextEditingController();
    
    print('\n📄 [UserDetailsPage] Page initialized');
    print('🎫 [UserDetailsPage] Token: ${widget.token.substring(0, 20)}...');
    print('🌐 [UserDetailsPage] Base URL: ${widget.baseUrl}');
    
    // Initialize token manager with auto-refresh
    TokenManager().initialize(
      widget.token,
      onTokenExpired: _handleTokenExpired,
    );
    
    _fetchUserDetails();
  }
  
  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _suffixController.dispose();
    
    // Stop token refresh when leaving page
    TokenManager().dispose();
    
    super.dispose();
  }
  
  /// Handle token expiration - logout user
  void _handleTokenExpired() {
    print('⚠️ [UserDetailsPage] Token expired - logging out');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchUserDetails() async {
    print('⏳ [UserDetailsPage] Fetching user profile with token...');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _userService.getUserDetails(widget.token);

    print('📦 [UserDetailsPage] Result received from UserService');
    print('📦 [UserDetailsPage] Success: ${result['success']}');

    setState(() {
      if (result['success']) {
        _userDetails = result['data'];
        
        // Populate controllers with user data
        _nameController.text = _userDetails?['name'] ?? '';
        _emailController.text = _userDetails?['email'] ?? '';
        
        if (_userDetails?['employee'] != null) {
          _firstNameController.text = _userDetails!['employee']['firstName'] ?? '';
          _lastNameController.text = _userDetails!['employee']['lastName'] ?? '';
          _middleNameController.text = _userDetails!['employee']['middleName'] ?? '';
          _suffixController.text = _userDetails!['employee']['suffix'] ?? '';
        }
        
        print('✅ [UserDetailsPage] User profile loaded successfully');
        print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
        print('📷 [UserDetailsPage] Profile photo: ${_userDetails?['profilePhoto'] ?? 'No photo'}');
      } else {
        _error = result['error'];
        print('❌ [UserDetailsPage] Error loading user profile: $_error');
      }
      _isLoading = false;
    });
    
    print('🏁 [UserDetailsPage] Fetch user profile completed\n');
  }

  void _toggleEditMode() {
    print('✏️ [UserDetailsPage] ${_isEditMode ? 'Canceling' : 'Entering'} edit mode');
    
    setState(() {
      if (_isEditMode) {
        // Cancel edit - restore original values
        _nameController.text = _userDetails?['name'] ?? '';
        _emailController.text = _userDetails?['email'] ?? '';
        
        if (_userDetails?['employee'] != null) {
          _firstNameController.text = _userDetails!['employee']['firstName'] ?? '';
          _lastNameController.text = _userDetails!['employee']['lastName'] ?? '';
          _middleNameController.text = _userDetails!['employee']['middleName'] ?? '';
          _suffixController.text = _userDetails!['employee']['suffix'] ?? '';
        }
      }
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ [UserDetailsPage] Form validation failed');
      return;
    }

    print('💾 [UserDetailsPage] Saving changes...');
    
    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare updated data
      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'employee': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'suffix': _suffixController.text.trim(),
        }
      };

      print('📤 [UserDetailsPage] Updated data: $updatedData');

      // Call update API endpoint
      final result = await _userService.updateUserDetails(widget.token, updatedData);
      
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          setState(() {
            _isEditMode = false;
            _isSaving = false;
          });
          
          // Refresh data
          _fetchUserDetails();
          
          print('✅ [UserDetailsPage] Changes saved successfully');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
          
          setState(() {
            _isSaving = false;
          });
          
          print('❌ [UserDetailsPage] Failed to save: ${result['error']}');
        }
      }
    } catch (e) {
      print('❌ [UserDetailsPage] Error saving changes: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _logout() {
    print('🚪 [UserDetailsPage] Logout button pressed');
    print('🔄 [UserDetailsPage] Navigating back to LoginPage...');
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                // Profile Photo with smart loading
                                ProfilePhoto(
                                  photoUrl: _userDetails!['employee']['photoUrl'] ?? 'N/A',
                                  baseUrl: widget.baseUrl,
                                  userName: _userDetails?['name'] ?? 'User',
                                  radius: 50,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userDetails?['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _userDetails?['email'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Editable Personal Information
                        EditableInfoCard(
                          title: 'Personal Information',
                          controllers: {
                            'Name': _nameController,
                            'Email': _emailController,
                          },
                          isEditMode: _isEditMode,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Editable Employee Information
                        if (_userDetails?['employee'] != null) ...[
                          EditableInfoCard(
                            title: 'Employee Information',
                            controllers: {
                              'Employee ID': TextEditingController(
                                text: _userDetails!['employee']['employeeId'] ?? 'N/A',
                              )..addListener(() {}), // Read-only
                              'First Name': _firstNameController,
                              'Last Name': _lastNameController,
                              'Middle Name': _middleNameController,
                              'Suffix': _suffixController,
                            },
                            isEditMode: _isEditMode,
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Save/Cancel buttons when in edit mode
                        if (_isEditMode)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _toggleEditMode,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}