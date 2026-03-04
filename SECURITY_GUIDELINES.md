# Security Guidelines

## Overview

This document outlines security best practices and guidelines for the HRIS Mobile Application. All developers must follow these guidelines when writing code and handling sensitive data.

---

## 1. Authentication & Authorization

### Password Security

#### Do's
```dart
// ✅ DO: Hash passwords with bcrypt/argon2
String hashedPassword = bcrypt.hashPassword(password);

// ✅ DO: Require strong passwords
// - Minimum 8 characters
// - At least 1 uppercase letter
// - At least 1 number
// - At least 1 special character

final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*])');
if (!passwordRegex.hasMatch(password)) {
  throw Exception('Password is not strong enough');
}

// ✅ DO: Clear passwords from memory after use
String? _tempPassword;
_tempPassword = null; // Clear immediately
```

#### Don'ts
```dart
// ❌ DON'T: Store plaintext passwords
String password = "user_password"; // NEVER

// ❌ DON'T: Log passwords
print('Password: $password'); // DANGER!

// ❌ DON'T: Use weak hashing
String weak = password.hashCode.toString(); // INSECURE
```

### Token Management

#### JWT Token Handling
```dart
// ✅ DO: Store token securely
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  
  late String _token;
  late String _refreshToken;
  late DateTime _expiryTime;
  
  // Tokens stored in memory only (not in SharedPreferences)
  factory TokenManager() => _instance;
  TokenManager._internal();
  
  // ✅ DO: Auto-refresh before expiration
  void _setupAutoRefresh() {
    final refreshDuration = Duration(
      seconds: (_expiryTime.difference(DateTime.now()).inSeconds - 60),
    );
    Future.delayed(refreshDuration, () => _refreshToken());
  }
  
  // ✅ DO: Clear on logout
  void logout() {
    _token = '';
    _refreshToken = '';
    print('✅ [TokenManager] Tokens cleared');
  }
}

// ✅ DO: Include token in headers
Map<String, String> getHeaders(String token) {
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}

// ✅ DO: Validate token format
bool isValidToken(String token) {
  final parts = token.split('.');
  return parts.length == 3; // JWT format: header.payload.signature
}
```

#### Don'ts
```dart
// ❌ DON'T: Log tokens
print('Token: $token'); // EXPOSE!

// ❌ DON'T: Store token in SharedPreferences
await prefs.setString('token', token); // INSECURE

// ❌ DON'T: Use tokens in URLs
final url = 'http://api.example.com/users?token=$token'; // EXPOSED

// ❌ DON'T: Use tokens without HTTPS
http.Client().get(Uri.http('unsecured.com', '/api')); // NO SSL
```

---

## 2. API Communication

### HTTPS/TLS

```dart
// ✅ DO: Always use HTTPS
const String baseUrl = 'https://api.example.com'; // HTTPS

// ✅ DO: Enforce certificate validation
class SecureHttpClient extends http.BaseClient {
  final SecurityContext securityContext = SecurityContext.defaultContext;
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Validate SSL certificates
    // Reject self-signed certificates in production
  }
}

// ❌ DON'T: Use HTTP in production
const String baseUrl = 'http://api.example.com'; // UNSECURED!

// ❌ DON'T: Allow insecure connections
HttpOverrides.global = MyHttpOverrides(); // Disables certificate check
```

### Certificate Pinning

```dart
// ✅ DO: Implement certificate pinning
class PinnedHttpClient extends http.BaseClient {
  static const String pinnedCert = '''-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgI...
-----END CERTIFICATE-----''';
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Validate certificate against pinned cert
    // Reject if mismatch
  }
}
```

### API Request Security

```dart
// ✅ DO: Add request timeout
final response = await http.get(
  uri,
  headers: headers,
).timeout(Duration(seconds: 30));

// ✅ DO: Add request signing (HMAC)
String signRequest(String method, String path, String body) {
  final secret = 'your-api-secret';
  final message = '$method\n$path\n$body';
  return Hmac(sha256, utf8.encode(secret))
    .convert(utf8.encode(message))
    .toString();
}

// ✅ DO: Validate response signature
bool validateResponseSignature(String signature, String body) {
  final expected = signRequest('GET', '/path', body);
  return signAlgorithm.compare(signature, expected);
}
```

