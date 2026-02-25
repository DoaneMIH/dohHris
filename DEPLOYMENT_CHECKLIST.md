# HRIS Mobile Application - Setup & Deployment Checklist

## Local Development Setup Checklist

### Prerequisites
- [ ] Flutter SDK installed (3.10.7+)
- [ ] Dart SDK installed (3.10.7+)
- [ ] Android Studio installed with API 21+ emulator
- [ ] Xcode installed (macOS only) for iOS development
- [ ] Git installed and configured
- [ ] VS Code or Android Studio IDE installed
- [ ] Backend server running and accessible

### Initial Setup

#### 1. Environment Configuration
- [ ] Clone repository from Git
- [ ] Navigate to project directory
- [ ] Verify Flutter version: `flutter --version`
- [ ] Verify Dart version: `dart --version`
- [ ] Check SDK paths are configured correctly

#### 2. Dependencies Installation
```bash
# Get all dependencies
flutter pub get

# Check for any issues
flutter doctor

# Expected output should show:
# ✓ Flutter (Channel stable, ...)
# ✓ Android toolchain - develop for Android devices
# ✓ Xcode - develop for iOS and macOS (if on macOS)
# ✓ VS Code (version X.X.X)
```

#### 3. Configuration Setup
- [ ] Edit `lib/config/api_config.dart`
- [ ] Update `baseUrl` to your backend server:
  ```dart
  static const String baseUrl = 'http://your-server-ip:8082';
  ```
- [ ] Verify all endpoints are correctly configured
- [ ] Test backend connectivity with Postman/cURL

#### 4. Generate App Icons
```bash
flutter pub run flutter_launcher_icons
```
- [ ] Verify icons generated in `android/` and `ios/` folders
- [ ] Check icon appears in launcher

#### 5. Build & Run for Testing

##### Android
```bash
flutter devices  # Verify emulator/device connected
flutter run -d android
```
- [ ] App launches successfully
- [ ] No build errors
- [ ] Splash screen displays

##### iOS (macOS only)
```bash
flutter run -d ios
```
- [ ] App builds without errors
- [ ] Deployment target compatible (12.0+)

#### 6. Functional Testing
- [ ] Login page loads correctly
- [ ] Input validation works
- [ ] Test login with valid credentials
- [ ] Token obtained and stored
- [ ] Navigation to home page succeeds
- [ ] Profile page loads user data
- [ ] DTR page displays records
- [ ] Photo upload functionality works
- [ ] Bottom navigation tabs respond
- [ ] About page displays correctly

---

## Code Quality Checklist

### Code Standards
- [ ] No lint errors: `flutter analyze`
- [ ] Code follows Dart style guide
- [ ] Naming conventions consistent (camelCase, PascalCase)
- [ ] Comments added for complex logic
- [ ] Debug prints use consistent emoji format
- [ ] No hardcoded values (use config file)

### Error Handling
- [ ] All API calls wrapped in try-catch
- [ ] Meaningful error messages displayed
- [ ] Token expiration handled gracefully
- [ ] Network errors handled properly
- [ ] Invalid image uploads caught
- [ ] Form validation implemented

### Security
- [ ] API key not committed to repo
- [ ] Passwords never logged
- [ ] Tokens handled securely
- [ ] HTTPS enforced in production
- [ ] No sensitive data in logs
- [ ] Image picker permissions requested

### Testing
- [ ] Widget tests written
- [ ] Unit tests for services
- [ ] Manual testing completed
- [ ] Edge cases tested
- [ ] Different screen sizes tested

---

## Pre-Deployment Checklist

### Code Preparation
- [ ] All features implemented
- [ ] Code reviewed by team
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Code formatted consistently
- [ ] Comments updated
- [ ] README updated if needed
- [ ] CHANGELOG updated

### Configuration
- [ ] Backend URL set correctly
- [ ] All API endpoints verified
- [ ] App icon finalized
- [ ] App name correct
- [ ] Version number updated (1.0.0+1)
- [ ] Package name correct

