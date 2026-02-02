import 'package:http/http.dart' as http;
import 'package:mobile_application/config/api_config.dart';
import 'dart:convert';
import '../services/token_manager.dart';

class DtrService {
  final String baseUrl;
  final String? token;

  DtrService({
    required this.baseUrl,
    this.token,
  });

  /// Fetch DTR records for a specific user
  Future<DtrResponse> fetchDtrRecords(String userId) async {
    try {
      // Build the DTR URL
      // final dtrUrl = '$baseUrl/employee/dtr/$userId';
      final dtrUrl = '$baseUrl${ApiConfig.dtrEndpoint}/$userId';
      
      print('📅 [DTR Service] Fetching from: $dtrUrl');

      // Get current token
      final authToken = TokenManager().token ?? token;
      print('[DTR Service] token: ${authToken.toString()}');

      if (authToken == null) {
        return DtrResponse(
          success: false,
          error: 'Authentication token not available',
        );
      }

      print("🎫 [DTR Service] Using token for authentication");

      // Fetch DTR data with authentication
      final response = await http.get(
        Uri.parse(dtrUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('📅 [DTR Service] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['message'] == 'Successful' && data['dtrList'] != null) {
          final records = List<Map<String, dynamic>>.from(data['dtrList']);
          
          // Sort records by date (latest first)
          records.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              return 0;
            }
          });

          print('✅ [DTR Service] Loaded ${records.length} records');
          
          return DtrResponse(
            success: true,
            records: records,
          );
        } else {
          return DtrResponse(
            success: false,
            error: 'No DTR records found',
          );
        }
      } else if (response.statusCode == 401) {
        return DtrResponse(
          success: false,
          error: 'Unauthorized - Please login again',
        );
      } else if (response.statusCode == 404) {
        return DtrResponse(
          success: false,
          error: 'DTR records not found for this user',
        );
      } else {
        return DtrResponse(
          success: false,
          error: 'Failed to load DTR: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [DTR Service] Error: $e');
      return DtrResponse(
        success: false,
        error: 'Error loading DTR: $e',
      );
    }
  }

  /// Fetch DTR records for a specific month and year
  Future<DtrResponse> fetchDtrRecordsByMonth(
    String userId, {
    int? month,
    int? year,
  }) async {
    final response = await fetchDtrRecords(userId);
    
    if (!response.success || response.records == null) {
      return response;
    }

    // Filter by month and year if provided
    if (month == null && year == null) {
      return response;
    }

    final filteredRecords = response.records!.where((record) {
      try {
        DateTime date = DateTime.parse(record['date']);
        bool yearMatch = year == null || date.year == year;
        bool monthMatch = month == null || date.month == month;
        return yearMatch && monthMatch;
      } catch (e) {
        return false;
      }
    }).toList();

    return DtrResponse(
      success: true,
      records: filteredRecords,
    );
  }

  /// Extract available years from records
  static List<int> extractAvailableYears(List<Map<String, dynamic>> records) {
    int currentYear = DateTime.now().year;
    List<int> availableYears = [];
    
    for (int year = currentYear; year >= 2025; year--) {
      availableYears.add(year);
    }
    
    return availableYears;
  }

  /// Extract available months from records
  static List<int> extractAvailableMonths(List<Map<String, dynamic>> records) {
    Set<int> months = {};
    
    for (var record in records) {
      try {
        DateTime date = DateTime.parse(record['date']);
        months.add(date.month);
      } catch (e) {
        print('Error parsing date: ${record['date']}');
      }
    }

    return months.toList()..sort((a, b) => b.compareTo(a)); // Descending
  }

  /// Get the default filter (latest month and year from records)
  static Map<String, int>? getDefaultFilter(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return null;

    try {
      DateTime latestDate = DateTime.parse(records.first['date']);
      return {
        'month': latestDate.month,
        'year': latestDate.year,
      };
    } catch (e) {
      print('Error setting default filter: $e');
      return null;
    }
  }
}

/// Response model for DTR service
class DtrResponse {
  final bool success;
  final List<Map<String, dynamic>>? records;
  final String? error;

  DtrResponse({
    required this.success,
    this.records,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'DtrResponse(success: $success, records: ${records?.length ?? 0})';
    } else {
      return 'DtrResponse(success: $success, error: $error)';
    }
  }
}