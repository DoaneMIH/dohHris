# HRIS Mobile Application - User Manual

## Version: 1.0.0

---

## Disclaimer

This software is provided "as-is" without warranty of any kind, express or implied. The developers make no representations or warranties regarding the software's reliability, accuracy, completeness, or suitability for any particular purpose. Users assume all risks associated with the use of this application, including but not limited to data loss, system failures, or operational disruptions.

By installing and using this application, you acknowledge that you have read and accepted this disclaimer. The developers shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from its use or inability to use the software.

---

## System Requirements

### Android

| Requirement | Specification |
|:---|:---|
| **Minimum SDK Version** | Android API Level 21 (Android 5.0) |
| **Target SDK Version** | Per Flutter configuration |
| **Recommended RAM** | Minimum 2 GB; 3-4 GB recommended |
| **Storage** | 100 MB minimum for installation |
| **Java Version** | JDK 17 or higher |

### iOS

| Requirement | Specification |
|:---|:---|
| **Minimum iOS Version** | iOS 11.0 or later |
| **Compatible iPhone Models** | iPhone 6s and later |
| **Compatible iPad Models** | iPad (5th generation) and later |
| **Recommended RAM** | Minimum 2 GB; 3 GB recommended |
| **Storage** | 80 MB minimum for installation |

---

## Installation & Deployment

### A. For Developers

#### Prerequisites