### Documentation
- [ ] DOCUMENTATION.md complete
- [ ] API_REFERENCE.md updated
- [ ] Code comments sufficient
- [ ] README.md comprehensive
- [ ] Setup instructions clear
- [ ] API docs generated if needed

---

## Android Build & Deployment

### Prerequisites
- [ ] Android SDK installed (API 21+)
- [ ] Build tools configured
- [ ] gradle.properties configured
- [ ] App signing key created
- [ ] Key password stored securely

### APK Build

#### Debug Build
```bash
flutter build apk --debug
```
- [ ] Build succeeds
- [ ] APK size reasonable (< 100MB)
- [ ] APK installable on device
- [ ] App functions correctly

#### Release Build (Split by ABI)
```bash
flutter build apk --split-per-abi --release
```
Output:
- [ ] `app-armeabi-v7a-release.apk` generated
- [ ] `app-arm64-v8a-release.apk` generated
- [ ] `app-x86_64-release.apk` generated
- [ ] All APKs installable
- [ ] All APKs functional

### App Bundle Build (For Play Store)
```bash
flutter build appbundle --release
```
- [ ] AAB file generated
- [ ] File size acceptable
- [ ] Verifiable with bundletool

### APK Signing

#### Create Keystore (First time only)
```bash
keytool -genkey -v -keystore ~/hris_key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias hris_key
```
- [ ] Keystore created
- [ ] Password stored securely
- [ ] Backup created

#### Sign APK
```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/hris_key.jks \
  app-release.apk hris_key
```
- [ ] APK signed successfully
- [ ] Signature verified

### Google Play Store Preparation
- [ ] Google Play Developer account created
- [ ] App created in Play Console
- [ ] App name finalized
- [ ] App description written
- [ ] Screenshots prepared (5-8 screenshots)
- [ ] Privacy policy created
- [ ] Content rating questionnaire filled
- [ ] Pricing set
- [ ] Target audience defined
- [ ] Release notes written

### Play Store Upload
- [ ] Internal testing track AAB uploaded
- [ ] Testers added
- [ ] Testing period started (min 2 days)
- [ ] QA testing completed
- [ ] Beta track upload
- [ ] Beta testers added
- [ ] Feedback received and addressed
- [ ] Closed testing completed
- [ ] Staged rollout configured (5% → 25% → 50% → 100%)
- [ ] Release approved by review team

### Post-Android Deployment
- [ ] App visible publicly on Play Store
- [ ] Installation works for new users
- [ ] Auto-update checking enabled
- [ ] Crash reports monitored
- [ ] User feedback monitored
- [ ] Analytics dashboard active

---

## iOS Build & Deployment

### Prerequisites
- [ ] Xcode installed (latest version)
- [ ] Apple Developer account created
- [ ] Certificates created
- [ ] Provisioning profiles configured
- [ ] Bundle ID matches app
- [ ] Team ID configured

### Build Configuration

#### Update Build Settings
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Set deployment target to iOS 12.0+
- [ ] Set team ID: `DEVELOPMENT_TEAM = XXXXXXXXXX`
- [ ] Update bundle identifier
- [ ] Set version and build number

#### Test on Simulator
```bash
flutter run -d ios
```
- [ ] App builds successfully
- [ ] App runs on simulator
- [ ] All features working
- [ ] No runtime errors

#### Test on Device
- [ ] Connect iPhone/iPad
- [ ] App builds for device
- [ ] App functions correctly
- [ ] Camera permission works
- [ ] Photo upload works

### Build for TestFlight

#### Create Archive
```bash
flutter build ios --release
```
- [ ] Build succeeds
- [ ] No warnings

#### Upload via Xcode
- [ ] Open in Xcode: `open ios/Runner.xcworkspace`
- [ ] Select Generic iOS Device
- [ ] Product → Archive
- [ ] Archives window opens
- [ ] Select latest archive
- [ ] Click "Distribute App"

