import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _token;
  Timer? _refreshTimer;
  Function? _onTokenExpired;
  
  // Token refresh interval (4 minutes 30 seconds to refresh before 5 min expiry)
  static const Duration refreshInterval = Duration(minutes: 4, seconds: 30);

  String? get token => _token;

  /// Initialize token manager with initial token
  void initialize(String token, {Function? onTokenExpired}) {
    print('🔄 [TokenManager] Initializing with new token');
    _token = token;
    _onTokenExpired = onTokenExpired;
    
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Start automatic refresh
    _startAutoRefresh();
  }

  /// Start automatic token refresh timer
  void _startAutoRefresh() {
    print('⏰ [TokenManager] Starting auto-refresh timer');
    print('⏰ [TokenManager] Will refresh every ${refreshInterval.inMinutes} minutes ${refreshInterval.inSeconds % 60} seconds');
    
    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      print('🔄 [TokenManager] Auto-refresh triggered');
      await refreshToken();
    });
  }

  /// Manually refresh the token
  Future<bool> refreshToken() async {
    if (_token == null) {
      print('❌ [TokenManager] No token to refresh');
      return false;
    }

    print('🔄 [TokenManager] Refreshing token...');
    print('🎫 [TokenManager] Current token: ${_token!.substring(0, 20)}...');
    print('🌐 [TokenManager] API URL: ${ApiConfig.baseUrl}/auth/refresh-token');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh-token'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [TokenManager] Response status code: ${response.statusCode}');
      print('📥 [TokenManager] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          _token = data['token'];
          print('✅ [TokenManager] Token refreshed successfully!');
          print('🎫 [TokenManager] New token: ${_token!.substring(0, 20)}...');
          return true;
        } else {
          print('❌ [TokenManager] No token in response');
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ [TokenManager] Token expired or invalid - cannot refresh');
        _handleTokenExpired();
        return false;
      } else {
        print('❌ [TokenManager] Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 [TokenManager] Exception during token refresh: $e');
      print('💥 [TokenManager] Exception type: ${e.runtimeType}');
      return false;
    }
  }

  /// Handle token expiration
  void _handleTokenExpired() {
    print('⚠️ [TokenManager] Token expired - logging out user');
    
    // Stop the refresh timer
    _refreshTimer?.cancel();
    _refreshTimer = null;
    
    // Clear token
    _token = null;
    
    // Call the callback to handle logout
    if (_onTokenExpired != null) {
      _onTokenExpired!();
    }
  }

  /// Stop auto-refresh (call on logout)
  void dispose() {
    print('🛑 [TokenManager] Disposing token manager');
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _token = null;
    _onTokenExpired = null;
  }

  /// Check if token is still valid (optional - for manual checks)
  bool get hasValidToken => _token != null && _token!.isNotEmpty;
}