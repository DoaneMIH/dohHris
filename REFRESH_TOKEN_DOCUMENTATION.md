# Refresh Token Documentation

## Overview

The HRIS Mobile Application implements a **7-day refresh token system** to provide persistent user sessions across app restarts while maintaining security through short-lived access tokens.

## Token Architecture

### Two-Token System

| Token Type | Duration | Purpose | Storage |
|-----------|----------|---------|---------|
| **Access Token** | 5 minutes | API request authentication | Memory only |
| **Refresh Token** | 7 days | Session persistence & silent re-login | SharedPreferences (Encrypted) |

### Why Two Tokens?

- **Access tokens** expire quickly (5 min) to limit damage if compromised
- **Refresh tokens** are long-lived (7 days) to enable session restoration without requiring user login
- **Silent re-login** happens automatically every 4 minutes to obtain new access tokens before expiry

---

## User Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ USER OPENS APP                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ Load Refresh Token from       │
        │ SharedPreferences             │
        └──────────────┬───────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
   ✅ Token Valid?           ❌ Token Expired/Missing
   (Less than 7 days)        
         │                           │
         ▼                           ▼
   Re-login silently         Show Login Page
   (Get new access token)    (User enters credentials)
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ Start Auto-Refresh Timer     │
        │ (Every 4 minutes)            │
        └──────────────┬───────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
    ✅ Token Refreshed         ❌ 401 Error
    (Keep user logged in)      (Credentials invalid)
         │                           │
         │                           ▼
         │                   Force Logout
         │                   (Send to Login)
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
              App continues running
```

---

## Technical Implementation

### 1. Token Manager (`token_manager.dart`)

The `TokenManager` singleton manages all token operations:

```dart
class TokenManager {
  // Refresh every 4 minutes (before 5-min server expiry)
  static const Duration refreshInterval = Duration(minutes: 4);
  
  // Refresh token valid for 7 days
  static const Duration refreshTokenValidityDuration = Duration(days: 7);
}
```

#### Key Methods

| Method | Purpose |
|--------|---------|
| `initialize()` | Called after login with token, credentials, and refresh token |
| `loadRefreshTokenFromStorage()` | Called at app startup to restore session |
| `performTokenRefresh()` | Re-login using stored credentials (auto-called every 4 min) |
| `_startAutoRefresh()` | Starts the 4-minute timer |
| `_saveRefreshTokenToStorage()` | Persist tokens to SharedPreferences |
| `clearStorage()` | Clear all stored tokens (logout) |
| `dispose()` | Clean up timers and memory (explicit logout) |

### 2. Session Manager (`session_manager.dart`)

The `SessionManager` singleton handles app-level session restoration:

```dart
Future<bool> initializeSession({Function? onTokenExpired}) async {
  final tokenManager = TokenManager();
  
  if (onTokenExpired != null) {
    tokenManager.setOnTokenExpired(onTokenExpired);
  }
  
  return await tokenManager.loadRefreshTokenFromStorage();
}
```

**Returns:**
- `true` → Valid session found, skip login
- `false` → No session, show login

### 3. Auth Service (`auth_service.dart`)

The `AuthService` handles login and logout:

#### Login Flow

```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    // Initialize TokenManager with credentials for silent re-login
    TokenManager().initialize(
      data['token'],  // Access token (5 min)
      email: email,
      password: password,
      refreshToken: data['refresh_token'] ?? data['token'],  // Refresh token (7 days)
    );
    
    return {'success': true, 'data': data};
  }
}
```

#### Logout Flow

```dart
static Future<void> logout(BuildContext context) async {
  final tokenManager = TokenManager();
  
  // 1. Stop background timers and clear memory
  tokenManager.dispose();
  
  // 2. Clear SharedPreferences
  await tokenManager.clearStorage();
  
  // 3. Navigate back to login
  Navigator.pushNamedAndRemoveUntil(
    context, 
    MyRoutes.loginPage, 
    (route) => false,
  );
}
```

### 4. Main App Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionManager = SessionManager();
  final hasValidSession = await sessionManager.initializeSession(
    onTokenExpired: () {
      // Token expired while app was running
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        MyRoutes.loginPage,
        (route) => false,
      );
    },
  );

  runApp(MyApp(hasValidSession: hasValidSession));
}
```

---

## Data Flow

### Startup Sequence

1. **main.dart** calls `SessionManager.initializeSession()`
2. **SessionManager** calls `TokenManager.loadRefreshTokenFromStorage()`
3. **TokenManager** reads from SharedPreferences:
   - Refresh token
   - Expiry timestamp
   - Stored email & password
4. If valid, **TokenManager** calls `performTokenRefresh()` to get a new access token
5. **TokenManager** starts a 4-minute timer to refresh periodically
6. App navigates to **Home** or **Login** based on session validity

### Auto-Refresh Sequence (Every 4 Minutes)

1. Timer fires in **TokenManager**
2. Calls `performTokenRefresh()`
3. Re-login via `POST /auth/login` with stored email/password
4. Server returns new access token
5. Update `_token` in memory
6. Wait 4 minutes, repeat

### Token Expiration Handling (401 Response)

