 import 'package:flutter/material.dart';
import 'package:mobile_application/pages/login_page.dart';
import 'package:mobile_application/pages/UserCredentials/user_details.dart';
import 'package:mobile_application/pages/navigation.dart';
import 'package:mobile_application/widgets/splash.dart';
import 'package:mobile_application/services/token_manager.dart';
import 'package:mobile_application/config/api_config.dart';

/// Centralized route management for all navigation paths in the app to prevent hardcoding route names throughout the codebase.
class MyRoutes {
  /// Splash screen route shown first when the app launches to check if user session exists.
  static const String splashPage = "/splash";
  /// Login page route where users enter credentials; shown if no valid session found.
  static const String loginPage = "/login_page";
  /// User details page route for viewing and editing profile information.
  static const String userDetailsPage = "/user_details";
  /// Home page route showing dashboard and main app content after successful login.
  static const String homePage = "/home";
 
 /// Maps route names to their corresponding widget builders; gets current token from TokenManager so routes always use fresh credentials.
 static final routes = <String, WidgetBuilder>{
    splashPage: (context) => const Splash2(),
    loginPage: (context) => const LoginPage(),
    homePage: (context) {
      final tokenManager = TokenManager();
      return MainNavigation(
        token: tokenManager.token ?? '',
        baseUrl: ApiConfig.baseUrl,
        initialIndex: 1, // Home tab is index 0, Profile tab is index 1, About tab is index 2
      );
    },
    userDetailsPage: (context) {
      final tokenManager = TokenManager();
      return UserDetailsPageContent(
        token: tokenManager.token ?? '',
        baseUrl: ApiConfig.baseUrl,
      );
    },
 };
}