# Testing Documentation

## Overview

This guide covers testing strategies, tools, and best practices for the HRIS Mobile Application.

---

## Testing Types

### Unit Tests

**Purpose**: Test individual functions and services in isolation

**Framework**: `flutter_test`

```dart
// File: test/services/auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('login', () {
      test('returns success on valid credentials', () async {
        final result = await authService.login(
          'test@example.com',
          'Password123!',
        );

        expect(result['success'], true);
        expect(result['data'], isNotNull);
        expect(result['error'], isNull);
      });

      test('returns error on invalid email', () async {
        final result = await authService.login(
          'invalid-email',
          'Password123!',
        );

        expect(result['success'], false);
        expect(result['error'], isNotNull);
      });

      test('returns error on missing password', () async {
        final result = await authService.login(
          'test@example.com',
          '',
        );

        expect(result['success'], false);
      });
    });

    group('validatePassword', () {
      test('validates strong password', () {
        final isValid = AuthService.validatePassword('StrongPass123!');
        expect(isValid, true);
      });

      test('rejects weak password', () {
        final isValid = AuthService.validatePassword('weak');
        expect(isValid, false);
      });
    });
  });
}
```

**Run Tests**:
```bash
flutter test
flutter test test/services/auth_service_test.dart
```

### Widget Tests

**Purpose**: Test UI components and interactions

```dart
// File: test/pages/login_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginPage()),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows error on invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginPage()),
      );

      // Enter invalid email
      await tester.enterText(
        find.byType(TextField).first,
        'invalid-email',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check error message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('navigates on successful login', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginPage()),
      );

      // Enter credentials
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'Password123!',
      );

      // Tap login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
```

**Run Tests**:
```bash
flutter test test/pages/login_page_test.dart
```

### Integration Tests

**Purpose**: Test complete user flows

```dart
// File: test_driver/app.dart

import 'package:flutter/material.dart';
import 'package:mobile_application/main.dart';

void main() => runApp(const MyApp());
```

```dart
// File: test_driver/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_application/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Test', () {
    testWidgets('Complete login flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and fill email field
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );

      // Find and fill password field
      await tester.enterText(
        find.byType(TextField).at(1),
        'Password123!',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we're on home page
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

**Run Integration Tests**:
```bash
flutter drive --target=test_driver/app.dart
```

---

## Test Coverage

### Generate Coverage Report

```bash
# Generate LCOV coverage file
flutter test --coverage

# Convert to HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Coverage Goals

| Component | Target |
|-----------|--------|
| Services | 90%+ |
| Utilities | 85%+ |
| Widgets | 70%+ |
| Pages | 60%+ |
| Overall | 80%+ |

### View Coverage

```bash
# Install lcov
brew install lcov  # macOS
sudo apt-get install lcov  # Linux

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
```

---

## Mock & Stub Testing

### Mocking HTTP Requests

```dart
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('UserService', () {
    test('fetches user data', () async {
      final mockClient = MockHttpClient();
      
      // Mock response
      when(mockClient.get(any))
        .thenAnswer((_) async => http.Response(
          '{"id": 1, "name": "John"}',
          200,
        ));
      
      final userService = UserService(client: mockClient);
      final user = await userService.getUser('1');
      
      expect(user.name, equals('John'));
      
      // Verify call was made
      verify(mockClient.get(any)).called(1);
    });
  });
}
```

### Mocking SharedPreferences

```dart
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TokenManager', () {
    test('stores and retrieves token', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      // Store token
      await prefs.setString('token', 'test-token-123');
      
      // Retrieve token
      final token = prefs.getString('token');
      
      expect(token, equals('test-token-123'));
    });
  });
}
```

---

## Performance Testing

### Test Performance

```dart
void main() {
  group('Performance Tests', () {
    testWidgets('LoginPage renders quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const MyApp());
      
      stopwatch.stop();
      
      // Should render in less than 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('UserService processes large dataset', () async {
      final stopwatch = Stopwatch()..start();
      
      final users = List.generate(1000, (i) => User(id: i, name: 'User $i'));
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
```

---

## Testing Best Practices

### Do's

```dart
// ✅ DO: Test behavior, not implementation
test('user can login with valid credentials', () async {
  final result = await authService.login(email, password);
  expect(result['success'], true);
});

// ✅ DO: Use descriptive test names
test('returns error when email format is invalid', () {});
test('navigates to home page after successful login', () {});

// ✅ DO: Test edge cases
test('handles empty email field', () {});
test('handles null password', () {});

// ✅ DO: Use setUp and tearDown
setUp(() {
  // Initialize test fixtures
});

tearDown(() {
  // Clean up resources
});

// ✅ DO: Group related tests
group('AuthService', () {
  group('login', () {
    test('...', () {});
  });
});
```

### Don'ts

```dart
// ❌ DON'T: Test implementation details
test('_validateEmail is called', () {});

// ❌ DON'T: Use vague test names
test('works', () {});

// ❌ DON'T: Make tests dependent on order
test('first test', () {});
test('second test needs first to pass', () {});

// ❌ DON'T: Test multiple concerns in one test
test('login validates email and password and shows error', () {});

// ❌ DON'T: Use hardcoded values
test('validates email', () {
  expect(validator.validate('abc@def.com'), true);
});
```

---

## Continuous Testing

### Watch Mode

```bash
# Watch files and re-run tests on changes
flutter test --watch
```

### Pre-commit Testing

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "Running tests..."
flutter test

if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi

exit 0
```

---

## Test Data

### Fixtures

```dart
// File: test/fixtures/user_fixtures.dart

class UserFixtures {
  static const validEmail = 'test@example.com';
  static const validPassword = 'ValidPass123!';
  static const validUser = {
    'id': 1,
    'email': validEmail,
    'first_name': 'John',
    'last_name': 'Doe',
  };
}
```

### Factory Methods

```dart
class UserFactory {
  static User createUser({
    int id = 1,
    String email = 'test@example.com',
    String name = 'John Doe',
  }) {
    return User(
      id: id,
      email: email,
      name: name,
    );
  }
}
```

---

## Testing Checklist

Before committing code:

- [ ] All tests pass locally
- [ ] Coverage at or above target
- [ ] New tests written for new code
- [ ] Tests are independent
- [ ] No hardcoded values
- [ ] Descriptive test names
- [ ] No skipped tests
- [ ] Error cases tested

---

## Test Failure Debugging

### Common Issues

```dart
// Issue: "A Timer is still running"
// Fix: Use pumpWidget and pumpAndSettle
await tester.pumpAndSettle();

// Issue: State is not preserved between tests
// Fix: Use setUp and tearDown properly
setUp(() => initializeTestState());

// Issue: Mock not called
// Fix: Verify with correct matcher
verify(mock.method(any)).called(1);
```

---

## Continuous Integration Testing

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

---

## Next Steps

- Review [CODE_STYLE_GUIDE.md](CODE_STYLE_GUIDE.md) for test code standards
- Check [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md) for test issues
- See [CI_CD_DOCUMENTATION.md](CI_CD_DOCUMENTATION.md) for automated testing

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Testing Framework**: flutter_test, mockito, integration_test
