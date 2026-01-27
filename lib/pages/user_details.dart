// // import 'package:flutter/material.dart';
// // import 'package:mobile_application/services/authenticated_photo.dart';
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
// //   int _selectedIndex = 1; // Profile tab is selected by default

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
// //         print('📷 [UserDetailsPage] Profile photo: ${_userDetails?['photoUrl'] ?? 'No photo'}');
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

// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
    
// //     // Handle navigation based on selected index
// //     switch (index) {
// //       case 0:
// //         // Home - Placeholder for future implementation
// //         print('🏠 [UserDetailsPage] Home button tapped - Not yet implemented');
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Home page - Coming soon!'),
// //             duration: Duration(seconds: 1),
// //           ),
// //         );
// //         break;
// //       case 1:
// //         // Profile - Already on this page
// //         print('👤 [UserDetailsPage] Profile button tapped');
// //         break;
// //       // Add more cases here when you add more navigation items
// //     }
// //   }

// //   Widget _buildProfileContent() {
// //     if (_isLoading) {
// //       return const Center(child: CircularProgressIndicator());
// //     }
    
// //     if (_error != null) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
// //             const SizedBox(height: 16),
// //             Text(_error!, textAlign: TextAlign.center),
// //             const SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: _fetchUserDetails,
// //               child: const Text('Retry'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
    
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16.0),
// //       child: Column(
// //         children: [
// //           Card(
// //             elevation: 4,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(24.0),
// //               child: Column(
// //                 children: [
// //                   // Profile Photo with smart loading
// //                   AuthenticatedProfilePhoto(
// //                     photoUrl: _userDetails?['employee']?['photoUrl'],
// //                     baseUrl: widget.baseUrl,
// //                     userName: _userDetails?['name'] ?? 'User',
// //                     radius: 50,
// //                     token: widget.token,
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     _userDetails?['name'] ?? 'N/A',
// //                     style: const TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     _userDetails?['email'] ?? 'N/A',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       color: Colors.grey.shade600,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           InfoCard(
// //             title: 'Personal Information',
// //             items: {
// //               'User ID': '${_userDetails?['id'] ?? 'N/A'}',
// //               'Email': _userDetails?['email'] ?? 'N/A',
// //               'Name': _userDetails?['name'] ?? 'N/A',
// //             },
// //           ),
// //           const SizedBox(height: 16),
// //           if (_userDetails?['employee'] != null) ...[
// //             InfoCard(
// //               title: 'Employee Information',
// //               items: {
// //                 'Employee ID': _userDetails!['employee']['employeeId'] ?? 'N/A',
// //                 'First Name': _userDetails!['employee']['firstName'] ?? 'N/A',
// //                 'Last Name': _userDetails!['employee']['lastName'] ?? 'N/A',
// //                 'Middle Name': _userDetails!['employee']['middleName'] ?? 'N/A',
// //                 'Suffix': (_userDetails!['employee']['suffix']?.isNotEmpty ?? false)
// //                     ? _userDetails!['employee']['suffix']
// //                     : 'N/A',
// //               },
// //             ),
// //           ],
// //           // Add extra padding at the bottom to prevent content from being hidden by the bottom nav bar
// //           const SizedBox(height: 80),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         title: const Text('User Profile'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: _logout,
// //             tooltip: 'Logout',
// //           ),
// //         ],
// //       ),
// //       body: _buildProfileContent(),
// //       bottomNavigationBar: BottomNavigationBar(
// //         items: const <BottomNavigationBarItem>[
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.home),
// //             label: 'Home',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.person),
// //             label: 'Profile',
// //           ),
// //           // Add more BottomNavigationBarItem here when you need more tabs
// //           // Example:
// //           // BottomNavigationBarItem(
// //           //   icon: Icon(Icons.settings),
// //           //   label: 'Settings',
// //           // ),
// //         ],
// //         currentIndex: _selectedIndex,
// //         selectedItemColor: Colors.green,
// //         onTap: _onItemTapped,
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:mobile_application/services/authenticated_photo.dart';
// import '../services/user_service.dart';
// import '../widgets/info_card.dart';
// import 'login_page.dart';