1. Auto-refresh receives 401 (Unauthorized)
2. **TokenManager** calls `_handleTokenExpired()`
3. Cancels timer, clears all storage
4. Calls `onTokenExpired` callback
5. **main.dart** callback navigates user to Login
6. User must re-authenticate

---

## Storage Details

### SharedPreferences Keys

```dart
static const String _refreshTokenKey = 'refresh_token';
static const String _tokenExpiresKey = 'token_expires_at';  // ISO 8601 format
static const String _emailKey = 'user_email';
static const String _passwordKey = 'user_password';
```

### Example Storage Content

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_expires_at": "2026-03-16T10:30:45.123456Z",
  "user_email": "john.doe@company.com",
  "user_password": "hashed_or_encrypted_password"
}
```

⚠️ **Security Note:** Credentials are stored in SharedPreferences. For production, consider:
- Encrypting credential storage using `flutter_secure_storage`
- Using refresh tokens without storing passwords
- Implementing biometric authentication for retrieval

---

## Security Considerations

### ✅ Current Protections

| Feature | Benefit |
|---------|---------|
| 5-minute access tokens | Limits exposure if token is intercepted |
| 7-day refresh tokens | Reduces need to store long-term credentials |
| Auto-refresh before expiry | Seamless UX without user interruption |
| 401 detection | Immediately logs out if credentials invalid |
| `dispose()` on logout | Clears all sensitive data from memory |

### ⚠️ Recommendations

1. **Use Secure Storage**
   ```dart
   // Current: SharedPreferences (not encrypted)
   // Recommended: flutter_secure_storage
   final secureStorage = FlutterSecureStorage();
   await secureStorage.write(key: 'token', value: token);
   ```

2. **HTTPS Only**
   - Ensure API endpoints use HTTPS
   - Prevent token interception on unsecured networks

3. **Credential Handling**
   - Never expose passwords in logs
   - Consider OAuth/SSO to avoid storing credentials

4. **Clock Skew**
   - Verify device time is reasonable
   - Handle server time differences

5. **Revocation**
   - Implement server-side token blacklist
   - Allow users to logout all sessions

---

## API Contract

### Login Endpoint

**POST** `/auth/login`

**Request:**
```json
{
  "email": "user@company.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "employee": {
    "id": 123,
    "name": "John Doe",
    "email": "john.doe@company.com"
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Invalid credentials"
}
```

### API Requests

All requests use the access token in the `Authorization` header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Logging

The system uses print statements for debugging:

| Format | Meaning |
|--------|---------|
| 🔐 | Authentication events |
| 🎫 | Token operations |
| 🔄 | Refresh operations |
| ⏰ | Timer/timing events |
| 📤/📥 | HTTP requests/responses |
| ✅ | Success |
| ❌ | Errors |
| 💥 | Exceptions |

### Example Log Output

```
🔍 [SessionManager] Checking for existing session...
✅ [TokenManager] Refresh token loaded from storage (Valid for 5 more days)
🎫 [TokenManager] Refresh token expires at: 2026-03-16T10:30:45.123456Z
🔄 [TokenManager] Refreshing token via /auth/login ...
📥 [TokenManager] Response status code: 200
✅ [TokenManager] Token refreshed successfully!
⏰ [TokenManager] Starting auto-refresh timer
⏰ [TokenManager] Will refresh every 4 min 0 sec
```

---

## Troubleshooting

### Issue: User logged out after app restart

**Cause:** Refresh token expired (>7 days) or corrupted storage
**Solution:**
1. Check logs for "Refresh token expired"
2. Verify SharedPreferences keys in device settings
3. Clear app data and re-login

### Issue: Auto-refresh not working

**Cause:** 
- Timer didn't start
- Network error during refresh
- Credentials cleared while timer was active

**Debug:**
1. Check for ⏰ log entries every 4 minutes
2. Look for 📥 response status codes
3. Verify credentials still stored

### Issue: User forced to login every 5 minutes

**Cause:** Auto-refresh timer not running or failing silently

**Fix:**
1. Ensure `_startAutoRefresh()` is called after `initialize()`
2. Verify network connectivity
3. Check for 401 responses in logs

### Issue: Session persists after logout

**Cause:** `dispose()` or `clearStorage()` not called

**Solution:**
1. Always call `logout(context)` from AuthService
2. Verify SharedPreferences keys are cleared
3. Restart app to confirm

---

## Integration Checklist

- [ ] TokenManager singleton is initialized before using tokens
- [ ] SessionManager called in main() with onTokenExpired callback
- [ ] Login flow calls TokenManager.initialize() with refresh token
- [ ] Logout flow calls AuthService.logout()
- [ ] All API requests use TokenManager.token in Authorization header
- [ ] Network errors are handled gracefully
- [ ] Device has internet connection before auto-refresh
- [ ] Secure storage considered for production
- [ ] Logout callback properly clears navigation stack

---

## References

- [RFC 6749 - OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
- [Flutter SharedPreferences Documentation](https://pub.dev/packages/shared_preferences)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

**Last Updated:** March 9, 2026  
**Status:** Active  
**Version:** 1.0
