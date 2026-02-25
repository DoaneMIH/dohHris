# HRIS Mobile Application - Quick Start Guide

## 5-Minute Setup

### 1. Prerequisites
```bash
# Verify Flutter/Dart installed
flutter --version  # Should be 3.10.7+
dart --version     # Should be 3.10.7+
```

### 2. Clone & Setup
```bash
# Clone repository
git clone <REPO_URL>
cd mobile_application

# Get dependencies
flutter pub get

# Check setup
flutter doctor
```

### 3. Configure Backend URL
Edit `lib/config/api_config.dart`:
```dart
// Change this line to your backend URL
static const String baseUrl = 'http://192.168.79.55:8082';
```

### 4. Run App
```bash
# List available devices
flutter devices

# Run on emulator/device
flutter run

# Or for specific device
flutter run -d <device_id>
```

---

## Project Structure Overview

```
lib/
├── main.dart              # App entry point
├── config/
│   └── api_config.dart   # API configuration
├── services/             # Business logic
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── token_manager.dart
│   └── authenticated_photo.dart
├── pages/                # Full screens
│   ├── login_page.dart
│   ├── homepage.dart
│   ├── dtr_page.dart
│   ├── about.dart
│   ├── navigation.dart
│   └── UserCredentials/  # Profile detail pages
└── widgets/              # Reusable components
    ├── routes.dart
    └── splash.dart
```

---

## Core Features

### 1. Authentication
- Email/password login
- Automatic token refresh every 4 minutes
- Secure token storage

```dart
// Usage in login_page.dart
final authService = AuthService();
final result = await authService.login(email, password);
```

### 2. User Profile
- View personal information
- Update profile details
- Upload/change profile photo

```dart
// Usage
final userService = UserService();
final profile = await userService.getUserDetails(token);
```

### 3. Daily Time Records
- View time-in/time-out records
- Filter by month/year
- See attendance history

```dart
// In dtr_page.dart
// Automatically fetches from: /adminuser/api/v1/dtr/{userId}
```

### 4. Employee Background
- Add/edit/delete:
  - Family members
  - Education
  - Work experience
  - Voluntary work
  - Training & development
  - Civil service info
  - Personal references

---

## Common Tasks

### Adding a New Service Method

1. **Create method in service file** (e.g., `user_service.dart`):
```dart
Future<Map<String, dynamic>> myNewMethod(String token, String id) async {
  print('🚀 [UserService] Starting operation...');
  
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/endpoint/$id'),
      headers: {
        'Authorization': 'Bearer ${TokenManager().token ?? token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('✅ [UserService] Success');
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'error': 'Failed'};
  } catch (e) {
    print('❌ [UserService] Error: $e');
    return {'success': false, 'error': e.toString()};
  }
}
```

2. **Call from page/widget**:
```dart
final service = UserService();
final result = await service.myNewMethod(token, id);
if (result['success']) {
  // Handle success
} else {
  // Handle error
}
```

### Adding a New Page

1. **Create page file** (e.g., `lib/pages/new_page.dart`):
```dart
import 'package:flutter/material.dart';

class NewPage extends StatefulWidget {
  final String token;
  final String baseUrl;

  const NewPage({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Page')),
      body: const Center(child: Text('Page Content')),
    );
  }
}
```

2. **Add to routes** (if needed) in `lib/widgets/routes.dart`:
```dart
static const String newPage = "/new_page";

static final routes = <String, WidgetBuilder>{
  // ... existing routes
  newPage: (context) => const NewPage(token: '', baseUrl: ''),
};
```

---

## API Endpoints Quick Reference

### Authentication
```
POST /auth/login
```

### User Profile
```
GET  /adminuser/get-profile
POST /adminuser/update-employee/{employeeId}
```

### Family
```
GET    /adminuser/family/get-all-family/{employeeId}
POST   /adminuser/family/add-family/{employeeId}
POST   /adminuser/family/update-family/{familyId}
DELETE /adminuser/family/delete-family/{familyId}
```

### Education
```
GET    /adminuser/education/get-all-education/{employeeId}
POST   /adminuser/education/add-education/{employeeId}
POST   /adminuser/education/update-education/{educationId}
DELETE /adminuser/education/delete-education/{educationId}
```

### Work Experience
```
GET    /adminuser/work-experience/get-all-work-experience/{employeeId}
POST   /adminuser/work-experience/add-work-experience/{employeeId}
POST   /adminuser/work-experience/update-work-experience/{experienceId}
DELETE /adminuser/work-experience/delete-work-experience/{experienceId}
```

