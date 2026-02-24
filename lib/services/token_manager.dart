

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _token;
  String? _email;
  String? _password;
  Timer? _refreshTimer;
  Function? _onTokenExpired;

  // Refresh at 4 min so the new token arrives well before the 5-min window closes
  static const Duration refreshInterval = Duration(minutes: 4);

  String? get token => _token;

  //Initialize token manager with the first token AND the credentials
  //that produced it so we can re-login silently on every refresh cycle.
  void initialize(
    String token, {
    required String email,
    required String password,
    Function? onTokenExpired,
  }) {
    print('🔄 [TokenManager] Initializing with new token');
    _token = token;
    _email = email;
    _password = password;
    _onTokenExpired = onTokenExpired;

    // Cancel any existing timer before starting a new one
    _refreshTimer?.cancel();

    _startAutoRefresh();
  }

  // Start the periodic refresh timer
  void _startAutoRefresh() {
    print('⏰ [TokenManager] Starting auto-refresh timer');
    print(
        '⏰ [TokenManager] Will refresh every ${refreshInterval.inMinutes} min '
        '${refreshInterval.inSeconds % 60} sec');

    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      print('🔄 [TokenManager] Auto-refresh triggered');
      await refreshToken();
    });
  }

  // Re-login using stored credentials to get a brand-new token.
  // This hits POST /auth/login — the same endpoint the app uses on first login.
  Future<bool> refreshToken() async {
    if (_email == null || _password == null) {
      print('❌ [TokenManager] No stored credentials — cannot refresh');
      _handleTokenExpired();
      return false;
    }

    print('🔄 [TokenManager] Refreshing token via /auth/login ...');
    print('🌐 [TokenManager] API URL: ${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'password': _password,
        }),
      );

      print('📥 [TokenManager] Response status code: ${response.statusCode}');

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
        // Credentials are no longer valid (e.g. password changed)
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
      print('💥 [TokenManager] Exception type: ${e.runtimeType}');
      return false;
    }
  }

  /// Handle token expiration / invalid credentials
  void _handleTokenExpired() {
    print('⚠️ [TokenManager] Token expired — logging out user');

    _refreshTimer?.cancel();
    _refreshTimer = null;

    _token = null;
    // Keep credentials cleared so nothing can silently re-login
    _email = null;
    _password = null;

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
    _email = null;
    _password = null;
    _onTokenExpired = null;
  }

  /// Quick check — true when a token is present and non-empty
  bool get hasValidToken => _token != null && _token!.isNotEmpty;
}