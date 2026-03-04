# Troubleshooting Guide

## Overview

Common issues and solutions for the HRIS Mobile Application development and deployment.

---

## Development Issues

### Flutter & Dart

#### Issue: "flutter: command not found"

**Symptoms**: Command not recognized in terminal

**Solutions**:
```bash
# Check Flutter installation
flutter --version

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"  # macOS/Linux

# Or on Windows
setx PATH "%PATH%;C:\flutter\bin"

# Verify
flutter doctor
```

#### Issue: "Pub get failed"

**Symptoms**: Dependencies won't install

**Solutions**:
```bash
# Clear cache
flutter clean
flutter pub cache clean

# Get dependencies again
flutter pub get --verbose

# Check for network issues
flutter pub get --system-temp

# Update Flutter
flutter upgrade
```

#### Issue: "The Gradle task assembleDebug failed"

**Symptoms**: Android build fails

**Solutions**:
```bash
# Clean build
flutter clean
cd android && ./gradlew clean && cd ..

# Update Gradle
# Edit android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip

# Rebuild
flutter pub get
flutter build apk
```

#### Issue: "CocoaPods could not find compatible versions"

**Symptoms**: iOS build fails with CocoaPods error

**Solutions**:
```bash
# Clean pods
cd ios && rm -rf Pods Podfile.lock && cd ..

# Update pods
cd ios && pod install --repo-update && cd ..

# Rebuild
flutter pub get
flutter build ios
```

---

### Android Development

#### Issue: Emulator won't start

**Symptoms**: Emulator crashes or doesn't launch

**Solutions**:
```bash
# List available AVDs
emulator -list-avds

# Kill existing emulator
adb kill-server

# Start with additional options
emulator -avd Pixel5 -wipe-data -no-boot-anim

# Check GPU compatibility
emulator -avd Pixel5 -gpu auto

# Disable GPU if needed
emulator -avd Pixel5 -gpu off
```

#### Issue: "ANDROID_SDK_ROOT not set"

**Symptoms**: Build fails with missing SDK path

**Solutions**:
```bash
# Find Android SDK location
ls ~/Library/Android/sdk  # macOS
ls ~/Android/Sdk  # Linux
echo %ANDROID_HOME%  # Windows

# Set environment variable
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin

# Or in pubspec.yaml snippet
# android {
#     compileSdkVersion 34
#     ndkVersion "25.1.8937393"
# }
```

#### Issue: Device not recognized (Windows)

**Symptoms**: ADB can't see connected Android device

**Solutions**:
```bash
# Install USB drivers
# Download from manufacturer's website

# Enable USB Debugging
# Settings → Developer Options → USB Debugging

# Reconnect device
adb kill-server
adb devices

# If still not visible
adb devices -l
```

---

### iOS Development (macOS)

#### Issue: "Xcode build failed"

**Symptoms**: iOS build fails with Xcode error

**Solutions**:
```bash
# Clean Xcode build
cd ios && xcodebuild clean && cd ..

# Update Xcode
sudo xcode-select --reset
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Rebuild
flutter clean
flutter pub get
flutter build ios
```

#### Issue: "Permission denied" running pod commands

**Symptoms**: CocoaPods permission error

**Solutions**:
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clear cache
rm -rf ~/.cocoapods

# Reinstall pods
cd ios && pod install --repo-update && cd ..
```

---

### Hot Reload & Hot Restart

#### Issue: Hot reload not working

**Symptoms**: Changes not reflected when pressing 'r'

**Solutions**:
```bash
# Perform full hot restart
R (in terminal)

# Or restart from scratch
flutter run

# If still not working
flutter clean
flutter run

# Check for syntax errors
dart analyze
```

#### Issue: "Hot restart failed"

**Symptoms**: Application crashes during hot restart

**Solutions**:
```bash
# Stop and restart
q (in terminal to quit)

# Clean rebuild
flutter clean
flutter run

# Check recent changes
git diff HEAD~1

# Revert problematic change
git checkout -- lib/pages/recently_changed.dart
```

---

## Authentication Issues

### Token & Login

#### Issue: "Token expired unexpectedly"

**Symptoms**: User logged out abruptly

**Solutions**:
```dart
// Check token expiration time
print('Token expires at: $_expiryTime');

// Verify refresh mechanism
print('Next refresh at: ${_nextRefreshTime}');

// Extend token timeout
static const Duration refreshInterval = Duration(minutes: 3);  // 4 → 3

// Or in api_config.dart
static const int tokenExpiryMinutes = 10;  // Increase if possible
```

#### Issue: "Authentication failed" on login

**Symptoms**: Login always fails even with correct credentials

**Solutions**:
```bash
# Check API endpoint
# In api_config.dart:
static const String baseUrl = 'http://192.168.79.55:8082';

# Test endpoint manually
curl -X POST http://192.168.79.55:8082/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass"}'

