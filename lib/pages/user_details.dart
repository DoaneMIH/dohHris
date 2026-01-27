
import 'package:flutter/material.dart';
import '../services/user_service.dart';
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
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  _userDetails?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                            'Suffix': _userDetails!['employee']['suffix'] ?? 'N/A',
                          },
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}