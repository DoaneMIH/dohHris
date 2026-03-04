# Code Style Guide

## Overview

This document defines coding standards and best practices for the HRIS Mobile Application. All code must follow these guidelines for consistency and maintainability.

---

## Dart & Flutter Style Guide

### 1. Naming Conventions

#### Classes and Types
```dart
// ✅ DO: PascalCase for classes
class LoginPage extends StatefulWidget {}
class AuthService {}
class TokenManager {}

// ❌ DON'T
class loginPage extends StatefulWidget {}
class auth_service {}
```

#### Variables and Functions
```dart
// ✅ DO: camelCase for variables and functions
String userName = "John";
int userAge = 30;
void authenticateUser() {}
Future<Map<String, dynamic>> fetchUserData() {}

// ❌ DON'T
String user_name = "John";
String UserName = "John";
void AuthenticateUser() {}
```

#### Constants
```dart
// ✅ DO: camelCase for constants
const Duration refreshInterval = Duration(minutes: 4);
const String appName = 'HRIS Mobile';
const int maxRetries = 3;

// ❌ DON'T
const Duration REFRESH_INTERVAL = Duration(minutes: 4);
const String APP_NAME = 'HRIS Mobile';
```

#### Private Members
```dart
// ✅ DO: prefix with underscore
class AuthService {
  String _token = '';
  late http.Client _httpClient;
  
  void _handleError(Exception e) {}
}

// ❌ DON'T
class AuthService {
  String token = '';
  void handleError(Exception e) {}
}
```

---

### 2. File Structure

#### File Organization
```dart
// ✅ DO: Organize in this order
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/token_manager.dart';

// Code goes here
```

#### Class Structure
```dart
class MyService {
  // 1. Static variables
  static final MyService _instance = MyService._internal();
  
  // 2. Instance variables
  late String _token;
  final List<String> _data = [];
  
  // 3. Constructor
  factory MyService() => _instance;
  MyService._internal();
  
  // 4. Public methods
  Future<bool> authenticate(String email, String password) async {
    // Implementation
  }
  
  // 5. Private methods
  Future<void> _refreshToken() async {
    // Implementation
  }
}
```

---

### 3. Formatting & Indentation

#### Indentation
```dart
// ✅ DO: Use 2 spaces (Flutter standard)
if (isLoggedIn) {
  print('User is logged in');
  fetchUserData();
}

// ❌ DON'T: Use 4 spaces or tabs
if (isLoggedIn) {
    print('User is logged in');
    fetchUserData();
}
```

#### Line Length
```dart
// ✅ DO: Keep lines under 80 characters
final String userData = fetchUserDataFromServer(
  userId: user.id,
  includeProfile: true,
);

// ❌ DON'T: Lines over 100 characters
final String userData = fetchUserDataFromServer(userId: user.id, includeProfile: true);
```

#### Spacing
```dart
// ✅ DO: Space around operators
if (value > 10 && name != null) {
  result = value * 2 + 5;
}

// ❌ DON'T
if(value>10&&name!=null){
  result=value*2+5;
}
```

---

### 4. Comments

#### Documentation Comments
```dart
// ✅ DO: Use /// for public APIs
/// Authenticates user with email and password
/// 
/// Returns a [Future] that resolves to [bool]
/// - true if authentication successful
/// - false if authentication failed
/// 
/// Throws [Exception] if network error occurs
Future<bool> authenticate(String email, String password) async {
  // Implementation
}

// ❌ DON'T: Use // for documentation
// This method authenticates the user
Future<bool> authenticate(String email, String password) async {
  // Implementation
}
```

#### Inline Comments
```dart
// ✅ DO: Explain WHY, not WHAT
void processUserData(Map<String, dynamic> data) {
  // Filter inactive users to improve performance
  final activeUsers = data.entries
    .where((entry) => entry.value['is_active'])
    .toList();
}

// ❌ DON'T
void processUserData(Map<String, dynamic> data) {
  // Loop through data and filter
  final activeUsers = data.entries
    .where((entry) => entry.value['is_active'])
    .toList();
}
```

#### Section Comments
```dart
class UserService {
  // ============ PUBLIC METHODS ============
  
  Future<User> getUser(String id) async {
    // Implementation
  }
  
  // ============ PRIVATE METHODS ============
  
  Future<void> _cacheUserData(User user) async {
    // Implementation
  }
}
```

---

### 5. Null Safety

#### Null Checks
```dart
// ✅ DO: Use ?? operator for defaults
String displayName = user.name ?? 'Anonymous';

// ✅ DO: Use ?. for optional access
String? address = user?.profile?.address;

// ✅ DO: Use late keyword for late initialization
late final String token;

// ❌ DON'T: Avoid ! unless absolutely sure
String displayName = user.name!; // Risky!
```

#### Type Annotations
```dart
// ✅ DO: Always specify types
Future<Map<String, dynamic>> fetchData() {
  // Implementation
}

// ✅ DO: Use final for immutable variables
final String userName = 'John';
final int age = 30;

// ❌ DON'T: Avoid var unless type is obvious
var userName = 'John'; // OK
var complexObject = buildComplexObject(); // Avoid
```

---

### 6. Error Handling

