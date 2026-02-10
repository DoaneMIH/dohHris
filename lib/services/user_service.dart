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
    print(
      '🌐 [UserService] API URL: ${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}',
    );

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

        return {'success': true, 'data': data['users']};
      } else {
        print(
          '❌ [UserService] Failed to load user profile: ${response.statusCode}',
        );
        return {
          'success': false,
          'error': 'Failed to load user profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [UserService] Exception occurred: $e');
      print('💥 [UserService] Exception type: ${e.runtimeType}');
      return {'success': false, 'error': 'Error: $e'};
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
    if (_cachedUserData == null ||
        _cachedUserData!['employeeId'] != employeeId) {
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

    print(
      '📝 [UserService] Filtered ${filteredPersonalData.length} fields with values from ${personalData.length} total fields',
    );
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
      print(
        '📤 [UserService] Form-data value (first 200 chars): ${jsonEncode(mergedData).substring(0, mergedData.length > 200 ? 200 : mergedData.length)}...',
      );

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

          return {'success': true, 'data': data};
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
          'error':
              'Failed to update: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e, stackTrace) {
      print('💥 [UserService] EXCEPTION OCCURRED!');
      print('💥 [UserService] Exception: $e');
      print('💥 [UserService] Exception Type: ${e.runtimeType}');
      print('💥 [UserService] Stack Trace:');
      print(stackTrace);
      print('========================================\n');

      return {'success': false, 'error': 'Error: $e'};
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

  Future<Map<String, dynamic>> getFamilyDetails(
    String token,
    String employeeId,
  ) async {
    try {
      final currentToken = TokenManager().token ?? token;
      print(
        '\n🔄 [UserService] Getting family details for employee: $employeeId',
      );
      print('🎫 Using token: ${currentToken.substring(0, 20)}...');

      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getFamilyEndpoint}$employeeId',
      );
      print('🌐 [UserService] Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 [UserService] Response status: ${response.statusCode}');
      print('📦 [UserService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch family details: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [UserService] Error getting family details: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ADD FAMILY MEMBER
  Future<Map<String, dynamic>> addFamilyMember(
    String token,
    String employeeId,
    Map<String, dynamic> familyData,
  ) async {
    print('\n➕ [UserService] ADD FAMILY MEMBER for employee: $employeeId');

    final currentToken = TokenManager().token ?? token;
    final url = '${ApiConfig.baseUrl}${ApiConfig.addFamilyEndpoint}$employeeId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(familyData),
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('💥 Error: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // UPDATE FAMILY MEMBER
  Future<Map<String, dynamic>> updateFamilyMember(
    String token,
    String familyId,
    Map<String, dynamic> familyData,
  ) async {
    print('\n✏️ [UserService] UPDATE FAMILY MEMBER: $familyId');

    final currentToken = TokenManager().token ?? token;
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.updateFamilyEndpoint}$familyId';
    print('🌐 [UserService] Update API URL: $url');
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(familyData),
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('💥 Error: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // DELETE FAMILY MEMBER
  Future<Map<String, dynamic>> deleteFamilyMember(
    String token,
    String familyId,
  ) async {
    print('\n🗑️ [UserService] DELETE FAMILY MEMBER: $familyId');

    final currentToken = TokenManager().token ?? token;
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.deleteFamilyEndpoint}$familyId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('💥 Error: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getEducationDetails(
    String token,
    String employeeId,
  ) async {
    try {
      print(
        '\n🔄 [UserService] Getting family details for employee: $employeeId',
      );

      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getEducationEndpoint}$employeeId',
      );
      print('🌐 [UserService] Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 [UserService] Response status: ${response.statusCode}');
      print('📦 [UserService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch family details: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [UserService] Error getting family details: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // ADD EDUCATION
  Future<Map<String, dynamic>> addEducation(
    String token,
    String employeeId,
    Map<String, dynamic> educationData,
  ) async {
    print('\n➕ [UserService] ADD EDUCATION for employee: $employeeId');

    final currentToken = TokenManager().token ?? token;
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.addEducationEndpoint}$employeeId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(educationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // UPDATE EDUCATION
  Future<Map<String, dynamic>> updateEducation(
    String token,
    String educationId,
    Map<String, dynamic> educationData,
  ) async {
    print('\n✏️ [UserService] UPDATE EDUCATION: $educationId');

    final currentToken = TokenManager().token ?? token;
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.updateEducationEndpoint}$educationId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(educationData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // DELETE EDUCATION
  Future<Map<String, dynamic>> deleteEducation(
    String token,
    String educationId,
  ) async {
    print('\n🗑️ [UserService] DELETE EDUCATION: $educationId');

    final currentToken = TokenManager().token ?? token;
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.deleteEducationEndpoint}$educationId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  // GET WORK EXPERIENCE
Future<Map<String, dynamic>> getWorkExperienceDetails(String token, String employeeId) async {
  try {
    print('\n💼 [UserService] Getting work experience for employee: $employeeId');
    
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getWorkExperienceEndpoint}$employeeId');
    final currentToken = TokenManager().token ?? token;

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': json.decode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': 'Failed: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error: $e',
    };
  }
}

// ADD WORK EXPERIENCE
Future<Map<String, dynamic>> addWorkExperience(
  String token,
  String employeeId,
  Map<String, dynamic> workData,
) async {
  print('\n➕ [UserService] ADD WORK EXPERIENCE for employee: $employeeId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.addWorkExperienceEndpoint}$employeeId';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(workData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

// UPDATE WORK EXPERIENCE
Future<Map<String, dynamic>> updateWorkExperience(
  String token,
  String workId,
  Map<String, dynamic> workData,
) async {
  print('\n✏️ [UserService] UPDATE WORK EXPERIENCE: $workId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.updateWorkExperienceEndpoint}$workId';
  
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(workData),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

// DELETE WORK EXPERIENCE
Future<Map<String, dynamic>> deleteWorkExperience(
  String token,
  String workId,
) async {
  print('\n🗑️ [UserService] DELETE WORK EXPERIENCE: $workId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.deleteWorkExperienceEndpoint}$workId';
  
  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}


// GET VOLUNTARY WORK
Future<Map<String, dynamic>> getVoluntaryWorkDetails(String token, String employeeId) async {
  try {
    print('\n🤝 [UserService] Getting voluntary work for employee: $employeeId');
    
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getVoluntaryWorkEndpoint}$employeeId');
    final currentToken = TokenManager().token ?? token;

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': json.decode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': 'Failed: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error: $e',
    };
  }
}

// ADD VOLUNTARY WORK
Future<Map<String, dynamic>> addVoluntaryWork(
  String token,
  String employeeId,
  Map<String, dynamic> voluntaryData,
) async {
  print('\n➕ [UserService] ADD VOLUNTARY WORK for employee: $employeeId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.addVoluntaryWorkEndpoint}$employeeId';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(voluntaryData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

// UPDATE VOLUNTARY WORK
Future<Map<String, dynamic>> updateVoluntaryWork(
  String token,
  String voluntaryId,
  Map<String, dynamic> voluntaryData,
) async {
  print('\n✏️ [UserService] UPDATE VOLUNTARY WORK: $voluntaryId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.updateVoluntaryWorkEndpoint}$voluntaryId';
  
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(voluntaryData),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

// DELETE VOLUNTARY WORK
Future<Map<String, dynamic>> deleteVoluntaryWork(
  String token,
  String voluntaryId,
) async {
  print('\n🗑️ [UserService] DELETE VOLUNTARY WORK: $voluntaryId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.deleteVoluntaryWorkEndpoint}$voluntaryId';
  
  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

//GET LEARNING AND DEVELOPMENT
Future<Map<String, dynamic>> getLearningDevelopmentDetails(String token, String employeeId) async {
  try {
    print('\n📚 [UserService] Getting learning and development for employee: $employeeId');
    
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getLearningEndpoint}$employeeId');
    final currentToken = TokenManager().token ?? token;

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': json.decode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': 'Failed: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error: $e',
    };
  }
}

// ADD LEARNING AND DEVELOPMENT
Future<Map<String, dynamic>> addLearningDevelopment(
  String token,
  String employeeId,
  Map<String, dynamic> learningData,
) async {
  print('\n➕ [UserService] ADD LEARNING AND DEVELOPMENT for employee: $employeeId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.addLearningEndpoint}$employeeId';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(learningData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

// UPDATE LEARNING AND DEVELOPMENT
Future<Map<String, dynamic>> updateLearningDevelopment(
  String token,
  String learningId,
  Map<String, dynamic> learningData,
) async {
  print('\n✏️ [UserService] UPDATE LEARNING AND DEVELOPMENT: $learningId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.updateLearningEndpoint}$learningId';
  
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(learningData),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  } 
}

// DELETE LEARNING AND DEVELOPMENT
Future<Map<String, dynamic>> deleteLearningDevelopment(
  String token,
  String learningId,
) async {
  print('\n🗑️ [UserService] DELETE LEARNING AND DEVELOPMENT: $learningId');
  
  final currentToken = TokenManager().token ?? token;
  final url = '${ApiConfig.baseUrl}${ApiConfig.deleteLearningEndpoint}$learningId';
  
  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': 'Error: $e'};
  }
}

}
