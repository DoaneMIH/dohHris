import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class UserService {
  Future<Map<String, dynamic>> getUserDetails(String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['users'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load user details: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }
}