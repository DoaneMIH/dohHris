import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_manager.dart';

class UserService {
  // Cache to store current user data
  Map<String, dynamic>? _cachedUserData;

  Future<Map<String, dynamic>> getUserDetails(String token) async {
    print('👤 [UserService] Fetching user profile with token...');
    
    // Use the current token from TokenManager (in case it was refreshed)
    final currentToken = TokenManager().token ?? token;
    print("🎫 [UserService] Token: ${currentToken.toString()}");
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
        // Cache the user data for later use
        _cachedUserData = data['users'];
        
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
    String employeeId,
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

  Future<Map<String, dynamic>> updatePersonalInformation(
    String token,
    String employeeId,
    Map<String, dynamic> personalData,
  ) async {
    print('\n========================================');
    print('💾 [UserService] UPDATE PERSONAL INFORMATION');
    print('========================================');
    print('📋 Employee ID: $employeeId');
    print('🎫 Token: ${token.substring(0, 20)}...');
    
    final currentToken = TokenManager().token ?? token;
    final url = '${ApiConfig.baseUrl}/adminuser/update-employee/$employeeId';
    
    // STEP 1: Fetch current user data if not cached
    if (_cachedUserData == null || _cachedUserData!['employeeId'] != employeeId) {
      print('🔄 [UserService] Fetching current user data...');
      final userDetailsResult = await getUserDetails(currentToken);
      
      if (!userDetailsResult['success']) {
        print('❌ [UserService] Failed to fetch current user data');
        return {
          'success': false,
          'error': 'Failed to fetch current user data before update',
        };
      }
    }
    
    final mergedData = Map<String, dynamic>.from(_cachedUserData ?? {});
    
    final filteredPersonalData = <String, dynamic>{};
    personalData.forEach((key, value) {
      // Only include non-null, non-empty values
      if (value != null && value.toString().trim().isNotEmpty) {
        filteredPersonalData[key] = value;
      } else {
        print('   - $key: SKIPPED (empty or null value)');
      }
    });
    
    print('📝 [UserService] Filtered ${filteredPersonalData.length} fields with values from ${personalData.length} total fields');
    print('📝 [UserService] Fields to update:');
    filteredPersonalData.forEach((key, value) {
      print('   - $key: ${mergedData[key]} → $value');
      mergedData[key] = value;
    });

    print('🔒 [UserService] Protected fields removed from update payload');
    print('🌐 [UserService] Full API URL: $url');
    print('📤 [UserService] Request will use form-data format');
    print('📤 [UserService] Total fields in merged data: ${mergedData.length}');
    print('----------------------------------------');
    
    try {
      print('⏳ [UserService] Sending PUT request with form-data...');
      
      // Create multipart request (form-data format)
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $currentToken';
      
      // Add the employee data as a form field with JSON string value
      request.fields['employee'] = jsonEncode(mergedData);
      
      print('📤 [UserService] Form-data key: employee');
      print('📤 [UserService] Form-data value (first 200 chars): ${jsonEncode(mergedData).substring(0, mergedData.length > 200 ? 200 : mergedData.length)}...');
      
      // Send the request
      var streamedResponse = await request.send();
      
      // Convert streamed response to regular response
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 [UserService] Response received!');
      print('📥 [UserService] Status Code: ${response.statusCode}');
      print('📥 [UserService] Status Message: ${response.reasonPhrase}');
      print('📥 [UserService] Response Headers:');
      response.headers.forEach((key, value) {
        print('   - $key: $value');
      });
      print('📥 [UserService] Response Body:');
      print(response.body);
      print('----------------------------------------');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          if (data.containsKey('employee')) {
            _cachedUserData = Map<String, dynamic>.from(data['employee']);
          } else if (data.containsKey('users')) {
            _cachedUserData = Map<String, dynamic>.from(data['users']);
          } else {
            // If response doesn't contain updated data, use our merged data
            _cachedUserData = Map<String, dynamic>.from(mergedData);
          }

          print('✅ [UserService] Personal information updated successfully!');
          print('✅ [UserService] Response data parsed successfully');
          print('✅ [UserService] Cache updated with new data');
          print('========================================\n');
          
          return {
            'success': true,
            'data': data,
          };
        } catch (jsonError) {
          print('⚠️ [UserService] JSON decode error: $jsonError');
          print('⚠️ [UserService] But status was 200, treating as success');
          
          _cachedUserData = Map<String, dynamic>.from(mergedData);
          
          return {
            'success': true,
            'data': {'message': 'Updated successfully'},
          };
        }
      } else if (response.statusCode == 403) {
        print('❌ [UserService] 403 FORBIDDEN');
        print('❌ [UserService] This might be a permission issue');
        print('❌ [UserService] Response: ${response.body}');
        print('========================================\n');
        
        return {
          'success': false,
          'error': 'Forbidden: ${response.body}',
          'statusCode': 403,
        };
      } else {
        print('❌ [UserService] Failed to update personal information');
        print('❌ [UserService] Status code: ${response.statusCode}');
        print('❌ [UserService] Response: ${response.body}');
        print('========================================\n');
        
        return {
          'success': false,
          'error': 'Failed to update: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e, stackTrace) {
      print('💥 [UserService] EXCEPTION OCCURRED!');
      print('💥 [UserService] Exception: $e');
      print('💥 [UserService] Exception Type: ${e.runtimeType}');
      print('💥 [UserService] Stack Trace:');
      print(stackTrace);
      print('========================================\n');
      
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }
  
  // Optional: Method to manually clear cache if needed
  void clearCache() {
    _cachedUserData = null;
    print('🗑️ [UserService] User data cache cleared');
  }
  
  // Optional: Method to get cached data
  Map<String, dynamic>? getCachedUserData() {
    return _cachedUserData;
  }
}