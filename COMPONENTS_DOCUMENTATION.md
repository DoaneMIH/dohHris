# Components Documentation

## Overview

Complete documentation of all reusable components, widgets, and services in the HRIS Mobile Application.

---

## Services

### AuthService

**Location**: `lib/services/auth_service.dart`

**Purpose**: Handle user authentication and authorization

#### Methods

##### login(String email, String password)

```dart
/// Authenticates user with email and password
/// 
/// Parameters:
/// - email: User's email address
/// - password: User's password
/// 
/// Returns: Future map with success status and token
/// 
/// Example:
/// final result = await authService.login('user@example.com', 'password');
/// if (result['success']) {
///   final token = result['data']['token'];
/// }

Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    print('🚀 [AuthService] Starting login for $email');
    
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ [AuthService] Login successful');
      return {'success': true, 'data': data['data']};
    } else {
      print('❌ [AuthService] Login failed: ${response.statusCode}');
      return {'success': false, 'error': 'Invalid credentials'};
    }
  } catch (e) {
    print('💥 [AuthService] Exception: $e');
    return {'success': false, 'error': e.toString()};
  }
}
```

---

### TokenManager

**Location**: `lib/services/token_manager.dart`

**Purpose**: Manage JWT token lifecycle, refresh, and expiration

#### Properties

```dart
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  
  late String _token;
  late String _email;
  late String _password;
  late DateTime _expiryTime;
  late Timer _refreshTimer;
  late Function? _onTokenExpired;
}
```

#### Methods

##### initialize(String token, {required String email, required String password})

```dart
/// Initialize token manager with new token
void initialize(
  String token, {
  required String email,
  required String password,
  Function? onTokenExpired,
}) {
  _token = token;
  _email = email;
  _password = password;
  _onTokenExpired = onTokenExpired;
  
  // Start auto-refresh timer
  _startAutoRefresh();
}
```

##### getToken() → String

```dart
/// Get current valid token
/// Returns empty string if logged out
String getToken() => _token;
```

##### logout()

```dart
/// Clear token and credentials
void logout() {
  _token = '';
  _email = '';
  _password = '';
  _refreshTimer?.cancel();
  print('✅ [TokenManager] User logged out');
}
```

---

### UserService

**Location**: `lib/services/user_service.dart`

**Purpose**: Fetch and manage user data

#### Properties

```dart
class UserService {
  static final UserService _instance = UserService._internal();
  
  Map<String, dynamic>? _cachedUserData;
  DateTime? _cacheTime;
  static const Duration cacheValidity = Duration(hours: 1);
}
```

#### Methods

##### getUserProfile(String token) → Future<Map>

