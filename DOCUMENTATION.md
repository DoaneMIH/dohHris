# HRIS Mobile Application - Complete Documentation

**Version**: 1.0 | **Last Updated**: March 2, 2026 | **Status**: Production Ready

## Quick Navigation

- **New to the project?** Start with [5-Minute Quick Start](#5-minute-quick-start)
- **Want to understand architecture?** See [Architecture & Design](#architecture--design)
- **Need to add features?** Check [Development Workflow](#development-workflow)
- **Ready to deploy?** Go to [Building & Deployment](#building--deployment)
- **Encountering issues?** Visit [Troubleshooting Guide](#troubleshooting-guide)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [5-Minute Quick Start](#5-minute-quick-start)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Features Overview](#features-overview)
6. [Architecture & Design](#architecture--design)
7. [Core Services](#core-services)
8. [Pages & Screens](#pages--screens)
9. [API Integration](#api-integration)
10. [Setup & Installation](#setup--installation)
11. [Development Workflow](#development-workflow)
12. [Building & Deployment](#building--deployment)
13. [Testing & Quality](#testing--quality)
14. [Troubleshooting Guide](#troubleshooting-guide)
15. [FAQ & Best Practices](#faq--best-practices)
16. [Additional Resources](#additional-resources)

---

## Project Overview

### What is HRIS Mobile Application?

**HRIS Mobile Application** is a professionally-designed Flutter-based Human Resources Information System (HRIS) mobile client enabling secure employee access to HR data and profile management across Android, iOS, Web, Windows, macOS, and Linux platforms.

### Core Capabilities

| Capability | Description |
|------------|-------------|
| **Authentication** | Secure email/password login with JWT token-based session management |
| **Profile Management** | View and update personal, professional, and employment information |
| **Daily Time Records** | Track attendance, time-in/time-out records with monthly filtering |
| **Background Information** | Comprehensive employee records including family, education, work history |
| **Photo Management** | Upload, update, and view profile photographs with authentication |
| **Responsive Design** | Works seamlessly on phones, tablets, web, and desktop platforms |

### Key Benefits

- ✅ **Seamless Authentication**: Secure login with automatic 4-minute token refresh
- ✅ **Complete Profile Control**: Employees manage their own HR information
- ✅ **Cross-Platform**: Single codebase runs on 6+ platforms
- ✅ **Offline Capable**: Cached data accessible without internet
- ✅ **Enterprise Secure**: Bearer token authentication with secure storage
- ✅ **Real-time Sync**: Automatic data synchronization with backend

### Intended Users

- **Employees**: Access and manage personal HR information
- **HR Administrators**: Monitor employee data and system status
- **Authorized Personnel**: View relevant profile information based on permissions

---

## 5-Minute Quick Start

### Prerequisites Check

```bash
# Verify Flutter & Dart installed
flutter --version    # Requires 3.10.7+
dart --version        # Requires 3.10.7+

# View available devices
flutter devices
```

### Setup Steps

```bash
# 1. Clone the repository
git clone <repository-url>
cd mobile_application

# 2. Get all dependencies
flutter pub get

# 3. Verify setup
flutter doctor
```

### Configure Backend

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://your-backend-url.com:8082';
```

### Run the Application

```bash
# On default device
flutter run

# Specify device
flutter run -d <device_id>

# With verbose output
flutter run -v
```

✅ **Done!** App should open to the Login screen. Use your credentials to log in.

---

## Technology Stack

### Core Framework

| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.10.7+ | Cross-platform mobile framework |
| **Dart** | 3.10.7+ | Programming language |
| **Material Design** | 3.0 | UI design system |

### Supported Platforms

| Platform | Min Version | Status |
|----------|-------------|--------|
| Android | API 21 (5.0) | ✅ Fully Supported |
| iOS | 12.0+ | ✅ Fully Supported |
| Web | Modern browsers | ✅ Fully Supported |
| Windows | 10+ | ✅ Fully Supported |
| macOS | 10.11+ | ✅ Fully Supported |
| Linux | Ubuntu 16.04+ | ✅ Fully Supported |

### Core Dependencies

- **`http`** (^1.1.0) - REST API HTTP client
- **`shared_preferences`** (^2.5.4) - Persistent key-value storage
- **`image_picker`** (^1.2.1) - Select images from camera/gallery
- **`cupertino_icons`** (^1.0.8) - iOS-style icons
- **`flutter_launcher_icons`** (^0.14.4) - App icon generation
- **`flutter_lints`** (^6.0.0) - Code quality and style rules

### Backend Requirements

- **API Server**: REST API on HTTP (port 8082)
- **Authentication**: JWT tokens in Bearer format
- **Data Format**: JSON request/response
- **CORS**: Enabled for mobile requests

---

## Project Structure

### Complete Directory Layout

```
mobile_application/
│
├── 📁 lib/                          # Dart source code
│   ├── main.dart                    # Application entry point
│   │
│   ├── 📁 config/
│   │   └── api_config.dart          # Backend URL & API configuration
│   │
│   ├── 📁 services/                 # Business logic layer
│   │   ├── auth_service.dart        # Authentication & login
│   │   ├── user_service.dart        # User profile management
│   │   ├── token_manager.dart       # JWT token lifecycle
│   │   └── authenticated_photo.dart # Photo upload/download
│   │
│   ├── 📁 pages/                    # Full-screen UI pages
│   │   ├── login_page.dart          # Login & authentication
│   │   ├── homepage.dart            # Dashboard/home screen
│   │   ├── dtr_page.dart            # Daily time records
│   │   ├── about.dart               # About page
│   │   ├── navigation.dart          # Bottom navigation controller
│   │   │
│   │   └── 📁 UserCredentials/      # Employee information pages
│   │       ├── user_details.dart          # Profile overview
│   │       ├── family_background.dart     # Family members
│   │       ├── education_background.dart  # Education history
│   │       ├── work_experience.dart       # Employment history
│   │       ├── voluntary_work.dart        # Volunteer activities
│   │       ├── learning_development.dart  # Training & development
│   │       ├── civil_service.dart         # Civil service info
│   │       ├── person_reference.dart      # Reference contacts
│   │       └── other_information.dart     # Additional details
│   │
│   └── 📁 widgets/                  # Reusable components
│       ├── routes.dart              # Named route definitions
│       └── splash.dart              # Splash/loading screen
│
├── 📁 android/                      # Android platform code
├── 📁 ios/                          # iOS platform code
├── 📁 web/                          # Web platform code
├── 📁 windows/                      # Windows platform code
├── 📁 macos/                        # macOS platform code
├── 📁 linux/                        # Linux platform code
│
├── 📁 assets/                       # Static resources
│   ├── images/
│   └── icon/
│
├── 📁 build/                        # Build output (git-ignored)
├── 📁 test/                         # Unit/widget tests
│
├── pubspec.yaml                     # Package dependencies
├── analysis_options.yaml            # Linting rules
├── codemagic.yaml                  # CI/CD configuration
├── README.md                        # Project overview
└── DOCUMENTATION.md                 # This file
```

---

## Features Overview

### 1. Secure Authentication
- Email/password login with backend validation
- JWT bearer token generation and storage
- Automatic token refresh every 4 minutes
- Secure credential storage with SharedPreferences
- Login error handling and user feedback

**Files**: `auth_service.dart`, `token_manager.dart`, `login_page.dart`

### 2. Profile Management
- View complete personal and professional information
- Edit and update profile details
- Cache user data for offline access
- Profile photo upload and download
- Comprehensive employee background tracking

**Files**: `user_service.dart`, `user_details.dart`

### 3. Daily Time Records (DTR)
- Display time-in and time-out records
- Filter by month and year
- View attendance history
- Real-time data refresh
- No-data and error state handling

**Files**: `dtr_page.dart`

### 4. Employee Background Management
Complete CRUD operations for:
- **Family Background** - Family member information
- **Education** - Educational qualifications
- **Work Experience** - Employment history
- **Voluntary Work** - Volunteer activities
- **Learning & Development** - Training records
- **Civil Service** - Civil service eligibility
- **Personal References** - Reference contacts
- **Other Information** - Additional details

**Files**: `lib/pages/UserCredentials/` (all background pages)

### 5. Responsive Navigation
- Bottom navigation bar with 3 main sections
- Persistent state management per tab
- Smart drawer navigation in profile section
- Material Design 3 responsive layout

**Files**: `navigation.dart`, `routes.dart`

### 6. Image Processing
- Upload profile photographs
- Download and cache profile images
- Select images from device storage or camera
- Authenticated image requests with bearer tokens

**Files**: `authenticated_photo.dart`

---

## Architecture & Design

### Architectural Pattern: Service-Oriented Architecture (SOA)

The application uses a **layered service-oriented architecture** with clear separation of concerns:

```
┌──────────────────────────────────────────┐
│    UI Layer (Pages & Widgets)            │
│  - StatefulWidget pages                  │
│  - Material Design 3                     │
│  - User interactions handled             │
└────────────────────┬─────────────────────┘
                     │ calls
┌────────────────────▼─────────────────────┐
│  Business Logic Layer (Services)         │
│  - AuthService                           │
│  - UserService                           │
│  - TokenManager                          │
│  - AuthenticatedPhoto                    │
└────────────────────┬─────────────────────┘
                     │ HTTP calls
┌────────────────────▼─────────────────────┐
│      Data Access Layer                   │
│  - http package                          │
│  - SharedPreferences                     │
│  - ImagePicker                           │
└────────────────────┬─────────────────────┘
                     │
┌────────────────────▼─────────────────────┐
│   Backend API (port 8082)                │
└──────────────────────────────────────────┘
```

### Design Patterns Used

#### 1. Singleton Pattern (TokenManager)
Ensures single global instance managing JWT tokens across the app.

**Benefits:**
- Single source of truth for token state
- Automatic refresh applies globally
- No token conflicts

#### 2. State Pattern (StatefulWidget)
Manages local widget state for pages requiring dynamic updates.

**Used in:**
- Login page (form, loading, errors)
- DTR page (filters, sorting)
- Profile pages (editing)
- Photo upload

#### 3. Factory Pattern
All service methods return consistent response format.

**Standard format:**
```dart
{'success': true, 'data': {...}}  // Success
{'success': false, 'error': 'msg'} // Error
```

#### 4. Observer Pattern
TokenManager notifies app when token expires.

---

## Core Services

### AuthService

**File**: `lib/services/auth_service.dart`

**Purpose**: Handle user login and authentication

#### Method: login()

```dart
Future<Map<String, dynamic>> login(String email, String password)
```

**What it does:**
1. Sends POST to `/auth/login`
2. Validates credentials
3. Returns token and employee data
4. Initializes TokenManager with credentials
5. Starts auto-refresh cycle

**Returns:**
```dart
{
  'success': true,
  'data': {
    'token': 'eyJhbGciOiJIUzI1NiIs...',
    'employee': {
      'id': 'EMP001',
      'name': 'John Doe',
      'email': 'john@example.com'
    }
  }
}
```

---

### TokenManager

**File**: `lib/services/token_manager.dart`

**Pattern**: Singleton

**Purpose**: Manage JWT token lifecycle and automatic refresh

#### Key Features

- Stores token after successful login
- Stores credentials for silent refresh
- Refreshes token automatically every 4 minutes
- Handles expiration gracefully
- Notifies app on token failure

#### Token Lifecycle

```
Login → Token received → Stored
  ↓
4-minute timer starts
  ↓
[After 4 minutes]
Silent re-login via /auth/login
  ↓
New token received → Timer resets
  ↓
[Repeat while app running]
  ↓
If refresh fails → onTokenExpired callback
  ↓
Force navigate to login
```

---

### UserService

**File**: `lib/services/user_service.dart`

**Purpose**: Manage user profiles and employee background information

#### Profile Methods

```dart
// Get user profile
Future<Map<String, dynamic>> getUserDetails(String token)

// Update profile
Future<Map<String, dynamic>> updatePersonalInformation(
  String token, String employeeId, Map<String, dynamic> data)
```

#### Family Background Methods

```dart
Future<Map<String, dynamic>> getAllFamily(String token, String employeeId)
Future<Map<String, dynamic>> addFamily(String token, String employeeId, Map data)
Future<Map<String, dynamic>> updateFamily(String token, String familyId, Map data)
Future<Map<String, dynamic>> deleteFamily(String token, String familyId)
```

#### Similar Methods Available For:
- Education: `getAllEducation()`, `addEducation()`, `updateEducation()`, `deleteEducation()`
- Work Experience: `getAllWorkExperience()`, `addWorkExperience()`, etc.
- Voluntary Work: `getAllVoluntaryWork()`, `addVoluntaryWork()`, etc.
- Learning & Development: `getAllLearningDev()`, `addLearningDev()`, etc.
- Civil Service: `getAllCivilService()`, `addCivilService()`, etc.
- Personal References: `getAllPersonReference()`, `addPersonReference()`, etc.

#### Data Caching

- Caches user data per employeeId
- Returns cached data if available
- Fetches fresh data when needed
- Enables offline access to previously loaded data

---

### AuthenticatedPhoto

**File**: `lib/services/authenticated_photo.dart`

**Purpose**: Handle profile photo upload/download with bearer token authentication

#### Key Methods

```dart
Future<Map<String, dynamic>> uploadPhoto(
  String token, String employeeId, File imageFile)

Future<void> _loadImage()   // Load image from server
Future<void> _pickAndUploadImage(ImageSource source) // Pick and upload
```

#### Features

- Display employee profile photos
- Authenticated image requests (requires bearer token)
- Photo upload via image picker
- Fallback avatar with initials
- Error handling with user messages
- Circular avatar design

---

## Pages & Screens

### Login Page
- **File**: `lib/pages/login_page.dart`
- Email and password input fields with validation
- Show/hide password toggle
- Loading indicator during authentication
- Error message display
- Auto-navigation to home after successful login

**User Flow**: Enter credentials → Validate → Authenticate → Initialize TokenManager → Navigate home

### Home Page (Dashboard)
- **File**: `lib/pages/homepage.dart`
- Welcome message with user greeting
- Feature cards/buttons
- Quick access links
- Dashboard statistics

### Daily Time Record (DTR) Page
- **File**: `lib/pages/dtr_page.dart`
- Month/Year filters
- Time-in/Time-out table
- Filter and search functionality
- No-data state handling
- API: `GET /adminuser/api/v1/dtr/{userId}`

### User Details Pages
- **File**: `lib/pages/UserCredentials/user_details.dart` (hub)
- Profile overview with photo
- Edit personal information button
- Navigation to all background detail pages
- Displays current information with edit options

### Background Information Pages

All follow the same pattern: **List → Add → Edit → Delete**

- **Family Background** (`family_background.dart`)
- **Education** (`education_background.dart`)
- **Work Experience** (`work_experience.dart`)
- **Voluntary Work** (`voluntary_work.dart`)
- **Learning & Development** (`learning_development.dart`)
- **Civil Service** (`civil_service.dart`)
- **Personal References** (`person_reference.dart`)
- **Other Information** (`other_information.dart`)

### Navigation Page
- **File**: `lib/pages/navigation.dart`
- Bottom navigation with 3 tabs
- Tab structure:
  - Home → HomePageContent
  - Profile → UserDetailsPageContent
  - About → AboutPage
- State maintained per tab
- Smart profile section navigation

### About Page
- **File**: `lib/pages/about.dart`
- Application information
- Version details
- Features overview
- Company information
- Support contact details
- Material 3 design with scrollable content

### Splash Screen
- **File**: `lib/widgets/splash.dart`
- Company logo centered
- 5-second delay before navigation
- Smooth transition to LoginPage
- Responsive design

---

## API Integration

### Base Configuration

**File**: `lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.79.55:8082';
}
```

### Authentication Endpoints

#### POST /auth/login

```json
Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "employee": {
    "id": "EMP001",
    "name": "John Doe",
    "email": "john@example.com",
    "department": "HR"
  }
}
```

### Profile Endpoints

#### GET /adminuser/get-profile
Fetch authenticated user's complete profile.

**Headers**: `Authorization: Bearer {token}`

#### POST /adminuser/update-employee/{employeeId}
Update employee profile information.

#### GET /employee/image/{photoId}
Download employee photo (requires bearer token).

#### POST /adminuser/update-employee-photo/{employeeId}
Upload new profile photo (multipart/form-data).

### Family Background Endpoints

- `GET /adminuser/family/{employeeId}`
- `POST /adminuser/family/add-family/{employeeId}`
- `POST /adminuser/family/update-family/{familyId}`
- `DELETE /adminuser/family/delete-family/{familyId}`

### Education Endpoints

- `GET /adminuser/education/{employeeId}`
- `POST /adminuser/education/add-education/{employeeId}`
- `POST /adminuser/education/update-education/{educationId}`
- `DELETE /adminuser/education/delete-education/{educationId}`

### Work Experience Endpoints

- `GET /adminuser/work-experience/{employeeId}`
- `POST /adminuser/work-experience/add-work-experience/{employeeId}`
- `POST /adminuser/work-experience/update-work-experience/{experienceId}`
- `DELETE /adminuser/work-experience/delete-work-experience/{experienceId}`

### Voluntary Work, Learning & Development, Civil Service, Personal References

All follow same pattern with respective endpoints.

### Daily Time Record

```
GET /adminuser/api/v1/dtr/{userId}
```

Response: Array of DTR records with date, time-in, time-out, status.

### Standard Response Format

**Success**:
```json
{
  "success": true,
  "data": {...},
  "statusCode": 200
}
```

**Error**:
```json
{
  "error": "Error description",
  "statusCode": 400
}
```

### Request Headers (All Authenticated Requests)

```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK | Success |
| 201 | Created | Resource created |
| 400 | Bad Request | Validate form |
| 401 | Unauthorized | Refresh token or login |
| 403 | Forbidden | No permission |
| 404 | Not Found | Show not found message |
| 500 | Server Error | Show error message |

---

## Setup & Installation

### Prerequisites

```bash
flutter --version  # Requires 3.10.7+
dart --version     # Requires 3.10.7+
flutter doctor     # Verify all requirements
```

**System Requirements**:
- Windows 10+, macOS 10.11+, or Linux Ubuntu 16.04+
- 2GB RAM minimum
- 1.5GB free disk space
- Git for version control

### Installation Steps

#### 1. Clone Repository

```bash
git clone https://github.com/organization/hris-mobile.git
cd mobile_application
```

#### 2. Install Dependencies

```bash
flutter pub get
flutter pub upgrade  # Optional
```

#### 3. Configure Backend URL

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://your-backend-url.com:8082';
```

#### 4. Run Application

```bash
flutter devices                      # List available devices
flutter run                          # Default device
flutter run -d <device_id>           # Specific device
flutter run --release                # Optimized release build
flutter run -v                       # Verbose output
```

### Emulator Setup

**Android**:
```bash
emulator -list-avds
emulator @emulator_name
```

**iOS**:
```bash
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
```

---

## Development Workflow

### Code Organization

```
lib/
├── config/          # Constants & configuration
├── services/        # Business logic
├── pages/           # Full screens
├── widgets/         # Reusable components
└── models/          # Data classes (if needed)
```

### Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Classes | PascalCase | `AuthService`, `LoginPage` |
| Methods | camelCase | `getUserDetails()` |
| Variables | camelCase | `isLoading`, `userName` |
| Constants | camelCase | `maxRetries` |
| Private | _camelCase | `_token`, `_loadData()` |
| Files | snake_case | `auth_service.dart` |

### Creating a New Service

```dart
// lib/services/new_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_manager.dart';

class NewService {
  Future<Map<String, dynamic>> fetchData(String token, String id) async {
    print('🚀 [NewService] Fetching data for ID: $id');
    
    try {
      final currentToken = TokenManager().token ?? token;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/data/$id'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ [NewService] Success');
        return {'success': true, 'data': jsonDecode(response.body)};
      }

      print('❌ [NewService] Error: ${response.statusCode}');
      return {'success': false, 'error': 'Failed to fetch data'};
    } catch (e) {
      print('💥 [NewService] Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
```

### Creating a New Page

```dart
// lib/pages/new_page.dart
import 'package:flutter/material.dart';
import '../services/new_service.dart';

class NewPage extends StatefulWidget {
  final String token;

  const NewPage({Key? key, required this.token}) : super(key: key);

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  late NewService _service;
  bool _isLoading = false;
  String? _error;
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _service = NewService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _service.fetchData(widget.token, 'id');

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _data = result['data'];
        } else {
          _error = result['error'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Page')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Text(_data.toString()),
    );
  }
}
```

### Debugging & Logging

**Print Emoji Standards**:
- 🚀 Action starting
- 📤 Request sent
- 📥 Response received
- ✅ Success
- ❌ Error
- 💥 Exception
- ⏰ Timer/scheduling
- 🔐 Security

**Enable Verbose Logging**:
```bash
flutter run -v
```

### Hot Reload Development

```bash
flutter run
# Press 'r' to reload
# Press 'R' for hot restart
# Press 'q' to quit
```

**When to use hot restart**:
- Changes to main() or initState()
- Changes to const values
- State needs reset

---

## Building & Deployment

### Android Build

#### Build APK (Local Testing)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Build AAB (Play Store)

```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### Split APK by Platform

```bash
flutter build apk --split-per-abi
```

### iOS Build

#### Build for iPhone

```bash
flutter build ios --release
```

#### Build for App Store

```bash
flutter build ios --release --export-method=app-store
```

### Web Build

```bash
flutter build web --release
```

Output: `build/web/`

### Create Signing Keystore (One-Time)

```bash
keytool -genkey -v -keystore ~/my-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### Configure Gradle Signing

Edit `android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        release {
            keyAlias = "my-key-alias"
            keyPassword = "your_password"
            storeFile = file("path/to/my-keystore.jks")
            storePassword = "your_password"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
        }
    }
}
```

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update Android versionCode/versionName
- [ ] Update iOS version info.plist
- [ ] Update API base URL for production
- [ ] Run `flutter test` successfully
- [ ] Run `flutter analyze` with no errors
- [ ] Test on physical devices
- [ ] Update CHANGELOG.md
- [ ] Sign all binaries
- [ ] Create git tag

---

## Testing & Quality

### Run Unit Tests

```bash
flutter test                 # All tests
flutter test test/widget_test.dart  # Specific test
flutter test -v              # Verbose output
```

### Code Analysis

```bash
flutter analyze               # Analyze for errors
dart format lib/              # Format code
flutter clean && flutter pub get  # Clean build
```

### Performance Profiling

```bash
flutter run --profile        # Profile build
# Or use DevTools: devtools
```

### Build Size Analysis

```bash
flutter build apk --analyze-size
```

---

## Troubleshooting Guide

### Login Issues

**"Network error" or "Failed to connect"**:
- Verify backend URL in `api_config.dart`
- Check network connectivity
- Ensure backend server is running
- Test with: `curl -X POST http://backend:8082/auth/login ...`

**"Invalid credentials"**:
- Verify email and password are correct
- Check with backend team
- Try resetting password through HRIS portal

**"Token expired despite auto-refresh"**:
- Check TokenManager initialization
- Verify refresh endpoint is working
- Check stored credentials validity

### Profile & Data Issues

**"Profile fails to load"**:
- Check API endpoint `/adminuser/get-profile` exists
- Verify token is valid
- Check backend response format
- Enable verbose logging: `flutter run -v`

**"Photo not loading"**:
- Verify photo endpoint returns correct format
- Check token is not expired
- Photo might not exist yet
- Try uploading new photo

**"Cannot add/edit records"**:
- Check form validation (all required fields filled)
- Verify endpoint exists: `/adminuser/family/add-family/{employeeId}`
- Check employee ID is correct
- Test endpoint directly with curl

### Build Issues

**"Build failed with SDK version error"**:
```bash
flutter upgrade
flutter pub get
flutter clean
flutter run
```

**"APK is too large"**:
```bash
flutter build appbundle  # Smaller alternative
flutter build apk --split-per-abi  # Split by architecture
```

**"Device not detected"**:
```bash
flutter devices          # List devices
flutter run -d <device_id>  # Specify device
# For Android: adb devices
# For iOS: Xcode trust device
```

### Runtime Errors

**"MissingPluginException"**:
```bash
flutter clean && flutter pub get && flutter run
# Or press 'R' for hot restart
```

**"Null safety errors"**:
```dart
// Add null checks
final token = TokenManager().token;
if (token != null) { /* use token */ }

// Or use coalescing
final token = TokenManager().token ?? '';
```

### Performance Issues

**App is slow**:
- Reduce loaded data
- Implement pagination
- Clear caches periodically
- Profile with DevTools

---

## FAQ & Best Practices

### Frequently Asked Questions

**Q: How do I change the backend URL?**
A: Edit `lib/config/api_config.dart`: `static const String baseUrl = 'http://your-url:8082';`

**Q: How often does token refresh?**
A: Every 4 minutes (240 seconds). Backend token expires after 5 minutes.

**Q: Can I access offline?**
A: Partially. Cached data is accessible offline, but new data requires internet.

**Q: Where are credentials stored?**
A: Securely in SharedPreferences (encrypted on iOS, Android 6+).

**Q: How do I reset my password?**
A: Contact HR or administrator through HRIS portal.

**Q: How do I report a bug?**
A: Provide: 1) Device type & OS, 2) Error message & stacktrace, 3) Steps to reproduce, 4) Screenshot/video

### Best Practices

#### Security ✅

- Always use HTTPS in production
- Never hardcode credentials
- Store tokens securely (SharedPreferences handles this)
- Validate all user input
- Consider certificate pinning for production

#### Performance ✅

- Use `const` constructors
- Implement pagination for large lists
- Cache data appropriately
- Lazy load images and data
- Avoid rebuilding entire pages

#### Code Quality ✅

- Follow naming conventions
- Write meaningful comments
- Use proper error handling
- Test before committing
- Keep functions focused (<200 lines)

#### UX/UI ✅

- Show loading indicators
- Provide clear error messages
- Make buttons easily tappable (>48dp)
- Test on multiple devices
- Don't block UI on slow operations

---

## Additional Resources

### Official Documentation

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Pub.dev](https://pub.dev)

### Related Packages

- [http](https://pub.dev/packages/http)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [image_picker](https://pub.dev/packages/image_picker)

### Project Documentation Files

- [README.md](README.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [API_REFERENCE.md](API_REFERENCE.md)
- [QUICKSTART.md](QUICKSTART.md)
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

---

## Support & Contribution

### Getting Help

1. Check this documentation
2. Search existing issues
3. Create detailed bug report with:
   - Device type & OS version
   - Error message & stacktrace
   - Steps to reproduce
   - Screenshots/videos

### Contributing

1. Fork repository
2. Create feature branch: `git checkout -b feature/improvement`
3. Make changes and test
4. Commit: `git commit -am 'Add improvement'`
5. Push: `git push origin feature/improvement`
6. Submit pull request

---

## Version Information

**Current Version**: 1.0.0  
**Release Date**: March 2, 2026  
**Status**: Production Ready  
**Last Updated**: March 2, 2026  
**Maintained By**: Development Team

---

## License

This HRIS Mobile Application is proprietary software. All rights reserved. Unauthorized access or use is strictly prohibited.

---

**End of Documentation**

For questions or clarifications, contact the Development Team.

