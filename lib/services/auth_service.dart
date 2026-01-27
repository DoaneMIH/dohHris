import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔐 [AuthService] Starting login process...');
    print('📧 [AuthService] Email: $email');
    print('🌐 [AuthService] API URL: ${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
    
    try {
      final requestBody = {
        'email': email,
        'password': password,
      };
      print('📤 [AuthService] Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 [AuthService] Response status code: ${response.statusCode}');
      print('📥 [AuthService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AuthService] Login successful!');
        print('🎫 [AuthService] Token received: ${data['token']?.substring(0, 20)}...');
        print('👤 [AuthService] User ID: ${data['employee']?['id']}');
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ [AuthService] Login failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Login failed: ${response.body}',
        };
      }
    } catch (e) {
      print('💥 [AuthService] Exception occurred: $e');
      print('💥 [AuthService] Exception type: ${e.runtimeType}');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }
}