```dart
/// Fetch authenticated user's profile
/// 
/// Caches result for 1 hour
Future<Map<String, dynamic>> getUserProfile(String token) async {
  try {
    print('🚀 [UserService] Fetching user profile');
    
    // Check cache
    if (_cachedUserData != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < cacheValidity) {
      print('✅ [UserService] Returning cached data');
      return {'success': true, 'data': _cachedUserData};
    }
    
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfileEndpoint}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      _cachedUserData = json.decode(response.body)['data'];
      _cacheTime = DateTime.now();
      return {'success': true, 'data': _cachedUserData};
    }
    return {'success': false, 'error': 'Failed to fetch profile'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

##### updateUserProfile(String token, Map<String, dynamic> data)

```dart
/// Update user profile information
Future<Map<String, dynamic>> updateUserProfile(
  String token,
  Map<String, dynamic> data,
) async {
  try {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/${getUserId()}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
    
    if (response.statusCode == 200) {
      // Invalidate cache
      _cachedUserData = null;
      return {'success': true, 'data': json.decode(response.body)['data']};
    }
    return {'success': false, 'error': 'Update failed'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

##### clearCache()

```dart
/// Clear cached user data
void clearCache() {
  _cachedUserData = null;
  _cacheTime = null;
  print('🧹 [UserService] Cache cleared');
}
```

---

### AuthenticatedPhoto

**Location**: `lib/services/authenticated_photo.dart`

**Purpose**: Load profile photos with authentication headers

#### Usage

```dart
class AuthenticatedProfilePhoto extends StatefulWidget {
  final String photoUrl;
  final String token;
  final double size;
  
  const AuthenticatedProfilePhoto({
    Key? key,
    required this.photoUrl,
    required this.token,
    this.size = 100.0,
  }) : super(key: key);

  @override
  State<AuthenticatedProfilePhoto> createState() => 
    _AuthenticatedProfilePhotoState();
}

class _AuthenticatedProfilePhotoState extends State<AuthenticatedProfilePhoto> {
  late Future<Uint8List> _imageFuture;
  
  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage();
  }
  
  Future<Uint8List> _loadImage() async {
    try {
      final response = await http.get(
        Uri.parse(widget.photoUrl),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception('Failed to load image');
    } catch (e) {
      print('❌ [AuthPhoto] Error: $e');
      rethrow;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey[300],
            child: const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person),
          );
        }
        
        if (snapshot.hasData) {
          return CircleAvatar(
            radius: widget.size / 2,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        }
        
        return CircleAvatar(radius: widget.size / 2);
      },
    );
  }
}
```

---

## UI Widgets

### CustomTextForm

**Purpose**: Reusable text input field with validation

```dart
class CustomTextForm extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final Widget? prefix;
  final Widget? suffix;
  
  const CustomTextForm({
    Key? key,
    required this.label,
    this.validator,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  State<CustomTextForm> createState() => _CustomTextFormState();
}

class _CustomTextFormState extends State<CustomTextForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefix,
        suffixIcon: widget.suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
```

#### Usage

```dart
CustomTextForm(
  label: 'Email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Invalid email';
    }
    return null;
  },
  prefix: const Icon(Icons.email),
)
```

---

### LoadingDialog

**Purpose**: Show loading indicator in dialog

```dart
class LoadingDialog extends StatelessWidget {
  final String message;
  
  const LoadingDialog({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Usage

```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => const LoadingDialog(message: 'Logging in...'),
);

// Later: Close dialog
Navigator.pop(context);
```

---

### ErrorDialog

**Purpose**: Show error message to user

```dart
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Function()? onPressed;
  
  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: onPressed ?? () => Navigator.pop(context),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
```

#### Usage

```dart
showDialog(
  context: context,
  builder: (context) => ErrorDialog(
    title: 'Login Failed',
    message: 'Invalid email or password',
  ),
);
```

---

## Constants & Configuration

### ApiConfig

**Location**: `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Base URL
  static const String baseUrl = 'http://192.168.79.55:8082';
  
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  // User endpoints
  static const String userProfileEndpoint = '/users/profile';
  static const String userUpdateEndpoint = '/users/{id}';
  static const String userPhotoEndpoint = '/users/photo';
  
  // DTR endpoints
  static const String dtrRecordsEndpoint = '/dtr/records';
  static const String dtrCheckInEndpoint = '/dtr/checkin';
  static const String dtrCheckOutEndpoint = '/dtr/checkout';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
}
```

---

## Routes & Navigation

**Location**: `lib/widgets/routes.dart`

```dart
class MyRoutes {
  static const String splashPage = '/splash';
  static const String loginPage = '/login';
  static const String homePage = '/home';
  static const String dtrPage = '/dtr';
  static const String aboutPage = '/about';
  
  static Map<String, WidgetBuilder> routes = {
    splashPage: (context) => const Splash2(),
    loginPage: (context) => const LoginPage(),
    homePage: (context) => const HomePage(),
    dtrPage: (context) => const DtrPage(),
    aboutPage: (context) => const AboutPage(),
  };
}
```

---

## State Management Pattern

### Simple State Management Example

```dart
class DTRPage extends StatefulWidget {
  const DTRPage({Key? key}) : super(key: key);

  @override
  State<DTRPage> createState() => _DTRPageState();
}

class _DTRPageState extends State<DTRPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadDTRRecords();
  }
  
  Future<void> _loadDTRRecords() async {
    setState(() => _isLoading = true);
    
    try {
      final token = TokenManager().getToken();
      final result = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dtrRecordsEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (result.statusCode == 200) {
        setState(() {
          _records = List.from(json.decode(result.body)['data']);
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Failed to load records');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    
    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return ListTile(
          title: Text(record['date']),
          subtitle: Text('${record['check_in_time']} - ${record['check_out_time']}'),
        );
      },
    );
  }
}
```

---

## Color Palette

```dart
class AppColors {
  static const Color primary = Color(0xFF00674F);
  static const Color primaryLight = Color(0xFF4CA989);
  static const Color primaryDark = Color(0xFF004D36);
  
  static const Color secondary = Color(0xFF5B5B5B);
  static const Color accent = Color(0xFFFFA726);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
}
```

---

## Typography

```dart
class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
```

---

## Next Steps

- Review [CODE_STYLE_GUIDE.md](CODE_STYLE_GUIDE.md) for widget implementation
- Check [TESTING_DOCUMENTATION.md](TESTING_DOCUMENTATION.md) for component testing
- See [ARCHITECTURE.md](ARCHITECTURE.md) for design patterns

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Component Status**: Production Ready
