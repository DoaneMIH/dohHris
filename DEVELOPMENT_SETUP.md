# Development Setup Guide

## Overview

This guide walks you through setting up the development environment for the HRIS Mobile Application. Follow these steps to get the project running on your local machine.

---

## Prerequisites

### System Requirements

- **Operating System**: Windows 10+, macOS 10.11+, or Linux (Ubuntu 16.04+)
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk Space**: 5GB free space
- **Network**: Internet connection required for dependencies

### Required Software

- **Flutter SDK**: 3.10.7 or higher
- **Dart SDK**: 3.10.7 or higher (included with Flutter)
- **Git**: Latest version
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA

---

## Step 1: Install Flutter SDK

### Windows

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract to a directory (e.g., `C:\flutter`)
3. Add Flutter to PATH:
   - Go to **Settings** → **Environment Variables**
   - Add `C:\flutter\bin` to the PATH
4. Verify installation:
   ```bash
   flutter --version
   dart --version
   ```

### macOS

```bash
# Using Homebrew (recommended)
brew install flutter
flutter --version
dart --version
```

### Linux

```bash
# Download and extract
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.7-stable.tar.xz
tar xf flutter_linux_3.10.7-stable.tar.xz

# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"
```

---

## Step 2: Install Android Studio (for Android development)

### Windows & macOS & Linux

1. Download from [android.com/studio](https://developer.android.com/studio)
2. Install and launch
3. Configure SDK:
   - Go to **SDK Manager**
   - Install:
     - **Android SDK Platform 34** (or latest)
     - **Android SDK Build-Tools 34.0.0**
     - **Android Emulator**
     - **Android SDK Platform-Tools**
     - **Android SDK Tools**
4. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

---

## Step 3: Install Xcode (for iOS development - macOS only)

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Or install full Xcode from App Store
```

Verify installation:
```bash
xcode-select --print-path
```

---

## Step 4: Clone the Repository

```bash
# Clone the project
git clone <repository-url>
cd mobile_application

# Navigate to project directory
pwd  # Should show: .../mobile_application
```

---

## Step 5: Set Up the Flutter Project

### Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get

# Generate launchers icons
flutter pub run flutter_launcher_icons

# Update dependencies (optional)
flutter pub upgrade
```

### Verify Setup

```bash
# Run doctor to check everything
flutter doctor

# Expected output:
# ✓ Flutter (Channel stable, 3.10.7, ...)
# ✓ Android toolchain - develop for Android devices
# ✓ Xcode - develop for iOS and macOS (macOS only)
# ✓ VS Code (version ...)
```

---

## Step 6: Configure API Endpoint

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Development environment
  static const String baseUrl = 'http://192.168.79.55:8082';
  
  // Production environment
  // static const String baseUrl = 'https://hris-api.example.com';
  
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  // User endpoints
  static const String userProfileEndpoint = '/users/profile';
  // ... other endpoints
}
```

---

## Step 7: Set Up Emulators

### Android Emulator

```bash
# List available AVDs
emulator -list-avds

# Create new emulator (if needed)
avdmanager create avd -n Pixel5 -k "system-images;android-34;google_apis;x86_64"

# Start emulator
emulator -avd Pixel5

# Or use Android Studio GUI
```

### iOS Simulator (macOS only)

```bash
# List available simulators
xcrun simctl list devices

# Start simulator
open -a Simulator

# Or specify exact device
xcrun simctl boot <device-uuid>
```

---

## Step 8: Run the Application

### On Android Emulator

```bash
# Start emulator first
emulator -avd Pixel5

# Run app
flutter run

# Or with specific device
flutter run -d emulator-5554
```

### On iOS Simulator (macOS)

```bash
# Start simulator
open -a Simulator

# Run app
flutter run
```

### On Physical Device

```bash
# Enable USB Debugging on device
# Connect via USB

# List connected devices
flutter devices

# Run app
flutter run -d <device-id>
```

### On Web

```bash
# Run on Chrome
flutter run -d chrome

# Run on Firefox
flutter run -d firefox

# Run on Edge
flutter run -d edge
```

---

## Step 9: Set Up IDE

### VS Code Setup

1. Install extensions:
   - **Flutter** (Dart Code)
   - **Dart** (Dart Code)
   - **REST Client** (Huachao Mao)
   - **Dart Data Class Generator** (Hamed Mohamadi)

2. Create `.vscode/launch.json`:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Flutter",
         "request": "launch",
         "type": "dart",
         "program": "lib/main.dart"
       }
     ]
   }
   ```

### Android Studio Setup

1. Install plugins:
   - Enable **Dart** plugin
   - Enable **Flutter** plugin
2. Open project via **File** → **Open**
3. Wait for indexing to complete

---

## Step 10: Verify Installation

```bash
# Run all checks
flutter doctor -v

# Check all dependencies
flutter pub get

# Analyze code
dart analyze

# Format code
dart format lib/

# Run tests
flutter test
```

Expected output - all items should show a ✓:
- Flutter
- Android toolchain
- Xcode (if on macOS)
- IDE/Editor
- Devices

---

## Troubleshooting

### Issue: Flutter not found
**Solution**: 
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"  # Linux/macOS
# Or manually add to PATH on Windows
```

### Issue: Android SDK tools missing
**Solution**:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Then run doctor
flutter doctor
```

### Issue: Emulator won't start
**Solution**:
```bash
# Kill existing emulator instances
adb kill-server

# Start fresh
emulator -avd Pixel5 -wipe-data
```

### Issue: Dependencies conflict
**Solution**:
```bash
# Clean Flutter cache
flutter clean

# Get dependencies again
flutter pub get

# Update packages
flutter pub upgrade
```

### Issue: Port 8082 already in use
**Solution**:
```bash
# Kill process on port 8082 (Windows)
netstat -ano | findstr :8082
taskkill /PID <PID> /F

# Or use different port and update api_config.dart
```

---

## Development Commands

### Common Flutter Commands

```bash
# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run app in release mode
flutter run --release

# Run tests
flutter test

# Build APK
flutter build apk

# Build AAB (Play Store)
flutter build appbundle

# Build iOS
flutter build ios

# Build Web
flutter build web

# Format code
dart format lib/

# Analyze code
dart analyze

# Generate icons
flutter pub run flutter_launcher_icons

# Hot reload
r (in terminal during flutter run)

# Hot restart
R (in terminal during flutter run)

# Stop app
q (in terminal during flutter run)
```

---

## IDE Keyboard Shortcuts

### VS Code
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+F5` - Start Debugging
- `F5` - Continue/Start
- `Ctrl+K Ctrl+0` - Fold All
- `Ctrl+K Ctrl+J` - Unfold All

### Android Studio
- `Cmd/Ctrl + ,` - Settings
- `Shift + Cmd/Ctrl + P` - Run Anything
- `Ctrl + R` - Run
- `Ctrl + D` - Debug
- `Cmd/Ctrl + /` - Comment

---

## Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for quick start
2. Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API details
3. Review [CODE_STYLE_GUIDE.md](CODE_STYLE_GUIDE.md) for coding standards
4. See [ARCHITECTURE.md](ARCHITECTURE.md) for system design

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Status**: Ready for Development