#### Upload to TestFlight
- [ ] Select "TestFlight & App Store"
- [ ] Click "Upload"
- [ ] Sign as required
- [ ] Wait for processing (5-20 minutes)
- [ ] App appears in TestFlight Builds tab

### TestFlight Testing
- [ ] Add internal testers (team members)
- [ ] Testers receive invite
- [ ] Testers install via TestFlight
- [ ] Testing completed (min 2 days)
- [ ] Bugs reported and fixed
- [ ] Ready for submission

### App Store Review Preparation
- [ ] App name finalized
- [ ] Subtitle added (if desired)
- [ ] Keywords (5) selected
- [ ] App description written (100-170 chars)
- [ ] Privacy policy URL provided
- [ ] Support email provided
- [ ] App category selected
- [ ] Content rating filled
- [ ] Screenshots prepared (6-8 per language)
- [ ] Preview video prepared (optional)
- [ ] Release notes written

### Submit to App Store
- [ ] Create app in App Store Connect
- [ ] Fill app information
- [ ] Select TestFlight build
- [ ] Fill all required fields
- [ ] Add app review information
- [ ] Submit for review
- [ ] Status monitored (3-24 hours typically)

### Apple Review Tips
- [ ] Test all functionality thoroughly
- [ ] Ensure no hardcoded test credentials
- [ ] Privacy policy accessible from app
- [ ] No external app store references
- [ ] App name consistent everywhere
- [ ] Complies with App Store Guidelines

### Post-iOS Deployment
- [ ] App visible on App Store
- [ ] Installation works for new users
- [ ] Automatic updates working
- [ ] Analytics dashboard active
- [ ] User reviews monitored
- [ ] Issues tracked and fixed

---

## Web Deployment Checklist

### Build for Web
```bash
flutter build web --release --web-renderer html
```
- [ ] Build completes successfully
- [ ] Output in `build/web/` directory
- [ ] No Flutter diagnostics errors

### Web Hosting Preparation
- [ ] Hosting service selected (Firebase, Netlify, etc.)
- [ ] Domain configured
- [ ] SSL certificate configured
- [ ] CORS headers configured
- [ ] Cache policy set up

### Firebase Hosting (If using)
```bash
firebase deploy --only hosting
```
- [ ] Firebase project created
- [ ] Firebase CLI installed
- [ ] Authorization configured
- [ ] Deployment successful
- [ ] Site accessible via URL
- [ ] HTTPS working

### General Web Deployment
- [ ] Upload `build/web/` contents to server
- [ ] Set correct MIME types
- [ ] Enable gzip compression
- [ ] Configure cache headers
- [ ] Test in multiple browsers:
  - [ ] Chrome
  - [ ] Firefox
  - [ ] Safari
  - [ ] Edge
- [ ] Test on mobile browsers
- [ ] Performance tested
- [ ] Security checked

---

## Windows Build & Deployment

### Prerequisites
- [ ] Visual Studio 2019+ installed
- [ ] Windows SDK installed
- [ ] CMake installed

### Build
```bash
flutter build windows --release
```
- [ ] Build succeeds
- [ ] Executable created in `build/windows/runner/Release/`
- [ ] No build warnings

### Testing
- [ ] App launches correctly
- [ ] All features work
- [ ] Performance acceptable
- [ ] No crashes

### Distribution
- [ ] Create installer (NSIS or MSI)
- [ ] Package for distribution
- [ ] Sign executable (optional but recommended)
- [ ] Create setup instructions

---

## macOS Build & Deployment

### Prerequisites
- [ ] Xcode installed
- [ ] macOS SDK configured
- [ ] Developer signing certificates

### Build
```bash
flutter build macos --release
```
- [ ] Build succeeds
- [ ] App bundle created

