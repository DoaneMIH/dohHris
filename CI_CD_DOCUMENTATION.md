# CI/CD Documentation

## Overview

Complete guide to the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the HRIS Mobile Application using CodeMagic.

---

## CI/CD Architecture

```
┌─────────────────────┐
│   Developer Commit  │
│    to Repository    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   GitHub Webhook    │
│   Triggers Build    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   CodeMagic Build   │
│   - Test           │
│   - Build          │
│   - Sign           │
└──────────┬──────────┘
           │
      ┌────┴────┐
      │          │
   Success    Failure
      │          │
      ▼          ▼
  Deploy    Notify Dev
   Notify
```

---

## CodeMagic Configuration

### File: codemagic.yaml

Located in project root directory.

```yaml
workflows:
  android-build:
    name: Android Build & Test
    triggering:
      events:
        - push
        - pull_request
      branch:
        patterns:
          - develop
          - main
      
    environment:
      flutter: stable
      android_sdk: 34.0.0
      java: 11
      gradle: 7.5
    
    scripts:
      - name: Install dependencies
        script: flutter pub get
      
      - name: Run tests
        script: flutter test
      
      - name: Run analysis
        script: dart analyze
      
      - name: Build APK
        script: |
          flutter build apk --release --split-per-abi
      
      - name: Build AAB
        script: |
          flutter build appbundle --release
    
    artifacts:
      - build/app/outputs/**/*.apk
      - build/app/outputs/**/*.aab
    
    publishing:
      email:
        recipients:
          - dev-team@company.com
        notify:
          success: true
          failure: true

  ios-build:
    name: iOS Build & Test
    triggering:
      events:
        - push
        - pull_request
      branch:
        patterns:
          - develop
          - main
    
    environment:
      flutter: stable
      xcode: 14.1
      cocoapods: 1.11
    
    scripts:
      - name: Install dependencies
        script: flutter pub get
      
      - name: Run tests
        script: flutter test
      
      - name: Build iOS
        script: |
          flutter build ios --release --no-codesign
      
      - name: Build IPA
        script: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -derivedDataPath build \
            -allowProvisioningUpdates
    
    artifacts:
      - build/ios/Release-iphoneos/*.app
    
    publishing:
      email:
        recipients:
          - dev-team@company.com

  web-build:
    name: Web Build & Deploy
    triggering:
      events:
        - push
      branch:
        patterns:
          - main
    
    environment:
      flutter: stable
      node: 18
    
    scripts:
      - name: Install dependencies
        script: flutter pub get
      
      - name: Run tests
        script: flutter test
      
      - name: Build web
        script: flutter build web --release
      
      - name: Deploy to Firebase
        script: |
          npm install -g firebase-tools
          firebase deploy --token $FIREBASE_TOKEN
    
    artifacts:
      - build/web/**
    
    publishing:
      email:
        recipients:
          - dev-team@company.com
```

---

## GitHub Actions Alternative

### File: .github/workflows/build.yml

```yaml
name: Build & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.7'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Run analysis
        run: dart analyze
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.7'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build AAB
        run: flutter build appbundle --release
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: android-build
          path: |
            build/app/outputs/**/*.apk
            build/app/outputs/**/*.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.7'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/Release-iphoneos
```

---

## Build Stages

### 1. Trigger

Builds can be triggered by:
- Push to specific branches
- Pull requests
- Manual trigger
- Scheduled (cron jobs)

```yaml
triggering:
  events:
    - push
    - pull_request
    - tag
  branch:
    patterns:
      - develop
      - main
      - release/*
  tag:
    patterns:
      - v*
```

### 2. Setup Environment

Install and configure tools:
- Flutter SDK
- Dart SDK
- Android SDK
- Xcode (iOS)
- Java/Gradle

### 3. Get Dependencies

```bash
flutter pub get
```

### 4. Analyze

```bash
dart analyze
flutter analyze
```

### 5. Test

```bash
flutter test
flutter test --coverage
```

### 6. Build

Build for target platform:
```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
```

### 7. Sign

Sign APK/AAB for distribution:
```bash
# Signing happens in codemagic.yaml configuration
# Keystore credentials stored in environment variables
```

### 8. Artifact Collection

Save build outputs for deployment

### 9. Deploy

Deploy to:
- Google Play Store
- Apple App Store
- Firebase Hosting
- Custom servers

### 10. Notify

Send notifications via:
- Email
- Slack
- GitHub status

---

## Environment Variables

### CodeMagic Variables

Set in CodeMagic console:

```
FIREBASE_TOKEN        = [firebase-token]
PLAY_STORE_KEY       = [play-store-key]
APPLE_ID              = [apple@email.com]
APPLE_PASSWORD        = [app-specific-password]
KEYSTORE_PASSWORD     = [android-keystore-password]
KEY_PASSWORD          = [android-key-password]
```

### GitHub Secrets

Set in GitHub repository settings:

```
FIREBASE_TOKEN
PLAY_STORE_KEY
APPLE_ID
APPLE_PASSWORD
```

