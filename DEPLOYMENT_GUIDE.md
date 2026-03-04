# Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the HRIS Mobile Application to production across all platforms.

---

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`flutter test`)
- [ ] Code analyzed (`dart analyze`)
- [ ] Code formatted (`dart format lib/`)
- [ ] No warnings in console
- [ ] Code reviewed and approved
- [ ] Git history clean

### Security
- [ ] All secrets/credentials removed from code
- [ ] API endpoints using HTTPS
- [ ] Authentication properly implemented
- [ ] Sensitive data encrypted
- [ ] Security audit completed
- [ ] Dependencies vetted

### Documentation
- [ ] README.md updated
- [ ] CHANGELOG.md updated
- [ ] API documentation complete
- [ ] User guide prepared
- [ ] Release notes written

### Configuration
- [ ] API endpoint configured for production
- [ ] Database connection strings updated
- [ ] App version incremented
- [ ] Build number incremented
- [ ] Feature flags configured

---

## Android Deployment

### 1. Prepare Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Build AAB for Play Store (recommended)
flutter build appbundle --release
```

### 2. Sign the App

#### Create Keystore (first time only)

```bash
# Create keystore
keytool -genkey -v -keystore ~/hris-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias hris_key

# Create a file android/key.properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=hris_key
storeFile=/path/to/hris-key.jks
```

#### Configure Signing

Edit `android/build.gradle.kts`:

```kotlin
signingConfigs {
    release {
        keyAlias = "hris_key"
        keyPassword = "your-key-password"
        storeFile = file("../hris-key.jks")
        storePassword = "your-keystore-password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.release
    }
}
```

### 3. Upload to Google Play Store

1. Create [Google Play Console](https://play.google.com/console) account
2. Create new app
3. Fill in app details:
   - App name: "HRIS Mobile"
   - Category: Business
   - Content rating: APG (All)
4. Upload AAB file
5. Add screenshots, description, privacy policy
6. Review and submit for approval

### 4. App Store Settings

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Edit `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.company.hris"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

### 5. Verification

```bash
# Verify APK
zipalign -v 4 app-release.apk app-release-aligned.apk

# Check signing
jarsigner -verify -verbose -certs app-release.apk
```

---

## iOS Deployment

### 1. Update App Version

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 2. Create Build

```bash
# Build iOS app
flutter build ios --release

# Or build for app store
flutter build ios -t lib/main.dart --release

# Build IPA
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build \
  -arch arm64 \
  -sdk iphoneos \
  -allowProvisioningUpdates
```

### 3. Create Apple Developer Account