#### Try-Catch Pattern
```dart
// ✅ DO: Handle specific exceptions
try {
  final response = await http.get(uri);
  return json.decode(response.body);
} on SocketException catch (e) {
  print('❌ [Service] Network error: $e');
  return {'success': false, 'error': 'Network error'};
} on FormatException catch (e) {
  print('❌ [Service] Invalid response: $e');
  return {'success': false, 'error': 'Invalid response'};
} catch (e) {
  print('💥 [Service] Unexpected error: $e');
  return {'success': false, 'error': 'Unknown error'};
}

// ❌ DON'T: Catch all exceptions
try {
  // Code
} catch (e) {
  print('Error: $e');
}
```

#### Result Objects
```dart
// ✅ DO: Return consistent result format
Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    // Implementation
    return {
      'success': true,
      'data': userData,
      'error': null,
    };
  } catch (e) {
    return {
      'success': false,
      'data': null,
      'error': 'Login failed',
    };
  }
}
```

---

### 7. Logging

#### Logging Format
```dart
// ✅ DO: Use consistent emoji-prefixed logging
print('🚀 [ServiceName] Starting operation');
print('📧 [ServiceName] Received data: $data');
print('📤 [ServiceName] Sending request to $endpoint');
print('📥 [ServiceName] Response: ${response.statusCode}');
print('✅ [ServiceName] Operation completed');
print('⚠️  [ServiceName] Warning: $message');
print('❌ [ServiceName] Error: $error');
print('💥 [ServiceName] Exception: $exception');

// ❌ DON'T: Inconsistent logging
print('Starting...');
print('Done');
print('Error occurred');
```

---

### 8. Flutter Widgets

#### StatefulWidget Structure
```dart
// ✅ DO: Use proper StatefulWidget structure
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Implementation
  }
}

// ❌ DON'T
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // No proper initialization/disposal
  @override
  Widget build(BuildContext context) {
    return Scaffold(); // Complex UI here
  }
}
```

#### Const Constructors
```dart
// ✅ DO: Use const for immutable widgets
class UserCard extends StatelessWidget {
  final String name;
  final String email;

  const UserCard({
    Key? key,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(child: Text(name));
  }
}

// ❌ DON'T: Mutable widgets as const
class MutableWidget extends StatelessWidget {
  MutableWidget({Key? key}) : super(key: key); // Not const
  
  @override
  Widget build(BuildContext context) => Container();
}
```

---

### 9. Async & Futures

#### Async Pattern
```dart
// ✅ DO: Use async/await over .then()
Future<User> fetchUser(String id) async {
  try {
    final response = await http.get(Uri.parse('/users/$id'));
    return User.fromJson(json.decode(response.body));
  } catch (e) {
    throw Exception('Failed to load user');
  }
}

// ❌ DON'T: Chain .then() calls
Future<User> fetchUser(String id) {
  return http.get(Uri.parse('/users/$id'))
    .then((response) => User.fromJson(json.decode(response.body)))
    .catchError((e) => throw Exception('Failed'));
}
```

#### Parallel Operations
```dart
// ✅ DO: Use Future.wait for parallel operations
Future<List<dynamic>> loadData() async {
  final results = await Future.wait([
    fetchUsers(),
    fetchDTRRecords(),
    fetchProfilePhoto(),
  ]);
  return results;
}

// ❌ DON'T: Sequential operations when parallel is possible
Future<List<dynamic>> loadData() async {
  final users = await fetchUsers();
  final dtr = await fetchDTRRecords();
  final photo = await fetchProfilePhoto();
  return [users, dtr, photo];
}
```

---

### 10. Testing

#### Test File Structure
```dart
// filename: auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/services/auth_service.dart';

void main() {
  group('AuthService', () {
    group('login', () {
      test('returns success on valid credentials', () async {
        final authService = AuthService();
        final result = await authService.login(
          'test@example.com',
          'password',
        );
        expect(result['success'], true);
      });

      test('returns error on invalid credentials', () async {
        final authService = AuthService();
        final result = await authService.login(
          'test@example.com',
          'wrongpassword',
        );
        expect(result['success'], false);
      });
    });
  });
}
```

---

## Project-Specific Standards

### API Configuration
```dart
// ✅ DO: Define all endpoints as constants
class ApiConfig {
  static const String baseUrl = 'http://192.168.79.55:8082';
  static const String loginEndpoint = '/auth/login';
  static const String userProfileEndpoint = '/users/profile';
}

// Usage
final url = '${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}';
```

### Service Pattern
```dart
// ✅ DO: Follow service pattern
class UserService {
  static final UserService _instance = UserService._internal();
  
  factory UserService() => _instance;
  UserService._internal();
  
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      // Implementation
      return {'success': true, 'data': userData};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
```

---

## Code Review Checklist

Before submitting code for review:

- [ ] Follows naming conventions
- [ ] Proper indentation (2 spaces)
- [ ] All functions documented
- [ ] Error handling implemented
- [ ] No console.log/print in production code
- [ ] No hardcoded values
- [ ] Tests written
- [ ] No TODO comments without context
- [ ] Code formatted with `dart format`
- [ ] No unused imports or variables

---

## Automated Formatting

```bash
# Format all Dart files
dart format lib/

# Analyze code
dart analyze

# Run linter
flutter analyze

# Fix common issues
flutter fix --apply
```

---

## Next Steps

- Review [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for environment setup
- Check [COMPONENTS_DOCUMENTATION.md](COMPONENTS_DOCUMENTATION.md) for component examples
- See [TESTING_DOCUMENTATION.md](TESTING_DOCUMENTATION.md) for testing standards

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Standard**: Dart Style Guide + Flutter Best Practices