// class UserDetailsPageContent extends StatefulWidget {
//   final String token;
//   final String baseUrl;

//   const UserDetailsPageContent({
//     Key? key,
//     required this.token,
//     required this.baseUrl,
//   }) : super(key: key);

//   @override
//   State<UserDetailsPageContent> createState() => _UserDetailsPageContentState();
// }

// class _UserDetailsPageContentState extends State<UserDetailsPageContent> {
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
//                               AuthenticatedProfilePhoto(
//                                 photoUrl: _userDetails?['employee']?['photoUrl'],
//                                 baseUrl: widget.baseUrl,
//                                 userName: _userDetails?['name'] ?? 'User',
//                                 radius: 50,
//                                 token: widget.token,
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
//                             'Suffix': (_userDetails!['employee']['suffix']?.isNotEmpty ?? false)
//                                 ? _userDetails!['employee']['suffix']
//                                 : 'N/A',
//                           },
//                         ),
//                       ],
//                       // Add extra padding at the bottom to prevent content from being hidden by the bottom nav bar
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_application/services/authenticated_photo.dart';
import '../services/user_service.dart';
import '../widgets/info_card.dart';
import 'login_page.dart';

class UserDetailsPageContent extends StatefulWidget {
  final String token;
  final String baseUrl;

  const UserDetailsPageContent({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<UserDetailsPageContent> createState() => _UserDetailsPageContentState();
}

class _UserDetailsPageContentState extends State<UserDetailsPageContent> {
  final _userService = UserService();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('\n📄 [UserDetailsPage] Page initialized');
    print('🎫 [UserDetailsPage] Token: ${widget.token.substring(0, 20)}...');
    print('🌐 [UserDetailsPage] Base URL: ${widget.baseUrl}');
    _fetchUserDetails();
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
        print('✅ [UserDetailsPage] User profile loaded successfully');
        print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
        print('📷 [UserDetailsPage] Profile photo: ${_userDetails?['photoUrl'] ?? 'No photo'}');
      } else {
        _error = result['error'];
        print('❌ [UserDetailsPage] Error loading user profile: $_error');
      }
      _isLoading = false;
    });
    
    print('🏁 [UserDetailsPage] Fetch user profile completed\n');
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
        automaticallyImplyLeading: false,
        title: const Text('User Profile'),
        actions: [
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
              : SingleChildScrollView(
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
                              AuthenticatedProfilePhoto(
                                photoUrl: _userDetails?['employee']?['photoUrl'],
                                baseUrl: widget.baseUrl,
                                userName: _userDetails?['name'] ?? 'User',
                                radius: 50,
                                token: widget.token,
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
                      InfoCard(
                        title: 'Personal Information',
                        items: {
                          'User ID': '${_userDetails?['id'] ?? 'N/A'}',
                          'Email': _userDetails?['email'] ?? 'N/A',
                          'Name': _userDetails?['name'] ?? 'N/A',
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_userDetails?['employee'] != null) ...[
                        InfoCard(
                          title: 'Employee Information',
                          items: {
                            'Employee ID': _userDetails!['employee']['employeeId'] ?? 'N/A',
                            'First Name': _userDetails!['employee']['firstName'] ?? 'N/A',
                            'Last Name': _userDetails!['employee']['lastName'] ?? 'N/A',
                            'Middle Name': _userDetails!['employee']['middleName'] ?? 'N/A',
                            'Suffix': (_userDetails!['employee']['suffix']?.isNotEmpty ?? false)
                                ? _userDetails!['employee']['suffix']
                                : 'N/A',
                          },
                        ),
                      ],
                      // Add extra padding at the bottom to prevent content from being hidden by the bottom nav bar
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }
}