---

## 3. Data Protection

### Encryption

#### At Rest
```dart
// ✅ DO: Encrypt sensitive data at rest
// Use flutter_secure_storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  
  Future<void> storeCredentials(String email, String password) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }
  
  Future<String?> retrieveCredentials(String key) async {
    return await _storage.read(key: key);
  }
}
```

#### In Transit
```dart
// ✅ DO: Use HTTPS for all communication
// ✅ DO: Implement TLS 1.3
// ✅ DO: Use strong cipher suites
```

### Sensitive Data Handling

```dart
// ✅ DO: Clear sensitive data from memory
class AuthService {
  String? _password;
  
  Future<bool> login(String email, String password) async {
    try {
      _password = password;
      // Use password
      final result = await _authenticateWithBackend(email, password);
      return result;
    } finally {
      // Always clear password
      _password = null;
    }
  }
}

// ✅ DO: Cover password input fields
TextField(
  obscureText: true, // Hide password
  enableInteractiveSelection: false, // Prevent copy
)

// ❌ DON'T: Log sensitive data
print('Email: $email, Password: $password'); // DANGEROUS!

// ❌ DON'T: Store sensitive data unencrypted
await prefs.setString('password', password); // INSECURE!

// ❌ DON'T: Send sensitive data in URLs
final url = 'https://api.example.com/login?password=$password'; // EXPOSED!
```

---

## 4. Input Validation

### Email Validation

```dart
// ✅ DO: Validate email format
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  return emailRegex.hasMatch(email);
}

// ✅ DO: Trim whitespace
String cleanEmail = email.trim().toLowerCase();

// ✅ DO: Validate length
if (email.length > 255) {
  throw Exception('Email too long');
}
```

### Password Validation

```dart
// ✅ DO: Enforce password policies
class PasswordValidator {
  static const minLength = 8;
  static const maxLength = 128;
  
  static bool isValid(String password) {
    // Length check
    if (password.length < minLength || password.length > maxLength) {
      return false;
    }
    
    // Complexity check
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialChar;
  }
}
```

### Form Input Sanitization

```dart
// ✅ DO: Sanitize all user inputs
String sanitizeInput(String input) {
  // Remove leading/trailing whitespace
  String clean = input.trim();
  
  // Remove special characters if not needed
  clean = clean.replaceAll(RegExp(r'[<>"\']'), '');
  
  // Limit length
  if (clean.length > 255) {
    clean = clean.substring(0, 255);
  }
  
  return clean;
}

// ✅ DO: Validate data type
if (int.tryParse(input) == null) {
  throw Exception('Invalid integer format');
}

// ❌ DON'T: Accept unsanitized user input
String unsafeInput = userInput; // Could contain malicious code
```

---

## 5. Error Handling & Logging

### Secure Logging

```dart
// ✅ DO: Log errors without sensitive data
try {
  final response = await authenticateUser(email, password);
} catch (e) {
  print('❌ [AuthService] Authentication failed'); // Generic message
  // Don't log email or password
}

// ✅ DO: Use error codes
enum AuthError {
  invalidCredentials(1001),
  networkError(1002),
  serverError(1003),
  tokenExpired(1004);
  
  final int code;
  const AuthError(this.code);
}

// ✅ DO: Log only necessary information
print('❌ [AuthService] Error code: ${AuthError.invalidCredentials.code}');
```

### User-Friendly Error Messages

```dart
// ✅ DO: Show generic messages to users
String getUserFriendlyMessage(dynamic error) {
  if (error is SocketException) {
    return 'Network connection failed. Please check your internet.';
  } else if (error is TimeoutException) {
    return 'Request timed out. Please try again.';
  } else {
    return 'An error occurred. Please try again later.';
  }
}

// ❌ DON'T: Expose technical details to users
showErrorDialog('Invalid credentials'); // Good
showErrorDialog('PostgreSQL: Column not found'); // Bad!
```

