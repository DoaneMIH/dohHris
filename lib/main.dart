import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/config/theme.dart';
import 'package:mobile_application/providers/theme_provider.dart';
import 'package:mobile_application/widgets/routes.dart';
import 'package:mobile_application/widgets/splash.dart';
import 'package:mobile_application/services/session_manager.dart';

/// Global navigator key used to navigate from anywhere in the app (e.g., when token expires in background).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Initializes the app by checking for an existing session, then runs the main app widget with theme support.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Checks if user has valid 7-day session from previous login; navigates to home if true, login if false.
  final sessionManager = SessionManager();
  final hasValidSession = await sessionManager.initializeSession(
    /// Callback that fires if auto-refresh receives a 401 while app is running (credentials invalid), forcing user back to login.
    onTokenExpired: () {
      // Fires when auto-refresh gets a 401 while the app is running.
      // Clears the entire nav stack and sends the user back to login.
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        MyRoutes.loginPage,
        (route) => false,
      );
    },
  );

  runApp(MyApp(hasValidSession: hasValidSession));
}

/// Root widget of the HRIS app that sets up theme provider and navigates based on session status.
class MyApp extends StatelessWidget {
  /// True if a valid 7-day session was found, causing the app to skip login and go straight to home.
  final bool hasValidSession;

  const MyApp({Key? key, this.hasValidSession = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'HRIS Login',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: navigatorKey, // attach the global key
            // navigatorObservers: [AppRouteObserver()],
            home: hasValidSession
                ? const Splash2(skipToHome: true)
                : const Splash2(),
            // initialRoute: MyRoutes.splashPage,
            routes: MyRoutes.routes,
          );
        },
      ),
    );
  }
}