# Check server logs
tail -f /var/log/hris_api.log

# Verify credentials
mysql -u root -p -e "SELECT * FROM users WHERE email='test@example.com';"
```

#### Issue: "Bearer token invalid"

**Symptoms**: API returns 401 Unauthorized

**Solutions**:
```dart
// Verify token format
if (!token.contains('.') || token.split('.').length != 3) {
  print('Invalid token format');
  // Re-login
}

// Check token in headers
print('Authorization header: Bearer $token');

// Verify token not expired
final parts = token.split('.');
final payload = jsonDecode(
  utf8.decode(base64Url.decode(parts[1]))
);
print('Token expires: ${payload['exp']}');
```

---

## API Communication Issues

### Network Errors

#### Issue: "Network connection timeout"

**Symptoms**: API requests hang and timeout

**Solutions**:
```dart
// Check network connectivity
import 'package:connectivity/connectivity.dart';

final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.none) {
  print('No internet connection');
}

// Increase timeout
final response = await http.get(
  uri,
  headers: headers,
).timeout(Duration(seconds: 60));  // Default 30

// Check API server
ping 192.168.79.55
curl -v http://192.168.79.55:8082/
```

#### Issue: "HRIS server not reachable"

**Symptoms**: Can't connect to API server

**Solutions**:
```bash
# Check if server is running
curl -I http://192.168.79.55:8082

# Check server logs
ssh admin@192.168.79.55
systemctl status hris-api

# Check firewall
ufw status
ufw allow 8082

# Check network
route -n
netstat -tlnp | grep 8082
```

#### Issue: "SSL Certificate verification failed"

**Symptoms**: HTTPS requests fail with certificate error

**Solutions**:
```dart
// Accept self-signed certificates (dev only)
HttpClient httpClient = HttpClient();
httpClient.badCertificateCallback = (cert, host, port) => true;

// Or properly configure certificate
SecurityContext context = SecurityContext.defaultContext;
context.setTrustedCertificates('path/to/cert.pem');

// For production: ensure valid certificate
# Check certificate validity
openssl x509 -in certificate.pem -text -noout
```

### API Response Issues

#### Issue: "JSON parse error"

**Symptoms**: "FormatException: Unexpected character"

**Solutions**:
```dart
// Check API response
print('Response: ${response.body}');

// Validate JSON before parsing
try {
  final data = json.decode(response.body);
} on FormatException catch (e) {
  print('Invalid JSON: $e');
  print('Response was: ${response.body}');
}

// Ensure UTF-8 encoding
final body = utf8.decode(response.bodyBytes);
final data = json.decode(body);
```

#### Issue: "Unexpected response structure"

**Symptoms**: Key not found in JSON response

**Solutions**:
```dart
// Check response structure
print('Keys: ${response.keys}');

// Use safe access
final data = response['data'] ?? {};
final user = data['user'] ?? {};

// Validate before use
if (response.containsKey('data') && response['data'] != null) {
  // Safe to use
}

// Check API documentation
// compare actual response with API_DOCUMENTATION.md
```

---

## Database Issues

### Connection Problems

#### Issue: "Cannot connect to database"

**Symptoms**: "Connection refused" or timeout

**Solutions**:
```bash
# Check if database is running
systemctl status mysql
systemctl status postgresql

# Start database service
sudo systemctl start mysql
sudo service postgresql start

# Check connection
mysql -u root -p -e "SELECT 1;"
psql -U postgres -c "SELECT 1;"

# Check credentials
# Verify in environment variables or config file
echo $DB_PASSWORD
```

#### Issue: "Database authentication failed"

**Symptoms**: "Access denied for user"

**Solutions**:
```bash
# Reset password
mysql -u root -e "ALTER USER 'user'@'localhost' IDENTIFIED BY 'newpassword';"

# Or
psql -U postgres -c "ALTER USER database_user WITH PASSWORD 'newpassword';"

# Verify credentials
mysql -u root -p -h 192.168.79.55 -e "SELECT User FROM mysql.user;"
```

### Query Issues

#### Issue: "Database migration failed"

**Symptoms**: Migration script won't execute

**Solutions**:
```bash
# Check syntax
mysql -u root -p < migrations/v1.1.0.sql --verbose

# Run with error reporting
mysql -u root -p < migrations/v1.1.0.sql 2>&1 | head -50

# Check individual statements
mysql -u root -p -e "DESCRIBE users;"

# Rollback if needed
mysql -u root -p < migrations/v1.0.9_rollback.sql
```

---

## UI/Widget Issues

### Rendering Problems

#### Issue: "Blank/white screen"

**Symptoms**: App launches but shows nothing

**Solutions**:
```dart
// Check main.dart
void main() {
  runApp(const MyApp());  // Make sure runApp is called
}

// Verify home widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(  // Provide proper home
        body: Center(child: Text('Content')),
      ),
    );
  }
}

