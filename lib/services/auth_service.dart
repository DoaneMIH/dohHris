
import 'package:flutter/material.dart'; // Added for BuildContext and Navigator
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/token_manager.dart';
import 'package:mobile_application/widgets/routes.dart'; // Added for MyRoutes

/// Handles user authentication and session management, including login, logout, and token persistence.
class AuthService {
  // ════════════════════════════════════════════════════════
  // 1. LOGIN METHOD
  // ════════════════════════════════════════════════════════
  /// Authenticates a user by checking their credentials and setting up automatic token refresh for a persistent 7-day session.
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔐 [AuthService] Starting login process...');
    print('📧 [AuthService] Email: $email');
    print('🌐 [AuthService] API URL: ${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

    try {
      /// Prepare request with user's email and password.
      final requestBody = {
        'email': email,
        'password': password,
      };
      print('📤 [AuthService] Request body: ${jsonEncode(requestBody)}');

      /// Send credentials to the server for validation and token generation.
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 [AuthService] Response status code: ${response.statusCode}');
      print('📥 [AuthService] Response body: ${response.body}');

      /// If credentials are valid, extract tokens and initialize automatic refresh cycle.
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AuthService] Login successful!');
        print('🎫 [AuthService] Token received: ${data['token']?.substring(0, 20)}...');
        print('👤 [AuthService] User ID: ${data['employee']?['id']}');

        /// Store credentials in TokenManager so it can silently re-authenticate every 4 minutes and maintain the 7-day session.
        TokenManager().initialize(
          data['token'],
          email: email,
          password: password,
          // Add this line so the TokenManager knows to save the 7-day session!
          refreshToken: data['refresh_token'] ?? data['token'],
        );

        return {
          'success': true,
          'data': data,
        };
      } else {
        /// If the server rejects the credentials, return the error message to the caller.
        print('❌ [AuthService] Login failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Login failed: ${response.body}',
        };
      }
    } catch (e) {
      /// If the network request fails or an unexpected error occurs, catch it and return an error response.
      print('💥 [AuthService] Exception occurred: $e');
      print('💥 [AuthService] Exception type: ${e.runtimeType}');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  // ════════════════════════════════════════════════════════
  // 2. LOGOUT METHOD
  // ════════════════════════════════════════════════════════
  /// Clears all stored authentication tokens and credentials, then returns the user to the login screen.
  static Future<void> logout(BuildContext context) async {
    print('🚪 [AuthService] Starting logout process...');
    
    final tokenManager = TokenManager();
    
    /// Stop the automatic token refresh timer and clear tokens from memory.
    tokenManager.dispose(); 
    
    /// Remove the 7-day persistent session from storage, preventing silent re-login after restart.
    await tokenManager.clearStorage();

    /// Validate that the app context still exists before attempting navigation.
    if (!context.mounted) return;

    print('✅ [AuthService] Storage cleared. Navigating to login...');
    
    /// Clear the entire navigation stack so the user can't use the back button to return to logged-in pages.
    Navigator.pushNamedAndRemoveUntil(
      context, 
      MyRoutes.loginPage, 
      (route) => false, 
    );
  }
}