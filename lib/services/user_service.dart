import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class UserService {
  Future<Map<String, dynamic>> getUserDetails(String token) async {
    print('👤 [UserService] Fetching user profile with token...');
    print('🎫 [UserService] Token: ${token.substring(0, 20)}...');
    print('🌐 [UserService] API URL: ${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}');
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
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
}