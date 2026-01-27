import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_manager.dart';

class UserService {
  Future<Map<String, dynamic>> getUserDetails(String token) async {
    print('👤 [UserService] Fetching user profile with token...');
    
    // Use the current token from TokenManager (in case it was refreshed)
    final currentToken = TokenManager().token ?? token;
    print('🎫 [UserService] Token: ${currentToken.substring(0, 20)}...');
    print('🌐 [UserService] API URL: ${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}');
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [UserService] Response status code: ${response.statusCode}');
      print('📥 [UserService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [UserService] User profile fetched successfully!');
        print('👤 [UserService] User name: ${data['users']?['name']}');
        print('📧 [UserService] User email: ${data['users']?['email']}');
        
        return {
          'success': true,
          'data': data['users'],
        };
      } else {
        print('❌ [UserService] Failed to load user profile: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Failed to load user profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [UserService] Exception occurred: $e');
      print('💥 [UserService] Exception type: ${e.runtimeType}');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUserDetails(
    String token,
    Map<String, dynamic> updatedData,
  ) async {
    print('💾 [UserService] Updating user profile...');
    
    // Use the current token from TokenManager (in case it was refreshed)
    final currentToken = TokenManager().token ?? token;
    print('🎫 [UserService] Token: ${currentToken.substring(0, 20)}...');
    print('📤 [UserService] Updated data: $updatedData');
    print('🌐 [UserService] API URL: ${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}');
    
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      print('📥 [UserService] Response status code: ${response.statusCode}');
      print('📥 [UserService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [UserService] User profile updated successfully!');
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ [UserService] Failed to update user profile: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Failed to update user profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [UserService] Exception occurred: $e');
      print('💥 [UserService] Exception type: ${e.runtimeType}');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }
}