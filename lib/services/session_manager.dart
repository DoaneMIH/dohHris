import 'package:mobile_application/services/token_manager.dart';

/// Singleton manager for app-level session lifecycle; checks for persisted login on startup and coordinates token expiry callbacks.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  /// Checks if a valid 7-day session exists from a previous login; returns true to skip login, false to show login screen.
  /// [onTokenExpired] callback fires if the auto-refresh cycle detects a 401 error (invalid credentials), allowing logout and navigation to login.
  Future<bool> initializeSession({Function? onTokenExpired}) async {
    print('🔍 [SessionManager] Checking for existing session...');

    try {
      final tokenManager = TokenManager();

      // Wire up the expiry callback BEFORE loading storage so the timer that
      // starts inside loadRefreshTokenFromStorage() already has it set.
      if (onTokenExpired != null) {
        tokenManager.setOnTokenExpired(onTokenExpired);
      }

      final hasValidSession = await tokenManager.loadRefreshTokenFromStorage();

      if (hasValidSession) {
        print('✅ [SessionManager] Session restored! User is logged in');
        return true;
      } else {
        print('❌ [SessionManager] No valid session found. User needs to login');
        return false;
      }
    } catch (e) {
      print('💥 [SessionManager] Error during session initialization: $e');
      return false;
    }
  }
}