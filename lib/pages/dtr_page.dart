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
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedMonth;
  int? _selectedYear;
  List<int> _availableYears = [];
  List<int> _availableMonths = [];

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
            // Sort records by date (latest first)
            _dtrRecords.sort((a, b) {
              try {
                DateTime dateA = DateTime.parse(a['date']);
                DateTime dateB = DateTime.parse(b['date']);
                return dateB.compareTo(dateA); // Descending order
              } catch (e) {
                return 0;
              }
            });
            _extractAvailableYearsAndMonths();
            _applyFilters();
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

  void _extractAvailableYearsAndMonths() {
    // Generate years from 2025 to current year
    int currentYear = DateTime.now().year;
    _availableYears = [];
    for (int year = currentYear; year >= 2025; year--) {
      _availableYears.add(year);
    }

    // Extract months from records and sort descending
    Set<int> months = {};
    for (var record in _dtrRecords) {
      try {
        DateTime date = DateTime.parse(record['date']);
        months.add(date.month);
      } catch (e) {
        print('Error parsing date: ${record['date']}');
      }
    }

    _availableMonths = months.toList()..sort((a, b) => b.compareTo(a)); // Descending
    
    // Set default filter to latest month and year if not already set
    if (_selectedMonth == null && _selectedYear == null && _dtrRecords.isNotEmpty) {
      _setDefaultFilter();
    }
  }

  void _setDefaultFilter() {
    // Find the latest date in records
    if (_dtrRecords.isNotEmpty) {
      try {
        DateTime latestDate = DateTime.parse(_dtrRecords.first['date']);
        _selectedMonth = latestDate.month;
        _selectedYear = latestDate.year;
      } catch (e) {
        print('Error setting default filter: $e');
      }
    }
  }

  void _applyFilters() {
    if (_selectedYear == null && _selectedMonth == null) {
      _filteredRecords = List.from(_dtrRecords);
    } else {
      _filteredRecords = _dtrRecords.where((record) {
        try {
          DateTime date = DateTime.parse(record['date']);
          bool yearMatch = _selectedYear == null || date.year == _selectedYear;
          bool monthMatch = _selectedMonth == null || date.month == _selectedMonth;
          return yearMatch && monthMatch;
        } catch (e) {
          return false;
        }
      }).toList();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? tempMonth = _selectedMonth;
        int? tempYear = _selectedYear;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Filter DTR Records',
                style: TextStyle(
                  color: Color(0xFF00674F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Dropdown
                  DropdownButtonFormField<int>(
                    value: tempYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF00674F)),
                    ),
                    hint: const Text('Select Year'),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Years'),
                      ),
                      ..._availableYears.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Month Dropdown
                  DropdownButtonFormField<int>(
                    value: tempMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range, color: Color(0xFF00674F)),
                    ),
                    hint: const Text('Select Month'),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Months'),
                      ),
                      // Generate months in descending order (12 to 1)
                      ...List.generate(12, (index) {
                        int month = 12 - index; // Start from December (12) down to January (1)
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempMonth = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = tempMonth;
                      _selectedYear = tempYear;
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00674F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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
            style: TextStyle(fontSize: 16, 
            // color: Colors.grey
            ),
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
                // Header section with filter and refresh buttons
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
                      Row(
                        children: [
                          // Filter button
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                                onPressed: _showFilterDialog,
                                tooltip: 'Filter by Month/Year',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              // Badge to show active filters
                              if (_selectedMonth != null || _selectedYear != null)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(
                                      minWidth: 8,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Refresh button
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                            onPressed: _fetchDtrRecords,
                            tooltip: 'Refresh',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Active filters display
                // if (_selectedMonth != null || _selectedYear != null)
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     color: Colors.blue.shade50,
                //     child: Row(
                //       children: [
                //         const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                //         const SizedBox(width: 8),
                //         Expanded(
                //           child: Text(
                //             'Filtered: ${_selectedMonth != null ? _getMonthName(_selectedMonth!) : 'All Months'} ${_selectedYear != null ? _selectedYear : 'All Years'}',
                //             style: const TextStyle(
                //               fontSize: 12,
                //               color: Colors.blue,
                //             ),
                //           ),
                //         ),
                //         TextButton(
                //           onPressed: () {
                //             setState(() {
                //               _selectedMonth = null;
                //               _selectedYear = null;
                //               _applyFilters();
                //             });
                //           },
                //           style: TextButton.styleFrom(
                //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //             minimumSize: Size.zero,
                //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //           ),
                //           child: const Text(
                //             'Clear',
                //             style: TextStyle(fontSize: 12),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                
                // DTR records list
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _filteredRecords.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No records found for selected filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(_filteredRecords.length, (index) {
                            final record = _filteredRecords[index];
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
      color: Colors.white,
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
                  const Color.fromARGB(255, 126, 126, 126),
                ),
                _buildHoursInfo(
                  'OT Hours',
                  _formatMinutes(record['utHours']),
                  const Color.fromARGB(255, 126, 126, 126),
                ),
                _buildHoursInfo(
                  'OT Minutes',
                  _formatMinutes(record['utMinutes']),
                  const Color.fromARGB(255, 126, 126, 126),
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
        color: Colors.white,
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