### DTR (Daily Time Record)
```
GET /adminuser/api/v1/dtr/{userId}
```

### Photos
```
GET  /employee/image/{photoId}
POST /adminuser/update-employee-photo/{employeeId}
```

*See [API_REFERENCE.md](API_REFERENCE.md) for complete details*

---

## Debugging Tips

### Enable Verbose Logging
```bash
flutter run -v
```

### Check for Errors
- Look for print statements with emoji prefixes
- 🚀 = Action starting
- ❌ = Error
- ✅ = Success
- 💥 = Exception

### Common Issues

#### "Network error"
```dart
// Check API base URL in api_config.dart
// Verify backend server is running
// Check network connectivity
```

#### "Token expired"
```dart
// TokenManager automatically refreshes every 4 minutes
// If issue persists, clear TokenManager and re-login
TokenManager()._token = null;
```

#### "Image won't upload"
```dart
// Check image size (< 5MB recommended)
// Verify employee ID is correct
// Check API endpoint is correct
```

#### "Build fails"
```bash
flutter clean
flutter pub get
flutter run
```

---

## Key Classes & Methods

### AuthService
```dart
Future<Map<String, dynamic>> login(String email, String password)
```

### TokenManager
```dart
TokenManager() // Singleton
void initialize(String token, {required String email, required String password})
Future<bool> refreshToken()
String? get token
```

### UserService
```dart
Future<Map<String, dynamic>> getUserDetails(String token)
Future<Map<String, dynamic>> updatePersonalInformation(String token, String employeeId, Map data)
Future<Map<String, dynamic>> getAllFamily(String token, String employeeId)
Future<Map<String, dynamic>> addFamily(String token, String employeeId, Map data)
// Similar methods for education, work experience, etc.
```

### AuthenticatedProfilePhoto
```dart
// Widget for displaying/uploading profile photos
AuthenticatedProfilePhoto(
  photoUrl: url,
  baseUrl: baseUrl,
  userName: name,
  token: token,
  employeeId: empId,
  onPhotoUpdated: callback,
)
```

---

## Environment Variables & Configuration

### API Configuration (lib/config/api_config.dart)
```dart
// Update to your backend URL
static const String baseUrl = 'http://192.168.79.55:8082';

// All endpoints defined as constants
static const String loginEndpoint = '/auth/login';
static const String getUserEndpoint = '/adminuser/get-profile';
// ... more endpoints
```

### No environment variables currently used
Consider adding for production:
```dart
// Future enhancement
const bool isProduction = bool.fromEnvironment('PROD');
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.79.55:8082',
);
```

---

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/widget_test.dart
```

### Manual Testing Checklist
- [ ] Login with valid credentials
- [ ] Try login with invalid credentials
- [ ] Check profile loads
- [ ] Check DTR displays
- [ ] Try updating profile
- [ ] Try uploading photo
- [ ] Test navigation
- [ ] Check app works on different screen sizes

---

## Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA
```bash
flutter build ipa --release
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

---

## Important Notes

### Token Refresh
- Automatic: Every 4 minutes
- Uses stored credentials for silent re-login
- Handles failures gracefully

### Debugging Production Issues
```bash
# Get app logs from device
adb logcat | grep flutter

# iOS logs
# Use Xcode Console
```

### Performance Tips
1. Cache user data in UserService
2. Minimize API calls
3. Lazy load images
4. Use pagination for large lists

---

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev
- **Material 3**: https://m3.material.io/
- **HTTP Package**: https://pub.dev/packages/http
- **SharedPreferences**: https://pub.dev/packages/shared_preferences

---

## Getting Help

1. **Check existing logs**: Look for print statements in console
2. **Review DOCUMENTATION.md**: Comprehensive guide
3. **Check API_REFERENCE.md**: API endpoint details
4. **Run flutter doctor**: Check environment issues
5. **Contact team**: Reach out to development team

---

## Next Steps

- [ ] Run the app locally
- [ ] Test login functionality
- [ ] Explore the codebase
- [ ] Read [DOCUMENTATION.md](DOCUMENTATION.md) for details
- [ ] Review [API_REFERENCE.md](API_REFERENCE.md) for endpoints
- [ ] Check [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for deployment

---

**Version**: 1.0  
**Last Updated**: February 25, 2026  
**For Questions**: Contact Development Team