### Using Variables

In workflow files:
```yaml
- name: Deploy
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  script: firebase deploy --token $FIREBASE_TOKEN
```

---

## Build Matrix

Test across multiple configurations:

```yaml
strategy:
  matrix:
    flutter-version: ['3.10', '3.13']
    dart-sdk: ['3.10.7', '3.13.0']
    android-sdk: ['34', '35']

steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

---

## Post-Build Actions

### Upload to Artifact Repository

```yaml
- name: Upload to artifacts
  uses: actions/upload-artifact@v3
  with:
    name: build-artifacts
    path: build/
```

### Send Notifications

#### Slack Notification

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Build Status",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Build *${{ job.status }}*\nCommit: ${{ github.sha }}"
            }
          }
        ]
      }
```

#### Email Notification

```yaml
- name: Send email
  if: failure()
  uses: davisben/action-send-email@v1
  with:
    server_address: ${{ secrets.EMAIL_SERVER }}
    server_port: ${{ secrets.EMAIL_PORT }}
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: "Build Failed: ${{ github.repository }}"
    to: dev-team@company.com
    from: ci@company.com
    body: |
      Build failed for commit ${{ github.sha }}
      Check logs at: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
```

---

## Automated Deployment

### Play Store Deployment

Using Fastlane:

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Google Play Store"
  lane :deploy do
    upload_to_play_store(
      aab: 'build/app/outputs/bundle/release/app-release.aab',
      track: 'beta',
      json_key: 'play-store-key.json'
    )
  end
end
```

### App Store Deployment

Using Fastlane:

```ruby
# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to App Store"
  lane :deploy do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release",
      export_method: "app-store"
    )
    
    upload_to_app_store(
      ipa: "Runner.ipa",
      skip_screenshots: true,
      skip_metadata: true
    )
  end
end
```

### Firebase Hosting Deployment

```yaml
- name: Deploy to Firebase
  run: |
    npm install -g firebase-tools
    flutter build web --release
    firebase deploy \
      --project ${{ secrets.FIREBASE_PROJECT }} \
      --token ${{ secrets.FIREBASE_TOKEN }}
```

---

## Build Optimization

### Parallel Jobs

Run independent jobs in parallel:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    # Runs first
  
  build-android:
    needs: test
    runs-on: ubuntu-latest
    # Runs after test completes
  
  build-ios:
    needs: test
    runs-on: macos-latest
    # Runs after test completes (in parallel with build-android)
```

### Caching Dependencies

```yaml
- uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      ~/.gradle/caches
      ~/Library/Caches
    key: ${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
```

### Docker Containers

For consistent environments:

```yaml
services:
  postgres:
    image: postgres:13
    env:
      POSTGRES_PASSWORD: postgres
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```

---

## Troubleshooting CI/CD

### Build Failures

#### Issue: "Dependencies fetch failed"

```yaml
- name: Debug dependencies
  run: flutter pub get --verbose
```

#### Issue: "Test timeout"

Increase timeout:
```yaml
- name: Run tests
  run: flutter test --test-randomize-ordering-seed random --timeout=120s
```

#### Issue: "APK signing failure"

Verify keystore configuration:
```bash
keytool -list -v -keystore hris-key.jks
```

### Common Solutions

```bash
# Clean cache
rm -rf ~/.pub-cache
rm -rf ~/.gradle

# Upgrade Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# Check for conflicts
flutter pub deps --style=pretty
```

---

## Monitoring & Analytics

### Track Build Metrics

```yaml
- name: Report metrics
  run: |
    echo "Build duration: $SECONDS seconds"
    du -sh build/
    flutter --version
    dart --version
```

### View Build History

- CodeMagic Dashboard: builds and logs
- GitHub Actions: workflow runs
- Email notifications: build status
- Slack channel: real-time updates

---

## Security Best Practices

### Secret Management

1. **Never commit secrets**:
   ```bash
   git add .gitignore  # Add key files
   echo "*.jks" >> .gitignore
   echo "*.p8" >> .gitignore
   ```

2. **Use environment variables**:
   ```yaml
   env:
     KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
   ```

3. **Rotate credentials regularly**:
   - Change signing keys annually
   - Rotate API tokens quarterly
   - Update service accounts

### Access Control

- Limit who can trigger builds
- Restrict deployment to main branch
- Require approvals for prod

```yaml
environments:
  production:
    approval-required: true
    allowed-branches: [main]
```

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Test Execution | < 5 minutes |
| APK Build | < 3 minutes |
| AAB Build | < 4 minutes |
| iOS Build | < 8 minutes |
| Web Build | < 2 minutes |
| Total Pipeline | < 15 minutes |

---

## Next Steps

- Review [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for manual deployment
- Check [TESTING_DOCUMENTATION.md](TESTING_DOCUMENTATION.md) for test setup
- See [ARCHITECTURE.md](ARCHITECTURE.md) for project structure

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**CI/CD Platform**: CodeMagic / GitHub Actions
