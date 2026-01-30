import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/config/api_config.dart';
import 'dart:convert';
import '../services/token_manager.dart';

class DtrWidget extends StatefulWidget {
  final String? token;
  final String baseUrl;
  final String userId;

  const DtrWidget({
    Key? key,
    this.token,
    required this.baseUrl,
    required this.userId,
  }) : super(key: key);

  @override
  State<DtrWidget> createState() => _DtrWidgetState();
}

class _DtrWidgetState extends State<DtrWidget> {
  List<Map<String, dynamic>> _dtrRecords = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDtrRecords();
  }

  Future<void> _fetchDtrRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Build the DTR URL
      final dtrUrl = '${widget.baseUrl}${ApiConfig.dtrEndpoint}/${widget.userId}';
      
      print('📅 [DTR] Fetching from: $dtrUrl');

      // Get current token
      final token = TokenManager().token ?? widget.token;

      // Fetch DTR data with authentication
      final response = await http.get(
        Uri.parse(dtrUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📅 [DTR] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['message'] == 'Successful' && data['dtrList'] != null) {
          setState(() {
            _dtrRecords = List<Map<String, dynamic>>.from(data['dtrList']);
            _isLoading = false;
          });
          print('✅ [DTR] Loaded ${_dtrRecords.length} records');
        } else {
          setState(() {
            _error = 'No DTR records found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load DTR: ${response.statusCode}';
          _isLoading = false;
        });
        print('❌ [DTR] Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading DTR: $e';
        _isLoading = false;
      });
      print('❌ [DTR] Error: $e');
    }
  }

  String _formatTime(dynamic timeValue) {
    if (timeValue == null || timeValue.toString().isEmpty || timeValue == 0) {
      return '--:--';
    }
    
    try {
      String timeStr = timeValue.toString();
      // Expected format: "2025-08-01T07:44:49" or "07:44:49"
      
      // Extract time part if it's a full datetime
      if (timeStr.contains('T')) {
        timeStr = timeStr.split('T')[1];
      }
      
      // Parse hours, minutes, seconds
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        
        // Convert to 12-hour format
        // String period = hours >= 12;
        int displayHours = hours % 12;
        if (displayHours == 0) displayHours = 12;
        
        return '${displayHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    
    return timeValue.toString();
  }

  String _formatMinutes(dynamic minutes) {
    if (minutes == null || minutes == 0) {
      return '0';
    }
    return minutes.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDtrRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00674F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_dtrRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No DTR records available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header section with refresh button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C5F4F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DAILY TIME RECORD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: _fetchDtrRecords,
                        tooltip: 'Refresh',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                // DTR records list
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(_dtrRecords.length, (index) {
                      final record = _dtrRecords[index];
                      return _buildDtrCard(record);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtrCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF00674F)),
                    const SizedBox(width: 8),
                    Text(
                      record['date'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00674F),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record['isUpdated'] == true 
                        ? Colors.orange.shade100 
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['isUpdated'] == true ? 'Updated' : 'OLD',
                    style: TextStyle(
                      fontSize: 12,
                      color: record['isUpdated'] == true 
                          ? Colors.orange.shade900 
                          : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Time entries
            _buildTimeSection('Morning', 
              'In: ${_formatTime(record['amIn'])}',
              'Out: ${_formatTime(record['amOut'])}',
            ),
            const SizedBox(height: 12),
            _buildTimeSection('Afternoon', 
              'In: ${_formatTime(record['pmIn'])}',
              'Out: ${_formatTime(record['pmOut'])}',
            ),
            
            const Divider(height: 24),
            
            // Hours summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHoursInfo(
                  'Undertime',
                  _formatMinutes(record['undertime']),
                  Colors.orange,
                ),
                _buildHoursInfo(
                  'OT Hours',
                  _formatMinutes(record['utHours']),
                  Colors.blue,
                ),
                _buildHoursInfo(
                  'OT Minutes',
                  _formatMinutes(record['utMinutes']),
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(String title, String timeIn, String timeOut) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Text(
                timeIn,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                timeOut,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}