// Check if there are errors
flutter run -vv  // Verbose output
```

#### Issue: "RenderFlex overflow error"

**Symptoms**: "A RenderFlex overflowed by X pixels"

**Solutions**:
```dart
// Wrap in SingleChildScrollView
SingleChildScrollView(
  child: Column(),
)

// Or use Expanded for flexible widgets
Expanded(
  child: Widget(),
)

// Or use flexible sizing
Flexible(
  child: Container(),
)

// Check layout constraints
flutter run --verbose
```

#### Issue: "Widget not visible"

**Symptoms**: Widget exists but not visible on screen

**Solutions**:
```dart
// Check widget size
Container(
  width: 100,  // Explicit width
  height: 100, // Explicit height
  child: MyWidget(),
)

// Check z-index/stacking
Stack(
  children: [
    Background(),
    Positioned(
      top: 0,
      left: 0,
      child: Foreground(),
    ),
  ],
)

// Check visibility
Visibility(
  visible: true,  // Or condition
  child: MyWidget(),
)
```

---

## Performance Issues

### Slow App

#### Issue: "App freezes or stutters"

**Symptoms**: Jank, frame drops, unresponsive UI

**Solutions**:
```dart
// Check frame rate
flutter run --profile

// Avoid long operations on main thread
Future.delayed(Duration.zero, () {
  // Heavy computation
  performHeavyOperation();
});

// Use isolates for CPU-bound work
compute(heavyFunction, argument);

// Profile with DevTools
flutter pub global activate devtools
flutter pub global run devtools

// Check widget rebuilds
Widget build(BuildContext context) {
  print('Building CheckoutPage');  // Excessive rebuilds?
  return Scaffold();
}
```

#### Issue: "High memory usage"

**Symptoms**: App leaks memory or uses too much RAM

**Solutions**:
```dart
// Proper disposal of resources
@override
void dispose() {
  _controller?.dispose();
  _subscription?.cancel();
  super.dispose();
}

// Stream cleanup
StreamSubscription sub = stream.listen(...);
// Later:
await sub.cancel();

// Image caching
// Use imageCache.clear() sparingly
imageCache.clearLiveImages();

// Check for memory leaks
flutter run --trace-startup
```

---

## Build Issues

### APK/AAB Build Failures

#### Issue: "Gradle build failed"

**Symptoms**: "FAILURE: Build failed with an exception"

**Solutions**:
```bash
# Clean gradle cache
cd android && ./gradlew clean && cd ..

# Update gradle
# Edit android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip

# Show full error
./gradlew build -s

# Check Java version
java -version  # Should be 11+

# Rebuild APK
flutter build apk --release
```

#### Issue: "Duplicate class error"

**Symptoms**: "duplicate class"

**Solutions**:
```bash
# Search for duplicates
find . -name "*.jar" | xargs grep "ClassName"

# Remove duplicates
# Edit android/build.gradle:
dependencies {
  // Remove duplicate dependencies
}

# Or use dependency exclusion
dependencies {
  implementation ('package:version') {
    exclude module: 'conflicting-module'
  }
}
```

---

## Deployment Issues

### Store Upload Failures

#### Issue: "App version already exists"

**Symptoms**: Store rejects upload

**Solutions**:
```bash
# Increment build number
# In pubspec.yaml
version: 1.0.0+2  # Increase +number

# Rebuild APK
flutter build apk --release

# Or for iOS
# In Info.plist
<key>CFBundleVersion</key>
<string>2</string>
```

#### Issue: "App not signed properly"

**Symptoms**: "Install fails" or "Signature mismatch"

**Solutions**:
```bash
# Verify signing
jarsigner -verify -verbose app.apk

# Re-sign if needed
# Ensure keystore exists
jarsigner -keystore hris-key.jks -storepass pass app.apk hris_key
```

---

## Error Codes & Messages

| Error Code | Meaning | Solution |
|-----------|---------|----------|
| 401 | Unauthorized | Re-login, check token |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Verify API endpoint |
| 500 | Server Error | Check server logs |
| 503 | Service Unavailable | Server maintenance, retry later |

---

## Support & Resources

### Getting Help

```
Documentation: /docs/
API Reference: API_DOCUMENTATION.md
Code Examples: examples/
```

### Reporting Issues

1. Check this guide first
2. Search GitHub issues
3. Ask in team chat
4. File detailed bug report with:
   - Device/OS version
   - Reproduction steps
   - Error logs
   - Screenshots

---

## Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| App won't start | `flutter clean && flutter run` |
| Tests fail | `flutter test --verbose` |
| Layout broken | Check `Expanded`, `Flexible`, scrolling |
| API fails | Check `baseUrl`, network, token |
| Build fails | Clear gradle: `./gradlew clean` |

---

## Next Steps

- Review [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for setup
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API details
- See [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md) for security

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Last Revised**: March 3, 2026
