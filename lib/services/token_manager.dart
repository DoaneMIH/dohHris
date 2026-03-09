import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Singleton token manager handling access token auto-refresh and 7-day session persistence; ensures user stays logged in seamlessly.
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _token;
  String? _refreshToken;
  String? _email;
  String? _password;
  DateTime? _refreshTokenExpiresAt;
  Timer? _refreshTimer;
  Function? _onTokenExpired;

  /// Refresh access token every 4 minutes before the 5-minute server expiry to ensure seamless background operations.
  static const Duration refreshInterval = Duration(minutes: 4);

  /// Refresh token is valid for 7 days, allowing users to remain logged in across app restarts without re-entering credentials.
  static const Duration refreshTokenValidityDuration = Duration(days: 7);

  // Storage keys
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresKey = 'token_expires_at';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  /// True if refresh token exists and hasn't expired (within the 7-day window).
  bool get hasRefreshToken => _refreshToken != null && _isRefreshTokenValid();
  DateTime? get refreshTokenExpiresAt => _refreshTokenExpiresAt;

  /// Allow the session manager to set the expiry callback after the token manager is created (wired during initialization).
  void setOnTokenExpired(Function callback) {
    _onTokenExpired = callback;
  }

  /// Initialize token manager with the first token AND the credentials
  /// that produced it so we can re-login silently on every refresh cycle.
  void initialize(
    String token, {
    required String email,
    required String password,
    String? refreshToken,
    Function? onTokenExpired,
  }) {
    print('🔄 [TokenManager] Initializing with new token');
    print('🎫 [TokenManager] Token set to: ${token.substring(0, 20)}...');
    _token = token;
    _email = email;
    _password = password;
    _refreshToken = refreshToken;
    _onTokenExpired = onTokenExpired;

    // Set refresh token expiry
    if (refreshToken != null) {
      _refreshTokenExpiresAt = DateTime.now().add(refreshTokenValidityDuration);
      print('🎫 [TokenManager] Refresh token expires at: $_refreshTokenExpiresAt');
      print('🎫 [TokenManager] Refresh token valid for: ${refreshTokenValidityDuration.inDays} days');
      _saveRefreshTokenToStorage();
    }

    // Cancel any existing timer before starting a new one
    _refreshTimer?.cancel();
    _startAutoRefresh();
  }

  /// Check if refresh token is still valid
  bool _isRefreshTokenValid() {
    if (_refreshToken == null || _refreshTokenExpiresAt == null) {
      return false;
    }
    return DateTime.now().isBefore(_refreshTokenExpiresAt!);
  }

  /// Save refresh token and credentials to local storage
  Future<void> _saveRefreshTokenToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, _refreshToken ?? '');
      await prefs.setString(_tokenExpiresKey, _refreshTokenExpiresAt?.toIso8601String() ?? '');
      await prefs.setString(_emailKey, _email ?? '');
      await prefs.setString(_passwordKey, _password ?? '');
      print('✅ [TokenManager] Refresh token saved to storage');
    } catch (e) {
      print('❌ [TokenManager] Failed to save refresh token: $e');
    }
  }

  /// Load refresh token from local storage and restore the session
  Future<bool> loadRefreshTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRefreshToken = prefs.getString(_refreshTokenKey);
      final savedExpiresAt = prefs.getString(_tokenExpiresKey);
      final savedEmail = prefs.getString(_emailKey);
      final savedPassword = prefs.getString(_passwordKey);

      if (savedRefreshToken != null &&
          savedExpiresAt != null &&
          savedEmail != null &&
          savedPassword != null) {
        _refreshToken = savedRefreshToken;
        _refreshTokenExpiresAt = DateTime.parse(savedExpiresAt);
        _email = savedEmail;
        _password = savedPassword;

        if (_isRefreshTokenValid()) {
          final remaining = _refreshTokenExpiresAt!.difference(DateTime.now());
          print('✅ [TokenManager] Refresh token loaded from storage');
          print('🎫 [TokenManager] Expires at: $_refreshTokenExpiresAt');
          print('🎫 [TokenManager] Current time: ${DateTime.now()}');
          print('⏳ [TokenManager] Time remaining: ${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m');

          // Get a fresh access token
          final refreshed = await performTokenRefresh();
          if (!refreshed) {
            print('❌ [TokenManager] Failed to get access token on session restore');
            await clearStorage();
            return false;
          }

          print('🎫 [TokenManager] Token after restore: ${_token?.substring(0, 20)}...');

          // Restart the auto-refresh timer
          _refreshTimer?.cancel();
          _startAutoRefresh();
          return true;
        } else {
          print('❌ [TokenManager] Refresh token expired — clearing storage');
          await clearStorage();
          return false;
        }
      }

      print('ℹ️ [TokenManager] No saved session found');
      return false;
    } catch (e) {
      print('❌ [TokenManager] Failed to load refresh token: $e');
      return false;
    }
  }

  /// Clears tokens and credentials from memory and storage to completely log out the user and prevent silent re-login.
  Future<void> clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiresKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      print('✅ [TokenManager] Storage cleared');
    } catch (e) {
      print('❌ [TokenManager] Failed to clear storage: $e');
    }
  }

  /// Start the periodic access token refresh timer
  void _startAutoRefresh() {
    print('⏰ [TokenManager] Starting auto-refresh timer');
    print('⏰ [TokenManager] Will refresh every ${refreshInterval.inMinutes} min');

    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      print('🔄 [TokenManager] Auto-refresh triggered');
      await performTokenRefresh();
    });
  }

  /// Re-authenticates using stored credentials every 4 minutes to obtain a fresh access token before the current one expires (silent login).
  /// Returns false and calls onTokenExpired if credentials no longer work (e.g., password was changed elsewhere).
  Future<bool> performTokenRefresh() async {
    if (_email == null || _password == null) {
      print('❌ [TokenManager] No stored credentials — cannot refresh');
      _handleTokenExpired();
      return false;
    }

    print('🔄 [TokenManager] Refreshing token via /auth/login...');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'password': _password,
        }),
      );

      print('📥 [TokenManager] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _token = data['token'];
          print('✅ [TokenManager] Token refreshed successfully!');
          print('🎫 [TokenManager] New token: ${_token!.substring(0, 20)}...');
          return true;
        } else {
          print('❌ [TokenManager] No token field in login response');
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ [TokenManager] Re-login failed (401) — credentials invalid');
        _handleTokenExpired();
        return false;
      } else {
        print('❌ [TokenManager] Re-login failed: ${response.statusCode}');
        print('📥 [TokenManager] Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 [TokenManager] Exception during token refresh: $e');
      return false;
    }
  }

  /// Handle token expiration — clears everything and notifies the app
  void _handleTokenExpired() {
    print('⚠️ [TokenManager] Token expired — logging out user');

    _refreshTimer?.cancel();
    _refreshTimer = null;
    _token = null;
    _refreshToken = null;
    _email = null;
    _password = null;
    _refreshTokenExpiresAt = null;

    clearStorage();

    if (_onTokenExpired != null) {
      _onTokenExpired!();
    }
  }

  /// Stop auto-refresh and wipe everything (call on explicit logout)
  void dispose() {
    print('🛑 [TokenManager] Disposing token manager');
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _token = null;
    _refreshToken = null;
    _email = null;
    _password = null;
    _refreshTokenExpiresAt = null;
    _onTokenExpired = null;
    clearStorage();
  }

  /// True when an access token is present and non-empty
  bool get hasValidToken {
    final isValid = _token != null && _token!.isNotEmpty;
    print('🎫 [TokenManager] hasValidToken: $isValid');
    return isValid;
  }
}