### Signing & Notarization
- [ ] Sign app with developer certificate
- [ ] Submit for notarization
- [ ] Wait for approval
- [ ] Staple ticket to app

### Distribution
- [ ] Create DMG for distribution
- [ ] Code sign DMG
- [ ] Prepare installation instructions

---

## Linux Build & Deployment

### Prerequisites
- [ ] Flutter Linux SDK configured
- [ ] Development libraries installed
- [ ] Build tools installed

### Build
```bash
flutter build linux --release
```
- [ ] Build succeeds
- [ ] Binary created in `build/linux/`

### Testing
- [ ] App launches and functions
- [ ] Performance acceptable

### Distribution
- [ ] Create AppImage or Snap package
- [ ] Publish to appropriate repository
- [ ] Create installation instructions

---

## Post-Deployment Monitoring

### Analytics & Performance
- [ ] Analytics dashboard configured
- [ ] User metrics tracked
- [ ] Crash reporting enabled
- [ ] Performance monitoring set up
- [ ] Error tracking active

### User Feedback
- [ ] App store reviews monitored
- [ ] User bug reports tracked
- [ ] Support email configured
- [ ] Response time < 24 hours

### Updates & Maintenance
- [ ] Version bump strategy defined
- [ ] Update schedule established
- [ ] Hot fix process documented
- [ ] Beta testing process ready
- [ ] Rollback procedure documented

### Security
- [ ] Regular security audits scheduled
- [ ] Dependencies updated
- [ ] Vulnerability scanning enabled
- [ ] SSL certificates renewed
- [ ] Data encryption verified

---

## Rollback Plan

If deployment issues occur:

1. [ ] Identify critical issue
2. [ ] Stop current rollout (if applicable)
3. [ ] Build previous version
4. [ ] Test thoroughly
5. [ ] Deploy previous version
6. [ ] Communicate to users
7. [ ] Investigate root cause
8. [ ] Implement fix
9. [ ] Re-test
10. [ ] Deploy fixed version

---

## Common Deployment Issues

### Issue: "Flutter SDK not found"
**Solution**: 
```bash
flutter doctor
# Follow instructions to install missing components
```

### Issue: "Gradle build failed"
**Solution**:
```bash
flutter clean
flutter pub get
flutter build apk
```

### Issue: "Provisioning profile not found (iOS)"
**Solution**:
- [ ] Check bundle ID matches
- [ ] Update provisioning profiles in Xcode
- [ ] Select correct team ID

### Issue: "App rejected from store"
**Solution**:
- [ ] Review rejection reason carefully
- [ ] Fix issue based on feedback
- [ ] Test again thoroughly
- [ ] Resubmit with detailed explanation

### Issue: "Slow build process"
**Solution**:
- [ ] Use `--split-per-abi` for Android
- [ ] Enable Gradle offline mode
- [ ] Increase build heap size
- [ ] Use faster build machine

### Issue: "Token expired in production"
**Solution**:
- [ ] TokenManager auto-refresh should handle
- [ ] Verify timestamp sync on server
- [ ] Check token refresh endpoint
- [ ] Implement user re-login fallback

---

## Version Management

### Versioning Strategy
- **Major**: Breaking changes, significant features
- **Minor**: New features, non-breaking changes
- **Patch**: Bug fixes, small improvements

### Current Version: 1.0.0+1
- Update `pubspec.yaml`:
  ```yaml
  version: 1.0.0+1
  ```
- Format: `versionName+buildNumber`
- Example: `1.0.1+2` = Version 1.0.1, Build 2

### Tag Release
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## Documentation After Deployment

- [ ] Update CHANGELOG.md with version changes
- [ ] Update README.md if needed
- [ ] Document any known issues
- [ ] Create release notes
- [ ] Update API documentation if changed
- [ ] Communicate changes to team
- [ ] Update deployment checklist based on lessons learned

---

**Last Updated**: February 25, 2026
**Checklist Version**: 1.0
**Reviewed By**: Development Team