Ensure you have Flutter installed and properly configured. Visit [flutter.dev](https://flutter.dev/docs/get-started/install) for installation instructions.

```bash
# Verify Flutter installation
flutter --version
```

#### Step 1: Clone or Access the Project

Navigate to your project directory:

```bash
cd /path/to/mobile_application
```

#### Step 2: Get Dependencies

Install all required packages specified in [pubspec.yaml](pubspec.yaml):

```bash
flutter pub get
```

This will download and install the following key dependencies:
- **provider** (6.1.5+1) - State management
- **http** (1.1.0) - HTTP client for API calls
- **shared_preferences** (2.5.4) - Local data persistence
- **image_picker** (1.2.1) - Image selection functionality
- **cupertino_icons** (1.0.8) - iOS-style icons
- **flutter_launcher_icons** (0.14.4) - App icon generation

#### Step 3: Run on Android Emulator

```bash
# List available emulators
flutter emulators

# Create an emulator (if needed)
flutter emulators create --name MyEmulator

# Launch emulator
flutter emulators launch MyEmulator

# Run the application
flutter run
```

#### Step 4: Run on iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Launch simulator (macOS only)
open -a Simulator

# Run the application
flutter run
```

#### Step 5: Building for Release

**For Android:**

```bash
flutter build apk --release
```

Output APK location: `build/app/outputs/flutter-app.apk`

**For iOS:**

```bash
flutter build ios --release
```

---

### B. For Users

#### Android Installation

**Via APK File:**

1. Enable installation from unknown sources:
   - Go to **Settings** > **Security**
   - Toggle **Unknown Sources** (or **Install Unknown Apps**)

2. Download the APK file from the provided link

3. Open the downloaded APK file and tap **Install**

4. Once installation completes, tap **Open** to launch the application

**Via Google Play Store (When Available):**

1. Open the **Google Play Store**
2. Search for "HRIS Mobile Application"
3. Tap **Install**
4. Allow required permissions
5. Tap **Open**

#### iOS Installation

**Via TestFlight (Beta Testing):**

1. Install **TestFlight** from the Apple App Store (if not already installed)

2. Open the TestFlight invitation link sent via email

3. Tap **View in App Store**

4. Select **Install**

5. Allow required permissions

6. Launch the app from the TestFlight home screen

**Via Apple App Store (When Available):**

1. Open the **App Store**
2. Search for "HRIS Mobile Application"
3. Tap the **Get** button
4. Complete Face ID / Touch ID authentication
5. Tap **Open**

---

## Usage

### Application Overview

The HRIS Mobile Application is a comprehensive Human Resources Information System designed to streamline HR processes and employee management. Below are the main features based on the application architecture:

### Main Features & Pages

#### 1. **Login Page** (`login_page.dart`)
- Secure authentication using credentials
- Token-based session management
- Automatic session persistence
- Password reset functionality (via credentials storage)

**How to Use:**
1. Enter your company-provided employee ID
2. Enter your password
3. Tap **Login**
4. The application will verify your credentials and establish a secured session

#### 2. **Homepage** (`homepage.dart`)
- Quick access dashboard
- Navigation hub to all application features
- User profile quick-view
- Session status indicator

**How to Use:**
1. After successful login, you will be presented with the dashboard
2. Browse available modules using the navigation menu
3. Tap on any module to access its features

#### 3. **Daily Time Record (DTR) Page** (`dtr_page.dart`)
- Record work hours and attendance
- Time-in/Time-out functionality
- Attendance history tracking
- Real-time status updates

**How to Use:**
1. Navigate to **DTR** from the homepage
2. Tap **Time In** when you arrive at work
3. Tap **Time Out** when you leave
4. View your weekly/monthly attendance history
5. Export DTR records (if enabled)

#### 4. **Payroll Page** (`payroll_page.dart`)
- View salary information
- Pay slip access and download
- Tax and deduction breakdowns
- Payment history

**How to Use:**
1. Navigate to **Payroll** from the homepage
2. Select the pay period from the dropdown
3. Review your salary breakdown
4. Download your pay slip by tapping the **Download** button
5. View previous pay periods using navigation arrows

#### 5. **Loan Management Page** (`loan_page.dart`)
- Apply for loans
- Track loan status
- View loan details and schedules
- Monitor payment history

**How to Use:**
1. Navigate to **Loans** from the homepage
2. To apply for a loan:
   - Tap **New Loan Application**
   - Fill in the required details (amount, purpose, tenure)
   - Submit the application
3. View existing loans with their current status
4. Track monthly installment payments

#### 6. **User Profile & Credentials** (`UserCredentials/`)
- View and edit personal information
- Update contact details
- Manage login credentials
- View profile photo

**How to Use:**
1. Tap your profile icon (typically in the header)
2. Review or update your personal details
3. Change your password if needed
4. Update your profile photo

#### 7. **About Page** (`about.dart`)
- Application version information
- Feature overview
- Support contact details
- Terms and conditions link

**How to Use:**
1. Navigate to **Menu** > **About**
2. Review application details and version
3. Access additional support resources

### Navigation System

The application uses a **Navigation Bar** for seamless page transitions:
- Swipe left/right between pages
- Tap navigation icons at the bottom to jump to specific sections
- Use the back button to return to previous pages

### User Profile Management

Manage your profile separately accessed from the User Credentials menu:
- Update personal information
- Change password
- Set profile picture (via image picker)
- Configure notification preferences

### Session Management

- Your session is automatically maintained across app restarts
- You will be automatically logged out after 30 minutes of inactivity (configurable)
- Token refresh occurs automatically when needed
- Manual logout available in settings

---

## Troubleshooting

### Common Issues & Solutions

#### 1. **"Command not found: flutter"**

**Problem:** Flutter command is not recognized in your terminal.

**Solution:**
- Verify Flutter is installed: Visit [flutter.dev](https://flutter.dev)
- Add Flutter to your PATH:
  - **Windows:** Add `C:\flutter\bin` to System Environment Variables
  - **macOS/Linux:** Add `export PATH="$PATH:/path/to/flutter/bin"` to `~/.bashrc` or `~/.zshrc`
- Restart your terminal and try again

---

#### 2. **Android Gradle Sync Fails**

**Problem:** Build fails with "Gradle sync failed" error.

**Solution:**
```bash
# Clean gradle cache
./gradlew clean

# Clear Flutter build
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter build apk
```

**Advanced:**
- Ensure Java Development Kit (JDK) 17+ is installed
- Update Android SDK: `flutter doctor --android-licenses` and accept all licenses
- Check `android/gradle.properties` has proper JVM arguments:
  ```properties
  org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G
  ```

---

#### 3. **iOS CocoaPods Issues**

**Problem:** "Error running pod install" or "Cocoapods not found" (macOS only)

**Solution:**
```bash
# Install or update CocoaPods
sudo gem install cocoapods

# Clean Flutter build
flutter clean

# Get dependencies
flutter pub get

# Navigate to iOS directory
cd ios/

# Update pods
pod repo update
pod install

# Return to project root
cd ..

# Run on iOS
flutter run
```

**Advanced:**
- If issues persist, remove Pods and Podfile.lock:
  ```bash
  cd ios/
  rm -rf Pods
  rm Podfile.lock
  pod install
  ```

---

#### 4. **"Unable to Locate API Endpoints"**

**Problem:** App fails to connect to the backend API.

**Solution:**
- Verify internet connection on your device
- Check API configuration in [lib/config/api_config.dart](lib/config/api_config.dart)
- Ensure you're accessing the correct API endpoint URL
- For emulators, use `10.0.2.2` instead of `localhost` on Android
- For iOS simulators, use `localhost` or `127.0.0.1`
- Contact your IT department to verify API availability

---

#### 5. **"Authentication Failed" or "Session Expired"**

**Problem:** Login fails or you're logged out unexpectedly.

**Solution:**
- Verify your credentials are correct
- Clear app cache:
  - **Android:** Settings > Apps > Mobile Application > Storage > Clear Cache
  - **iOS:** Settings > General > iPhone Storage > Mobile Application > Offload App, then reinstall
- Ensure your account is active and not locked
- Check internet connectivity
- Update your password if needed
- Reinstall the app as a last resort:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

---

#### 6. **App Crashes on Startup**

**Problem:** Application crashes immediately after launching.

**Solution:**
- Clear application data:
  - **Android:** Settings > Apps > Mobile Application > Storage > Clear Data
  - **iOS:** Offload and reinstall the app
- Update Flutter and dependencies:
  ```bash
  flutter upgrade
  flutter pub get
  ```
- Rebuild the app:
  ```bash
  flutter clean
  flutter run
  ```
- Check logs for detailed error information:
  ```bash
  flutter run -v
  ```

---

#### 7. **Image Picker Not Working**

**Problem:** Cannot select images from gallery or camera.

**Solution:**
- **Android:** Grant permissions:
  - Go to **Settings > Apps > Mobile Application > Permissions**
  - Enable **Camera** and **Photos/Media**
  
- **iOS:** Grant permissions:
  - Go to **Settings > Privacy > Camera** (enable for the app)
  - Go to **Settings > Privacy > Photos** (enable for the app)

---

#### 8. **Push Notifications Not Received**

**Problem:** Notifications are not appearing on your device.

**Solution:**
- Enable notifications in app settings
- Check device notification settings are enabled for this app
- Ensure location services are enabled (if required)
- Restart the application

---

#### 9. **Storage/Permission Errors**

**Problem:** "Permission denied" or storage-related errors.

**Solution:**
- **Android:** Grant necessary permissions through Settings
- **iOS:** Grant permissions when prompted during app use
- Ensure adequate device storage (minimum 100 MB free space)
- Restart the device

---

#### 10. **"Hot Reload/Restart Fails During Development"**

**Problem:** `flutter run` fails with hot reload/restart errors.

**Solution:**
```bash
# Stop the current process (Ctrl+C)

# Kill any existing Flutter processes
pkill flutter

# Clean build files
flutter clean

# Restart the app
flutter run
```

---

## Performance Optimization Tips

### For Users

1. **Regular Cache Clearing:**
   - Clear app cache monthly to maintain performance
   - Remove unused cached images and documents

2. **Network Usage:**
   - Use Wi-Fi when available to reduce mobile data consumption
   - Background sync requires active internet connection

3. **Device Storage:**
   - Maintain at least 100 MB free storage
   - Remove old downloaded documents

4. **Battery Usage:**
   - Disable background refresh when not needed
   - Reduce screen brightness in settings

### For Developers

1. Keep Flutter SDK updated: `flutter upgrade`
2. Regularly update package dependencies: `flutter pub upgrade`
3. Monitor build times and optimize as needed
4. Use release builds for performance testing
5. Profile app performance using Flutter DevTools: `flutter pub global activate devtools`

---

## Security Best Practices

- **Never share your login credentials** with anyone
- **Enable device lock** (PIN/Biometric) on your device
- **Use strong passwords** with mixed case, numbers, and symbols
- **Log out** when finished using the app on shared devices
- **Keep your phone OS and apps updated** for security patches
- **Avoid public Wi-Fi** for sensitive operations; use VPN if necessary
- **Never store sensitive information** in screenshots or notes

---

## FAQ (Frequently Asked Questions)

**Q: How do I reset my password?**
A: Contact your HR department or use the password reset feature on the login screen if enabled.

**Q: Can I use the app on multiple devices?**
A: Yes, but your session will be managed per device. Logging in on a new device will maintain your previous session.

**Q: How is my data backed up?**
A: Your data is securely stored on company servers. Daily backups are performed; contact IT for recovery needs.

**Q: What internet speed do I need?**
A: Minimum 2 Mbps recommended for optimal performance. Basic operations work with 1 Mbps.

**Q: Is the app available offline?**
A: Limited features are available offline. Full functionality requires internet connection.

**Q: How often are new features released?**
A: Features are rolled out based on company requirements. Check the About section for current version details.

---

## Contact & Support

### Technical Support

| Channel | Contact |
|:---|:---|
| **Email** | [support@company.com](mailto:support@company.com) |
| **Help Desk** | +1-XXX-XXX-XXXX (Extension: XXX) |
| **IT Portal** | [https://itsupport.company.com](https://itsupport.company.com) |
| **On-Site Support** | HR Department, Building A, 2nd Floor |

### For HR-Related Inquiries

| Issue | Contact |
|:---|:---|
| **Leave Management** | hr@company.com |
| **Payroll Questions** | payroll@company.com |
| **Loan Applications** | finance@company.com |
| **General HR Issues** | employees@company.com |

### Developers

For developers working with this codebase:

- **Flutter Documentation:** https://flutter.dev/docs
- **Dart Documentation:** https://dart.dev/guides
- **Package Registry:** https://pub.dev
- **Project Repository:** [TBD]
- **Pull Request Reviews:** [TBD]

### Reporting Bugs

To report a bug:

1. Capture screenshots or screen recordings
2. Note the exact steps to reproduce the issue
3. Include device model and OS version
4. Email details to [support@company.com](mailto:support@company.com)
5. Reference your employee ID

---

## Application Dependencies Reference

The application uses the following key packages (from [pubspec.yaml](pubspec.yaml)):

| Package | Version | Purpose |
|:---|:---|:---|
| **Flutter SDK** | ^3.10.7 | Core framework |
| **provider** | 6.1.5+1 | State management |
| **http** | 1.1.0 | HTTP requests to API |
| **shared_preferences** | 2.5.4 | Local data storage |
| **image_picker** | 1.2.1 | Image selection from gallery/camera |
| **cupertino_icons** | 1.0.8 | iOS-style icons |
| **flutter_launcher_icons** | 0.14.4 | App icon generation |
| **flutter_lints** | 6.0.0 | Code quality analysis (dev) |

---

## Version History

| Version | Release Date | Key Features |
|:---|:---|:---|
| 1.0.0 | [Current Date] | Initial release with DTR, Payroll, Loan Management |

---

## Document Information

- **Document Version:** 1.0
- **Last Updated:** March 17, 2026
- **Application Version:** 1.0.0
- **Flutter Version:** 3.10.7+
- **Dart Version:** 3.10.7+

---

**End of User Manual**

For the latest updates and additional resources, visit your company's HR portal or contact the support team listed above.