1. Go to [Apple Developer](https://developer.apple.com)
2. Enroll in Apple Developer Program ($99/year)
3. Create provisioning profile
4. Create certificate

### 4. Configure Signing

Edit `ios/Runner.xcodeproj/project.pbxproj`:

```
PROVISIONING_PROFILE = "YOUR_PROFILE_ID";
DEVELOPMENT_TEAM = "YOUR_TEAM_ID";
CODE_SIGN_IDENTITY = "iPhone Distribution";
```

### 5. Upload to App Store Connect

1. Create app on [App Store Connect](https://appstoreconnect.apple.com)
2. Fill in app information
3. Create test flight build
4. Upload with Transporter

```bash
# Using xcrun
xcrun altool --upload-app \
  -t ios \
  -f app.ipa \
  -u apple@email.com \
  -p app-password
```

### 6. Submit for Review

1. Complete app review information
2. Add privacy policy URL
3. Set age rating
4. Upload screenshots
5. Submit for review

---

## Web Deployment

### 1. Build for Web

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build web version
flutter build web --release
```

### 2. Firebase Hosting Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting
```

### 3. Deploy to Firebase

```bash
# Deploy web app
firebase deploy --only hosting

# Check deployment
firebase hosting:channel:list
```

### 4. Configure Custom Domain

1. Go to Firebase Console
2. Select Hosting
3. Add custom domain
4. Follow DNS configuration steps
5. Wait 24 hours for SSL certificate

---

## Linux Deployment

### 1. Build for Linux

```bash
# Build Linux app
flutter build linux --release
```

### 2. Create AppImage

```bash
# Create AppImage
appimage-builder

# Configure in appimage-builder.yml
version: 1
AppDir:
  path: ./build/linux/x64/release/bundle
  app_info:
    id: com.company.hris
    name: HRIS Mobile
    icon: app_icon
    version: 1.0.0
```

### 3. Distribute

```bash
# Upload to GitHub Releases
gh release create v1.0.0 dist/*.AppImage

# Or host on own servers
scp dist/*.AppImage deploy@server.com:/var/www/downloads/
```

---

## Windows Deployment

### 1. Build for Windows

```bash
# Build Windows app
flutter build windows --release
```

### 2. Create Installer (MSIX)

```bash
# Create MSIX package
flutter pub get
flutter build windows --release

# Create installer
New-Item -Type Directory "msix_config"
# Configure MSIX settings
```

### 3. Sign Installer

```powershell
# Create certificate
New-SelfSignedCertificate -Type Custom \
  -Subject "CN=Company Name" \
  -KeyUsage DigitalSignature \
  -FriendlyName "HRIS Mobile" \
  -CertStoreLocation "Cert:\CurrentUser\My\"

# Sign MSIX
SignTool sign /fd SHA256 /td SHA256 \
  /f certificate.pfx /p password \
  app.msix
```

### 4. Distribute

- Upload to Microsoft Store
- Host on company website
- Distribute via software management tools

---

## macOS Deployment

### 1. Update Configuration

Edit `macos/Runner/Configs/Release.xcconfig`:

```
PRODUCT_BUNDLE_IDENTIFIER = com.company.hris
PRODUCT_NAME = HRIS Mobile
```

### 2. Build for macOS

```bash
# Build macOS app
flutter build macos --release

# Create DMG
hdiutil create -format UDZO \
  -srcfolder build/macos/Build/Products/Release/HRIS\ Mobile.app \
  -volname "HRIS Mobile" \
  HRIS-Mobile.dmg
```

### 3. Notarize App

```bash
# Submit for notarization
xcrun altool --notarize-app \
  -f HRIS-Mobile.zip \
  -t osx \
  -u apple@email.com

# Staple notarization ticket
xcrun stapler staple "HRIS Mobile.app"
```

### 4. Distribute

- Upload to App Store
- Host DMG on website
- Create auto-update mechanism

---

## CI/CD Deployment (CodeMagic)

### 1. Configure CodeMagic Workflow

Edit `codemagic.yaml`:

```yaml
workflows:
  android-release:
    name: Android Release Build
    triggering:
      events:
        - push
      branch:
        pattern: 'main'
    
    environment:
      flutter: latest
      xcode: latest
      cocoapods: 1.11
    
    scripts:
      - name: Get dependencies
        script: flutter pub get
      
      - name: Build APK
        script: flutter build apk --release
      
      - name: Upload to Play Store
        script: |
          bundle install
          fastlane android deploy
```

### 2. Configure Fastlane

Edit `android/fastlane/Fastfile`:

```ruby
default_platform(:android)

platform :android do
  desc "Build and upload to Play Store"
  lane :deploy do
    upload_to_play_store(
      track: 'beta',
      aab: 'build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

---

## Database Migration

### 1. Backup Production Database

```bash
# Create backup
mysqldump -u root -p production_db > backup_$(date +%Y%m%d).sql

# Verify backup
wc -l backup_20240303.sql
```

### 2. Run Migrations

```bash
# Execute migration scripts
mysql -u root -p production_db < migrations/v1.1.0.sql

# Verify migration
mysql -u root -p -e "SELECT COUNT(*) FROM users;"
```

### 3. Verify Data Integrity

```sql
-- Check row counts
SELECT table_name, table_rows 
FROM information_schema.tables 
WHERE table_schema = 'production_db';

-- Check constraints
SHOW TABLE STATUS FROM production_db;

-- Verify foreign keys
SELECT CONSTRAINT_NAME, TABLE_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE REFERENCED_TABLE_NAME IS NOT NULL;
```

---

## Post-Deployment Tasks

### 1. Monitoring

- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Check error logs
- [ ] Monitor API response times
- [ ] Check user feedback

### 2. User Communication

- [ ] Send release notes email
- [ ] Update website
- [ ] Announce in app
- [ ] Update documentation

### 3. Rollback Plan

If critical issues found:

```bash
# Revert to previous build
firebase hosting:rollback

# Or redeploy previous version
flutter build web --release

# Downgrade app version
firebase deploy --only hosting

# Notify users
# Post maintenance message
```

### 4. Analytics

```bash
# Track release metrics
firebase analytics report
# - Downloads
# - Install rate
# - Crash rate
# - User retention
```

---

## Version Management

### Semantic Versioning

Format: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes
- **BUILD**: Build number

### Update Version

```yaml
# pubspec.yaml
version: 1.0.0+1

# For next release
version: 1.1.0+2
```

Increment:
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes
- Build: Every release

---

## Troubleshooting Deployment

### APK/AAB Size Too Large

```bash
# Check app size
flutter build apk --analyze-size --release

# Reduce size
# Remove unused dependencies
# Enable R8/ProGuard minification
```

### App Crashes After Deployment

```bash
# Check logs
adb logcat | grep "FATAL"

# Check Firebase Crashlytics
firebase console

# Rollback if critical
firebase hosting:rollback
```

### Store Upload Failed

```bash
# Verify signature
jarsigner -verify -verbose -certs app.apk

# Check version code
# Increment versionCode for new upload
```

---

## Release Checklist

Before every release:

- [ ] Version number incremented
- [ ] Build number incremented
- [ ] Changelog updated
- [ ] README updated
- [ ] All tests passing
- [ ] Code coverage acceptable
- [ ] Security audit passed
- [ ] Usability tested
- [ ] Screenshots updated
- [ ] Release notes prepared
- [ ] Backup created
- [ ] Build successful
- [ ] Staging tested
- [ ] Approval obtained
- [ ] Deployed successfully
- [ ] Monitored for errors

---

## Next Steps

- Review [CI_CD_DOCUMENTATION.md](CI_CD_DOCUMENTATION.md) for automated builds
- Check [MONITORING.md](MONITORING.md) for post-deployment monitoring
- See [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md) for common issues

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Deployment Status**: Production Ready