---

## 6. Access Control

### Role-Based Access Control (RBAC)

```dart
// ✅ DO: Implement role-based access
enum UserRole {
  admin,
  manager,
  employee,
  guest
}

class AuthorizationService {
  static bool hasPermission(UserRole role, String action) {
    const permissions = {
      UserRole.admin: ['view_all', 'edit_all', 'delete_users'],
      UserRole.manager: ['view_team', 'edit_team', 'approve_dtr'],
      UserRole.employee: ['view_own', 'edit_own'],
      UserRole.guest: ['view_public'],
    };
    
    return permissions[role]?.contains(action) ?? false;
  }
}

// ✅ DO: Check permissions before showing UI
if (AuthorizationService.hasPermission(currentUserRole, 'delete_users')) {
  // Show delete button
}
```

### Rate Limiting

```dart
// ✅ DO: Implement rate limiting
class RateLimiter {
  static final Map<String, List<DateTime>> _requests = {};
  static const maxRequests = 10;
  static const duration = Duration(minutes: 1);
  
  static bool allowRequest(String userId) {
    final now = DateTime.now();
    final userRequests = _requests[userId] ?? [];
    
    // Remove old requests
    userRequests.removeWhere(
      (req) => now.difference(req) > duration
    );
    
    if (userRequests.length >= maxRequests) {
      return false; // Rate limit exceeded
    }
    
    userRequests.add(now);
    _requests[userId] = userRequests;
    return true;
  }
}
```

---

## 7. Dependency Security

### Keeping Dependencies Updated

```bash
# Check for vulnerabilities
flutter pub outdated
flutter pub upgrade --dry-run

# Update dependencies
flutter pub upgrade

# Check pubspec.lock for known issues
dart pub audit
```

### Avoiding Vulnerable Packages

```yaml
# ✅ DO: Pin specific versions
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.3

# ❌ DON'T: Use wildcard versions
dependencies:
  http: '*'
  shared_preferences: '>0.0.1'
```

---

## 8. Device Security

### App Permissions

```dart
// ✅ DO: Request necessary permissions
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

// AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

// Info.plist (iOS)
<key>NSCameraUsageDescription</key>
<string>We need camera access for profile photos</string>
```

### Jailbreak/Root Detection

```dart
// ✅ DO: Detect rooted/jailbroken devices
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

Future<void> checkDeviceSecurity() async {
  bool jailbroken = await FlutterJailbreakDetection.jailbroken;
  if (jailbroken) {
    // Handle compromised device
    showErrorDialog('This app cannot run on rooted/jailbroken devices');
  }
}
```

---

## 9. Security Checklist

### Before Production Release

- [ ] All API endpoints use HTTPS
- [ ] JWT tokens validated and refreshed properly
- [ ] Passwords hashed with bycrypt (min 10 rounds)
- [ ] Sensitive data encrypted at rest
- [ ] No credentials in code or version control
- [ ] Input validation on all user inputs
- [ ] Error messages don't leak sensitive info
- [ ] SQL injection prevention (parameterized queries)
- [ ] CORS properly configured
- [ ] CSRF protection implemented
- [ ] Dependency vulnerabilities checked
- [ ] Code reviewed by security team
- [ ] Penetration testing completed
- [ ] Privacy policy reviewed by legal
- [ ] Data retention policies enforced
- [ ] Audit logging enabled
- [ ] Rate limiting implemented
- [ ] Certificate pinning enabled

---

## 10. Incident Response

### Security Breach Protocol

1. **Identify**: Detect and confirm security breach
2. **Contain**: Stop unauthorized access immediately
3. **Assess**: Determine scope and impact
4. **Document**: Record all actions taken
5. **Notify**: Alert affected users within 72 hours
6. **Remediate**: Fix root cause and patch vulnerability
7. **Review**: Conduct post-incident review

### Contact & Escalation

```
Security Issues: security@company.com
Urgent: +63-XXX-XXXX
```

---

## Next Steps

- Review [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) for data storage
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for secure deployment
- See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API security

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Status**: Approved by Security Team
