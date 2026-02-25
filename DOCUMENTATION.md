# HRIS Mobile Application - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Features](#features)
5. [Architecture](#architecture)
6. [Core Services](#core-services)
7. [Pages & Screens](#pages--screens)
8. [API Configuration](#api-configuration)
9. [Dependencies](#dependencies)
10. [Setup & Installation](#setup--installation)
11. [Development Guide](#development-guide)
12. [Building & Deployment](#building--deployment)
13. [Troubleshooting](#troubleshooting)

---

## Project Overview

**HRIS Mobile Application** is a Flutter-based Human Resources Information System (HRIS) mobile application designed for Android and iOS platforms. The application enables employees to:

- **Authenticate** securely with their credentials
- **View** personal profiles and employment details
- **Manage** Daily Time Records (DTR)
- **Update** personal and professional information
- **Track** employee background information (family, education, work experience, etc.)

### Key Objectives
- Provide seamless employee access to HR data
- Facilitate remote profile management
- Support secure token-based authentication
- Enable real-time data synchronization with backend

### Target Users
- Employees in organizations using the HRIS backend system
- HR administrators managing employee information
- Any authorized personnel accessing their profiles

---

## Technology Stack

### Framework & Language
- **Framework**: Flutter 3.x
- **Language**: Dart 3.10.7+
- **Target Platforms**: Android (API 21+), iOS (12.0+), Web, Windows, macOS, Linux

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | Latest | Core Flutter framework |
| `dart` | ^3.10.7 | Dart language SDK |
| `http` | ^1.1.0 | HTTP client for API calls |
| `shared_preferences` | ^2.5.4 | Local storage for persistent data |
| `image_picker` | ^1.2.1 | Select and upload images |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |
| `flutter_lints` | ^6.0.0 | Code quality analysis |

---

## Project Structure

```
mobile_application/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── config/
│   │   └── api_config.dart         # API endpoints configuration
│   ├── services/
│   │   ├── auth_service.dart       # Authentication logic
│   │   ├── user_service.dart       # User profile management
│   │   ├── token_manager.dart      # Token refresh & management
│   │   └── authenticated_photo.dart # Photo upload service
│   ├── pages/
│   │   ├── login_page.dart         # Login screen
│   │   ├── homepage.dart           # Home dashboard
│   │   ├── dtr_page.dart           # Daily Time Record
│   │   ├── about.dart              # About page
│   │   ├── navigation.dart         # Bottom navigation
│   │   └── UserCredentials/        # User detail pages
│   │       ├── user_details.dart
│   │       ├── family_background.dart
│   │       ├── education_background.dart
│   │       ├── work_experience.dart
│   │       ├── voluntary_work.dart
│   │       ├── learning_development.dart
│   │       ├── civil_service.dart
│   │       ├── person_reference.dart
│   │       └── other_information.dart
│   └── widgets/
│       ├── routes.dart             # Route definitions
│       └── splash.dart             # Splash screen
├── android/                        # Android-specific code
├── ios/                           # iOS-specific code
├── web/                           # Web platform code
├── windows/                       # Windows platform code
├── macos/                         # macOS platform code
├── linux/                         # Linux platform code
├── assets/                        # Images, icons, and static files
│   ├── images/
│   └── icon/
├── pubspec.yaml                   # Package dependencies
├── analysis_options.yaml          # Linting rules
├── codemagic.yaml                # CI/CD configuration
└── README.md                      # Project readme

```

---

## Features

### 1. **User Authentication**
- Secure login with email and password
- JWT token generation and validation
- Automatic token refresh every 4 minutes (before 5-minute expiration)
- Session management with persistent token storage
- Login error handling and validation

**Implemented in**: `auth_service.dart`, `token_manager.dart`

### 2. **User Profile Management**
- View personal and professional information
- Update profile details (name, contact info, etc.)
- Photo upload and management
- Profile data caching for offline access

**Implemented in**: `user_service.dart`, `authenticated_photo.dart`

### 3. **Daily Time Record (DTR)**
- View time-in and time-out records
- Filter DTR by month and year
- Display attendance history
- Real-time data synchronization

**Implemented in**: `dtr_page.dart`

### 4. **Employee Background Information**
Comprehensive modules for managing:
- **Family Background**: Add/edit/delete family member information
- **Education**: Track educational qualifications and institutions
- **Work Experience**: Maintain professional work history
- **Voluntary Work**: Document volunteer activities
- **Learning & Development**: Track training and development activities
- **Civil Service**: Manage civil service eligibility information
- **Personal References**: Store reference contact information
- **Other Information**: Additional employee details

**Implemented in**: `UserCredentials/` folder

### 5. **Navigation & UI**
- Bottom navigation bar for easy screen access
- Splash screen with 5-second delay
- Responsive material design
- Material 3 design system

**Implemented in**: `navigation.dart`, `splash.dart`

### 6. **Security Features**
- Bearer token authentication in API headers
- Automatic token refresh mechanism
- Secure credential storage
- Session timeout handling

---

## Architecture

### Architecture Pattern: Service-Oriented Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────┐
│         UI Layer (Pages)        │
│  - login_page.dart              │
│  - homepage.dart                │
│  - user_details.dart, etc.      │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     Business Logic Layer        │
│       (Services)                │
│  - AuthService                  │
│  - UserService                  │
│  - TokenManager                 │
│  - AuthenticatedPhoto           │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     Data Access Layer           │
│  - HTTP Client (http package)   │
│  - SharedPreferences            │
│  - ImagePicker                  │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│      API Configuration          │
│  - ApiConfig                    │
│  - Endpoints                    │
│  - Base URL                     │
└─────────────────────────────────┘
```

### Data Flow

1. **User Input** → UI Layer (Pages)
2. **Service Call** → Business Logic Layer (Services)
3. **API Request** → Data Access Layer
4. **API Response** → Parse & Cache
5. **Update UI** → Re-render with new data

### State Management

The application uses:
- **StatefulWidget**: For pages requiring state updates
- **Local Variables**: For page-level state
- **Token Manager Singleton**: For global token state
- **Caching** in UserService for profile data

---

## Core Services

### 1. **AuthService** (`auth_service.dart`)

**Purpose**: Handles user authentication and login operations

**Key Methods**:
```dart
Future<Map<String, dynamic>> login(String email, String password)
```

**Features**:
- Sends POST request to `/auth/login` endpoint
- Validates credentials
- Returns authentication token and user data
- Automatically initializes TokenManager with credentials
- Comprehensive logging for debugging

**Usage**:
```dart
final authService = AuthService();
final result = await authService.login(email, password);
if (result['success']) {
  // Login successful
  var token = result['data']['token'];
  var user = result['data']['employee'];
}
```

---

### 2. **TokenManager** (`token_manager.dart`)

**Purpose**: Manages JWT token lifecycle and automatic refresh

**Architecture**: Singleton pattern for global access

**Key Features**:
- Stores token after successful login
- Stores user credentials for silent refresh
- Automatically refreshes token every 4 minutes
- Handles token expiration gracefully
- Notifies app when token is expired

**Key Methods**:
```dart
void initialize(String token, {required String email, required String password, Function? onTokenExpired})
Future<bool> refreshToken()
String? get token
```

**Flow**:
```
Initial Login
    ↓
Token received + Credentials stored
    ↓
4-minute timer starts
    ↓
Timer triggers → Silent re-login via /auth/login
    ↓
New token received → Continue operations
    ↓
If refresh fails → Call onTokenExpired callback
```

**Usage**:
```dart
// Access current token
final token = TokenManager().token;

// Initialize (done automatically by AuthService)
TokenManager().initialize(token, email: email, password: password);
```

---

### 3. **UserService** (`user_service.dart`)

**Purpose**: Manages user profile data and personal information

**Key Methods**:

#### Get User Details
```dart
Future<Map<String, dynamic>> getUserDetails(String token)
```
- Fetches user profile from `/adminuser/get-profile`
- Caches result for offline access
- Returns user data including name, email, contact info

#### Update Personal Information
```dart
Future<Map<String, dynamic>> updatePersonalInformation(
  String token,
  String employeeId,
  Map<String, dynamic> personalData,
)
```
- Updates user profile at `/adminuser/update-employee/{id}`
- Merges new data with existing cached data
- Filters out null/empty values for clean requests
- Returns success/failure status

#### Family Background Management
```dart
Future<Map<String, dynamic>> getAllFamily(String token, String employeeId)
Future<Map<String, dynamic>> addFamily(String token, String employeeId, Map<String, dynamic> familyData)
Future<Map<String, dynamic>> updateFamily(String token, String familyId, Map<String, dynamic> familyData)
Future<Map<String, dynamic>> deleteFamily(String token, String familyId)
```

#### Education Management
```dart
Future<Map<String, dynamic>> getAllEducation(String token, String employeeId)
Future<Map<String, dynamic>> addEducation(String token, String employeeId, Map<String, dynamic> educationData)
Future<Map<String, dynamic>> updateEducation(String token, String educationId, Map<String, dynamic> educationData)
Future<Map<String, dynamic>> deleteEducation(String token, String educationId)
```

**Similar methods available for**:
- Work Experience
- Voluntary Work
- Learning & Development
- Civil Service Eligibility
- Personal References
- Other Information

**Data Caching**:
- Caches current user data to minimize API calls
- Validates cache against current employee ID
- Allows offline access to previously loaded data

---

### 4. **AuthenticatedProfilePhoto** (`authenticated_photo.dart`)

**Purpose**: Manages profile photo upload and display with authentication

**Key Features**:
- Displays employee profile photos
- Handles authenticated image requests
- Photo upload functionality
- Image picker integration
- Error handling with fallback UI

**Key Methods**:
```dart
Future<void> _loadImage() // Load image from server
Future<void> _pickAndUploadImage(ImageSource source) // Pick and upload
Future<Map<String, dynamic>> uploadPhoto(String token, String employeeId, File imageFile)
```

**Usage**:
```dart
AuthenticatedProfilePhoto(
  photoUrl: photoUrl,
  baseUrl: baseUrl,
  userName: userName,
  token: token,
  employeeId: employeeId,
  onPhotoUpdated: () { /* callback */ },
)
```

---

## Pages & Screens

### 1. **Login Page** (`login_page.dart`)

**Screen Layout**:
- Email input field with validation
- Password input field with show/hide toggle
- Login button
- Loading indicator during authentication
- Error message display

**Features**:
- Form validation (email format, password required)
- Secure password entry
- Loading state management
- Error handling with user-friendly messages
- Automatic navigation to home after login

**Key Logic**:
1. User enters email and password
2. Form validation occurs
3. AuthService.login() called
4. Token received and TokenManager initialized
5. User navigated to MainNavigation page
6. TokenManager starts automatic refresh cycle

---

### 2. **Home Page** (`homepage.dart`)

**Screen Layout**:
- AppBar with title
- Welcome message with icon
- Placeholder content area
- Card with additional information

**Purpose**: Dashboard and entry point for main app features

---

### 3. **Daily Time Record Page** (`dtr_page.dart`)

**Features**:
- Display time-in/time-out records
- Filter by month and year
- Calendar picker for easy selection
- Sortable records list
- No-data state handling

**API Endpoints Used**:
- GET `/adminuser/api/v1/dtr/{userId}` - Fetch DTR records

**UI Components**:
- Month/Year selector
- Records table with time information
- Loading indicators
- Error messages

---

### 4. **User Details Pages** (`UserCredentials/` folder)

#### Main User Details (`user_details.dart`)
- Central profile management hub
- Navigation to all detail pages
- Profile photo management
- Quick access to update forms

#### Family Background (`family_background.dart`)
- List of family members
- Add new family member
- Edit existing records
- Delete family members
- Form validation for all fields

#### Education Background (`education_background.dart`)
- Educational qualifications list
- Add education history
- Update education records
- Delete education entries
- School/University information management

#### Work Experience (`work_experience.dart`)
- Employment history
- Company information
- Position and tenure tracking
- Add/edit/delete work records

#### Voluntary Work (`voluntary_work.dart`)
- Volunteer service history
- Organization information
- Activity descriptions
- Duration tracking

#### Learning & Development (`learning_development.dart`)
- Training and development records
- Course information
- Certificates and completion dates
- Skill development tracking

#### Civil Service (`civil_service.dart`)
- Civil service eligibility status
- Examination information
- License and certification details

#### Personal References (`person_reference.dart`)
- Reference contact information
- Name and organization
- Contact details
- Relationship information

#### Other Information (`other_information.dart`)
- Additional employee details
- Miscellaneous information
- Special notes

---

### 5. **Navigation Page** (`navigation.dart`)

**Architecture**: MainNavigation StatefulWidget with bottom navigation

**Bottom Navigation Tabs**:
1. **Home** (icon: home) → HomePageContent
2. **Profile** (icon: person/menu) → UserDetailsPageContent
3. **About** (icon: info) → AboutPage

**Smart Navigation**:
- Profile tab shows "person" icon first tap
- Clicking again shows menu icon and opens drawer
- Switching tabs resets profile navigation state
- Each page maintains separate state

---

### 6. **About Page** (`about.dart`)

**Content**:
- Application information
- Version details
- Features overview
- Company information
- Support contact details

**Design**: Material 3 with custom color scheme

---

### 7. **Splash Screen** (`splash.dart`)

**Features**:
- Company logo display
- 5-second delay before navigation
- Responsive design
- Automatic navigation to login page

---

## API Configuration

### File: `api_config.dart`

**Base URL Configuration**:
```dart
static const String baseUrl = 'http://192.168.79.55:8082';
```

**Alternative URLs (commented)**:
- Local: `http://localhost:8082`
- Emulator: `http://10.0.2.2:8082`

### API Endpoints

#### Authentication
```
POST /auth/login
```
Request body:
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

#### User Profile
```
GET /adminuser/get-profile
POST /adminuser/update-employee/{employeeId}
GET /employee/image/{photoId}
POST /adminuser/update-employee-photo/{employeeId}
```

#### Family Background
```
GET /adminuser/family/get-all-family/{employeeId}
POST /adminuser/family/add-family/{employeeId}
POST /adminuser/family/update-family/{familyId}
DELETE /adminuser/family/delete-family/{familyId}
```

#### Education
```
GET /adminuser/education/get-all-education/{employeeId}
POST /adminuser/education/add-education/{employeeId}
POST /adminuser/education/update-education/{educationId}
DELETE /adminuser/education/delete-education/{educationId}
```

#### Work Experience
```
GET /adminuser/work-experience/get-all-work-experience/{employeeId}
POST /adminuser/work-experience/add-work-experience/{employeeId}
POST /adminuser/work-experience/update-work-experience/{experienceId}
DELETE /adminuser/work-experience/delete-work-experience/{experienceId}
```

#### Voluntary Work
```
GET /adminuser/voluntary-work/get-all-voluntary-work/{employeeId}
POST /adminuser/voluntary-work/add-voluntary-work/{employeeId}
POST /adminuser/voluntary-work/update-voluntary-work/{voluntaryId}
DELETE /adminuser/voluntary-work/delete-voluntary-work/{voluntaryId}
```

#### Learning & Development
```
GET /adminuser/learn-dev/get-all-learn-dev/{employeeId}
POST /adminuser/learn-dev/add-learn-dev/{employeeId}
POST /adminuser/learn-dev/update-learn-dev/{learningId}
DELETE /adminuser/learn-dev/delete-learn-dev/{learningId}
```

#### Daily Time Record
```
GET /adminuser/api/v1/dtr/{userId}
```

### Authentication Headers

All authenticated requests require:
```
Authorization: Bearer {token}
Content-Type: application/json
```

### Response Format

Standard success response:
```json
{
  "success": true,
  "data": { /* response data */ }
}
```

Standard error response:
```json
{
  "error": "Error message",
  "statusCode": 400
}
```

---

## Dependencies

### Runtime Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| flutter | Latest | Core framework |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| shared_preferences | ^2.5.4 | Local data persistence |
| http | ^1.1.0 | HTTP requests |
| image_picker | ^1.2.1 | Image selection |
| flutter_launcher_icons | ^0.14.4 | App icon generation |

### Development Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| flutter_test | Latest | Unit testing framework |
| flutter_lints | ^6.0.0 | Code quality rules |

### Installation

Update all dependencies:
```bash
flutter pub get
```

Upgrade dependencies:
```bash
flutter pub upgrade
```

---

## Setup & Installation

### Prerequisites

- **Flutter**: Version 3.10.7 or higher
- **Dart**: Version 3.10.7 or higher
- **Android Studio**: For Android development (API 21+)
- **Xcode**: For iOS development (iOS 12.0+)
- **Git**: For version control

### Installation Steps

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd mobile_application
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Configure API Base URL

Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'your_backend_url';
```

#### 4. Generate App Icons
```bash
flutter pub run flutter_launcher_icons
```

#### 5. Run the Application

**Android**:
```bash
flutter run -d android
```

**iOS**:
```bash
flutter run -d ios
```

**Web**:
```bash
flutter run -d web
```

**Windows**:
```bash
flutter run -d windows
```

---

## Development Guide

### Code Structure Best Practices

#### 1. File Organization
- **Services**: Business logic and API calls
- **Pages**: Full-screen widgets
- **Widgets**: Reusable UI components
- **Config**: Configuration constants

#### 2. Naming Conventions
- **Classes**: PascalCase (e.g., `UserService`, `LoginPage`)
- **Methods**: camelCase (e.g., `getUserDetails()`)
- **Constants**: camelCase (e.g., `refreshInterval`)
- **Private members**: Prefix with underscore (e.g., `_token`)

#### 3. Error Handling Pattern
```dart
try {
  // API call or operation
} catch (e) {
  print('❌ [ServiceName] Error: $e');
  return {
    'success': false,
    'error': 'Error message',
  };
}
```

#### 4. Debugging with Print Statements
All service methods include descriptive print statements with emoji prefixes:
- 🚀 Action starting
- 📧 Data/credentials
- 📤 Request sent
- 📥 Response received
- ✅ Success
- ❌ Error
- 💥 Exception
- ⏰ Timer/scheduling
- 🔐 Security
- 👤 User info

### Adding New Features

#### Example: Adding a New Service

1. Create new file in `lib/services/`:
```dart
// lib/services/new_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_manager.dart';

class NewService {
  Future<Map<String, dynamic>> fetchData(String token) async {
    print('🚀 [NewService] Fetching data...');
    
    try {
      final currentToken = TokenManager().token ?? token;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/endpoint'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ [NewService] Success');
        return {'success': true, 'data': jsonDecode(response.body)};
      }
    } catch (e) {
      print('❌ [NewService] Error: $e');
    }
    return {'success': false};
  }
}
```

2. Add endpoint to `lib/config/api_config.dart`:
```dart
static const String newEndpoint = '/api/endpoint';
```

3. Use in your UI:
```dart
final service = NewService();
final result = await service.fetchData(token);
```

#### Example: Adding a New Page

1. Create new file in `lib/pages/`:
```dart
// lib/pages/new_page.dart
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
      body: Center(child: const Text('Page Content')),
    );
  }
}
```

2. Add route in `lib/widgets/routes.dart` (if needed):
```dart
static const String newPage = "/new_page";

static final routes = <String, WidgetBuilder>{
  // ... existing routes
  newPage: (context) => const NewPage(token: '', baseUrl: ''),
};
```

### Testing

#### Run Tests
```bash
flutter test
```

#### Run Specific Test
```bash
flutter test test/widget_test.dart
```

---

## Building & Deployment

### Android Build

#### Build APK
```bash
flutter build apk --split-per-abi
```

Outputs:
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

#### Build AAB (App Bundle)
```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### Sign APK
1. Create keystore:
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. Update `android/app/build.gradle.kts`:
```kotlin
android {
    signingConfigs {
        release {
            keyAlias = "key"
            keyPassword = "password"
            storeFile = file("path/to/key.jks")
            storePassword = "password"
        }
    }
}
```

3. Build signed APK:
```bash
flutter build apk --release
```

### iOS Build

#### Build for Release
```bash
flutter build ios --release
```

#### Archive for App Store
```bash
flutter build ios --release --export-method=app-store
```

#### Build for Ad Hoc (Enterprise Distribution)
```bash
flutter build ios --release --export-method=ad-hoc
```

### Web Build

```bash
flutter build web --release
```

Output: `build/web/`

### Windows Build

```bash
flutter build windows --release
```

### macOS Build

```bash
flutter build macos --release
```

### CI/CD with CodeMagic

The project includes `codemagic.yaml` for automated builds:

```bash
# Trigger build on push
codemagic build start
```

---

## Troubleshooting

### Common Issues & Solutions

#### 1. **Login Not Working**

**Error**: "Network error" or "Failed to connect"

**Solutions**:
- Verify backend URL in `api_config.dart`
- Check network connectivity
- Ensure backend server is running
- Verify API endpoint is correct

#### 2. **Token Expired Despite Auto-Refresh**

**Symptoms**: Logged out unexpectedly

**Solutions**:
```dart
// Clear token and re-login
TokenManager()._token = null;
// Navigate to login
Navigator.pushReplacementNamed(context, MyRoutes.loginPage);
```

#### 3. **Image Upload Fails**

**Symptoms**: "Failed to upload photo"

**Solutions**:
- Check image picker has proper permissions
- Verify image size (keep under 5MB)
- Check API endpoint `/adminuser/update-employee-photo/` is correct
- Verify employee ID is correct

#### 4. **Build Errors**

**Error**: "Build failed with SDK version"

**Solutions**:
```bash
# Update Flutter
flutter upgrade

# Update packages
flutter pub get

# Clean build
flutter clean
flutter pub get
flutter run
```

#### 5. **Device Not Detected**

```bash
# List connected devices
flutter devices

# Use specific device
flutter run -d <device_id>
```

#### 6. **DTR Data Not Loading**

**Check**:
- User ID is correct
- Token is valid
- API endpoint `/adminuser/api/v1/dtr/{userId}` is responding
- Network connectivity

#### 7. **Profile Photo Not Displaying**

**Solutions**:
```dart
// Check image URL format
print('Image URL: $photoUrl');

// Verify authentication token
final token = TokenManager().token;
print('Token: $token');

// Check response status
// 401 = Unauthorized
// 404 = Image not found
```

### Debug Logging

Enable detailed logging by checking console output:

```bash
flutter run -v
```

All services print detailed logs with emoji indicators.

### Performance Optimization

#### 1. **Minimize API Calls**
- Use UserService caching
- Store user data locally
- Avoid duplicate requests

#### 2. **Lazy Load Data**
- Load family background on demand
- Paginate large lists
- Cache filtered results

#### 3. **Image Optimization**
- Compress images before upload
- Cache downloaded photos
- Use Progressive JPEG

---

## Additional Resources

### Official Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)

### Dependencies
- [HTTP Package](https://pub.dev/packages/http)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)
- [Image Picker](https://pub.dev/packages/image_picker)

### Related Files
- [pubspec.yaml](pubspec.yaml) - Dependency definitions
- [analysis_options.yaml](analysis_options.yaml) - Linting rules
- [codemagic.yaml](codemagic.yaml) - CI/CD configuration
- [android/build.gradle.kts](android/build.gradle.kts) - Android build config
- [ios/Runner.xcodeproj](ios/Runner.xcodeproj) - iOS build config

---

## Support & Contribution

### Reporting Issues

When reporting issues, include:
1. Device type and OS version
2. Error message and stacktrace
3. Steps to reproduce
4. Screenshot/video if applicable

### Contribution Guidelines

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit pull request

### Code Quality Standards

- **Follow Dart style guide**
- **Write meaningful comments**
- **Test before committing**
- **Maintain consistent naming**
- **Keep functions focused**
- **Use proper error handling**

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Feb 2026 | Initial release |

---

## License

This project is proprietary and owned by the organization. All rights reserved.

---

## Contact & Support

For technical support or questions:
- **Email**: support@company.com
- **Internal Portal**: [HRIS Portal]
- **IT Department**: ext. XXXX

---

**Last Updated**: February 25, 2026
**Documentation Version**: 1.0
**Maintained By**: Development Team
