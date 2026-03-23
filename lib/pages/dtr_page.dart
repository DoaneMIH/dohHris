// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_application/config/api_config.dart';
// import 'dart:convert';
// import '../services/token_manager.dart';

// class DtrWidget extends StatefulWidget {
//   final String? token;
//   final String baseUrl;
//   final String userId;

//   const DtrWidget({
//     Key? key,
//     this.token,
//     required this.baseUrl,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   State<DtrWidget> createState() => _DtrWidgetState();
// }

// class _DtrWidgetState extends State<DtrWidget> {
//   List<Map<String, dynamic>> _dtrRecords = [];
//   List<Map<String, dynamic>> _filteredRecords = [];
//   bool _isLoading = false;
//   String? _error;
//   int? _selectedMonth;
//   int? _selectedYear;
//   List<int> _availableYears = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchDtrRecords();
//   }

//   Future<void> _fetchDtrRecords() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final dtrUrl = '${widget.baseUrl}${ApiConfig.dtrEndpoint}/${widget.userId}';
//       print('📅 [DTR] Fetching from: $dtrUrl');

//       final token = TokenManager().token ?? widget.token;

//       final response = await http.get(
//         Uri.parse(dtrUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       print('📅 [DTR] Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['message'] == 'Successful' && data['dtrList'] != null) {
//           setState(() {
//             _dtrRecords = List<Map<String, dynamic>>.from(data['dtrList']);
//             _dtrRecords.sort((a, b) {
//               try {
//                 DateTime dateA = DateTime.parse(a['date']);
//                 DateTime dateB = DateTime.parse(b['date']);
//                 return dateB.compareTo(dateA);
//               } catch (e) {
//                 return 0;
//               }
//             });
//             _extractAvailableYearsAndMonths();
//             _applyFilters();
//             _isLoading = false;
//           });
//           print('✅ [DTR] Loaded ${_dtrRecords.length} records');
//         } else {
//           setState(() {
//             _error = 'No DTR records found';
//             _isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           _error = 'Failed to load DTR: ${response.statusCode}';
//           _isLoading = false;
//         });
//         print('❌ [DTR] Failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Error loading DTR: $e';
//         _isLoading = false;
//       });
//       print('❌ [DTR] Error: $e');
//     }
//   }

//   void _extractAvailableYearsAndMonths() {
//     int currentYear = DateTime.now().year;
//     _availableYears = [];
//     for (int year = currentYear; year >= 2025; year--) {
//       _availableYears.add(year);
//     }

//     Set<int> months = {};
//     for (var record in _dtrRecords) {
//       try {
//         DateTime date = DateTime.parse(record['date']);
//         months.add(date.month);
//       } catch (e) {
//         print('Error parsing date: ${record['date']}');
//       }
//     }

//     if (_selectedMonth == null && _selectedYear == null && _dtrRecords.isNotEmpty) {
//       _setDefaultFilter();
//     }
//   }

//   void _setDefaultFilter() {
//     if (_dtrRecords.isNotEmpty) {
//       try {
//         DateTime latestDate = DateTime.parse(_dtrRecords.first['date']);
//         _selectedMonth = latestDate.month;
//         _selectedYear = latestDate.year;
//       } catch (e) {
//         print('Error setting default filter: $e');
//       }
//     }
//   }

//   void _applyFilters() {
//     if (_selectedYear == null && _selectedMonth == null) {
//       _filteredRecords = List.from(_dtrRecords);
//     } else {
//       _filteredRecords = _dtrRecords.where((record) {
//         try {
//           DateTime date = DateTime.parse(record['date']);
//           bool yearMatch = _selectedYear == null || date.year == _selectedYear;
//           bool monthMatch = _selectedMonth == null || date.month == _selectedMonth;
//           return yearMatch && monthMatch;
//         } catch (e) {
//           return false;
//         }
//       }).toList();
//     }
//   }

//   // ─── Bottom Sheet helpers ──────────────────────────────────────────────────

//   Future<void> _showOptionsBottomSheet({
//     required BuildContext ctx,
//     required String title,
//     required List<String> options,
//     required String? currentValue,
//     required void Function(String) onSelected,
//   }) async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     await showModalBottomSheet(
//       context: ctx,
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(ctx).size.height * 0.6,
//       ),
//       builder: (sheetCtx) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 10, bottom: 6),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//               const Divider(height: 1),
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: options.length,
//                   itemBuilder: (_, index) {
//                     final option = options[index];
//                     final isSelected = option == currentValue;
//                     return InkWell(
//                       onTap: () {
//                         onSelected(option);
//                         Navigator.of(sheetCtx).pop();
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 14),
//                         color: isSelected
//                             ? Theme.of(context).primaryColor.withOpacity(0.08)
//                             : Colors.transparent,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 option,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: isSelected
//                                       ? Theme.of(context).primaryColor
//                                       : Theme.of(context).textTheme.bodyMedium?.color,
//                                   fontWeight: isSelected
//                                       ? FontWeight.w600
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                             if (isSelected)
//                               Icon(Icons.check,
//                                   size: 18, color: Theme.of(context).primaryColor),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSelector({
//     required String label,
//     required String? selectedValue,
//     required BuildContext ctx,
//     required List<String> options,
//     required void Function(String) onChanged,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return GestureDetector(
//       onTap: () => _showOptionsBottomSheet(
//         ctx: ctx,
//         title: 'Select $label',
//         options: options,
//         currentValue: selectedValue,
//         onSelected: onChanged,
//       ),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         child: Row(
//           children: [
//             Expanded(
//               child: selectedValue == null || selectedValue.isEmpty
//                   ? Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isDark ? Colors.grey[400] : Colors.grey,
//                       ),
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           label,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           selectedValue,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Theme.of(context).textTheme.bodyMedium?.color,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//             Icon(
//               Icons.arrow_drop_down,
//               size: 22,
//               color: isDark ? Colors.grey[400] : Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─── Filter Dialog ─────────────────────────────────────────────────────────

//   void _showFilterDialog() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         int? tempMonth = _selectedMonth;
//         int? tempYear = _selectedYear;

//         return StatefulBuilder(
//           builder: (dialogContext, setDialogState) {
//             final yearOptions =
//                 _availableYears.map((y) => y.toString()).toList();
//             final monthOptions = List.generate(12, (i) => _getMonthName(i + 1));

//             return Dialog(
//               backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               insetPadding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(dialogContext).size.width * 0.1,
//                 vertical: 24,
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // ── Header ──
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         topRight: Radius.circular(12),
//                       ),
//                     ),
//                     child: const Row(
//                       children: [
//                         SizedBox(width: 8),
//                         Text(
//                           'Filter DTR Records',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ── Body ──
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildSelector(
//                           label: 'Year',
//                           selectedValue: tempYear?.toString(),
//                           ctx: dialogContext,
//                           options: yearOptions,
//                           onChanged: (v) => setDialogState(
//                               () => tempYear = int.tryParse(v)),
//                         ),
//                         const SizedBox(height: 12),
//                         _buildSelector(
//                           label: 'Month',
//                           selectedValue: tempMonth != null
//                               ? _getMonthName(tempMonth!)
//                               : null,
//                           ctx: dialogContext,
//                           options: monthOptions,
//                           onChanged: (v) => setDialogState(() =>
//                               tempMonth = monthOptions.indexOf(v) + 1),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   // ── Actions ──
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _selectedMonth = tempMonth;
//                                 _selectedYear = tempYear;
//                                 _applyFilters();
//                               });
//                               Navigator.of(dialogContext).pop();
//                             },
//                             style: OutlinedButton.styleFrom(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.check, size: 16),
//                                 SizedBox(width: 6),
//                                 Text('Apply'),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () =>
//                                 Navigator.of(dialogContext).pop(),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[200],
//                               foregroundColor: isDark
//                                   ? Colors.white
//                                   : Colors.black87,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ─── Helpers ───────────────────────────────────────────────────────────────

//   String _getMonthName(int month) {
//     const months = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return months[month - 1];
//   }

//   String _formatTime(dynamic timeValue) {
//     if (timeValue == null || timeValue.toString().isEmpty || timeValue == 0) {
//       return '--:--';
//     }
//     try {
//       String timeStr = timeValue.toString();
//       if (timeStr.contains('T')) {
//         timeStr = timeStr.split('T')[1];
//       }
//       List<String> parts = timeStr.split(':');
//       if (parts.length >= 2) {
//         int hours = int.parse(parts[0]);
//         int minutes = int.parse(parts[1]);
//         int displayHours = hours % 12;
//         if (displayHours == 0) displayHours = 12;
//         return '${displayHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
//       }
//     } catch (e) {
//       print('Error formatting time: $e');
//     }
//     return timeValue.toString();
//   }

//   String _formatMinutes(dynamic minutes) {
//     if (minutes == null || minutes == 0) return '0';
//     return minutes.toString();
//   }

//   String _formatDateWithDay(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return 'N/A';
//     try {
//       DateTime date = DateTime.parse(dateStr);
//       List<String> days = [
//         'Monday', 'Tuesday', 'Wednesday', 'Thursday',
//         'Friday', 'Saturday', 'Sunday'
//       ];
//       String dayOfWeek = days[date.weekday - 1];
//       return '$dateStr ($dayOfWeek)';
//     } catch (e) {
//       print('Error formatting date: $e');
//       return dateStr;
//     }
//   }

//   // ─── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Center(child: CircularProgressIndicator(color: Colors.white)),
//       );
//     }

//     if (_error != null) {
//       return Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(_error!,
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchDtrRecords,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_dtrRecords.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Center(
//           child: Text('No DTR records available',
//               style: TextStyle(fontSize: 16)),
//         ),
//       );
//     }

//     return Container(
//       padding: EdgeInsets.zero,
//       child: Column(
//         children: [
//           // ── Header bar ──
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'DAILY TIME RECORD',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: _showFilterDialog,
//                       child: Stack(
//                         children: [
//                           const Icon(Icons.filter_list,
//                               color: Colors.white, size: 20),
//                           if (_selectedMonth != null || _selectedYear != null)
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 width: 6,
//                                 height: 6,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     GestureDetector(
//                       onTap: _fetchDtrRecords,
//                       child: const Icon(Icons.refresh,
//                           color: Colors.white, size: 20),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ── DTR records list ──
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _filteredRecords.isEmpty
//                 ? const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20.0),
//                       child: Text(
//                         'No records found for selected filters',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color.fromARGB(255, 255, 255, 255),
//                         ),
//                       ),
//                     ),
//                   )
//                 : Column(
//                     children: List.generate(_filteredRecords.length, (index) {
//                       final record = _filteredRecords[index];
//                       return _buildDtrCard(record);
//                     }),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDtrCard(Map<String, dynamic> record) {
//     // ✅ Respects light/dark theme automatically
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardColor = Theme.of(context).scaffoldBackgroundColor;  // ✅ Use scaffold background for cards to ensure contrast
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade700;

//     return Card(
//       elevation: 0,
//       color: cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.calendar_today,
//     size: 20, color: isDark ? Colors.white : Theme.of(context).primaryColor),
//                 const SizedBox(width: 5),
//                 Text(
//                   _formatDateWithDay(record['date']),
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             _buildTimeSection(
//               'Morning',
//               'In: ${_formatTime(record['amIn'])}',
//               'Out: ${_formatTime(record['amOut'])}',
//               textColor: textColor,
//               subTextColor: subTextColor,
//             ),
//             _buildTimeSection(
//               'Afternoon',
//               'In: ${_formatTime(record['pmIn'])}',
//               'Out: ${_formatTime(record['pmOut'])}',
//               textColor: textColor,
//               subTextColor: subTextColor,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildHoursInfo('Undertime',
//                     _formatMinutes(record['undertime']), subTextColor),
//                 _buildHoursInfo('OT Hours',
//                     _formatMinutes(record['utHours']), subTextColor),
//                 _buildHoursInfo('OT Minutes',
//                     _formatMinutes(record['utMinutes']), subTextColor),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Divider(
//               height: 20,
//               color: isDark ? Colors.grey[700] : Colors.grey[300],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeSection(
//     String title,
//     String timeIn,
//     String timeOut, {
//     required Color textColor,
//     required Color subTextColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       decoration: const BoxDecoration(color: Colors.transparent),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title,
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: textColor)),        // ✅ theme-aware
//           Row(
//             children: [
//               Text(timeIn,
//                   style: TextStyle(fontSize: 13, color: subTextColor)),  // ✅ theme-aware
//               const SizedBox(width: 12),
//               Text(timeOut,
//                   style: TextStyle(fontSize: 13, color: subTextColor)),  // ✅ theme-aware
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHoursInfo(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(value,
//             style: TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: color)),
//         const SizedBox(height: 4),
//         Text(label,
//             style: TextStyle(fontSize: 12, color: color)),              // ✅ theme-aware
//       ],
//     );
//   }
// }

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

  // ── Static const colors ───────────────────────────────────────────────────
  static const Color _grey300 = Color(0xFFE0E0E0);

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
      final dtrUrl = '${widget.baseUrl}${ApiConfig.dtrEndpoint}/${widget.userId}';
      print('📅 [DTR] Fetching from: $dtrUrl');

      final token = TokenManager().token ?? widget.token;

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
            _dtrRecords.sort((a, b) {
              try {
                DateTime dateA = DateTime.parse(a['date']);
                DateTime dateB = DateTime.parse(b['date']);
                return dateB.compareTo(dateA);
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
    int currentYear = DateTime.now().year;
    _availableYears = [];
    for (int year = currentYear; year >= 2025; year--) {
      _availableYears.add(year);
    }

    Set<int> months = {};
    for (var record in _dtrRecords) {
      try {
        DateTime date = DateTime.parse(record['date']);
        months.add(date.month);
      } catch (e) {
        print('Error parsing date: ${record['date']}');
      }
    }

    if (_selectedMonth == null && _selectedYear == null && _dtrRecords.isNotEmpty) {
      _setDefaultFilter();
    }
  }

  void _setDefaultFilter() {
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

  // ─── NEW: Filter Dialog with Bottom Sheet (matches loan page) ─────────────

void _showFilterDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    isScrollControlled: true, 
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,  
    ),  
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filter DTR Records',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF587CA5)
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 14),

              // ── Year Section ──
              Text(
                'Year',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              // ← Changed to Column with stretch
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _availableYears.map((year) {
                  final selected = _selectedYear == year;
                  return Padding(
                    padding: EdgeInsets.zero, 
                    child: SizedBox(
                      width: double.infinity,  // ← Full width
                      child: ChoiceChip(
                        label: Center(child: Text(year.toString())),  // ← Center text
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            _selectedYear = selected ? null : year;
                            _applyFilters();
                          });
                          Navigator.pop(ctx);
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF587CA5)
                                  : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF587CA5)
                              : Theme.of(context).primaryColor,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Month Section ──
              Text(
                'Month',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(12, (index) {
                  final month = index + 1;
                  final monthName = _getMonthName(month);
                  final selected = _selectedMonth == month;
                  return Padding(
                    padding: EdgeInsets.zero, 
                    child: SizedBox(
                      width: double.infinity,  // ← Full width
                      child: ChoiceChip(
                        label: Center(child: Text(monthName)),  // ← Center text
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            _selectedMonth = selected ? null : month;
                            _applyFilters();
                          });
                          Navigator.pop(ctx);
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF587CA5)
                                  : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF587CA5)
                              : Theme.of(context).primaryColor,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatTime(dynamic timeValue) {
    if (timeValue == null || timeValue.toString().isEmpty || timeValue == 0) {
      return '--:--';
    }
    try {
      String timeStr = timeValue.toString();
      if (timeStr.contains('T')) {
        timeStr = timeStr.split('T')[1];
      }
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
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
    if (minutes == null || minutes == 0) return '0';
    return minutes.toString();
  }

  String _formatDateWithDay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      String dayOfWeek = days[date.weekday - 1];
      return '$dateStr ($dayOfWeek)';
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
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
            Text(_error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDtrRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
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
          child: Text('No DTR records available', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    if (_selectedMonth != null || _selectedYear != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedYear != null && _selectedMonth != null
                              ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
                              : _selectedYear != null
                                  ? '$_selectedYear'
                                  : _getMonthName(_selectedMonth!),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _fetchDtrRecords,
                      child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── DTR records list ──
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
    );
  }

  Widget _buildDtrCard(Map<String, dynamic> record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade700;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20,
                    color: isDark ? Colors.white : Theme.of(context).primaryColor),
                const SizedBox(width: 5),
                Text(
                  _formatDateWithDay(record['date']),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTimeSection(
              'Morning',
              'In: ${_formatTime(record['amIn'])}',
              'Out: ${_formatTime(record['amOut'])}',
              textColor: textColor,
              subTextColor: subTextColor,
            ),
            _buildTimeSection(
              'Afternoon',
              'In: ${_formatTime(record['pmIn'])}',
              'Out: ${_formatTime(record['pmOut'])}',
              textColor: textColor,
              subTextColor: subTextColor,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHoursInfo(
                    'Undertime', _formatMinutes(record['undertime']), subTextColor),
                _buildHoursInfo(
                    'OT Hours', _formatMinutes(record['utHours']), subTextColor),
                _buildHoursInfo(
                    'OT Minutes', _formatMinutes(record['utMinutes']), subTextColor),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              height: 20,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(
    String title,
    String timeIn,
    String timeOut, {
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          Row(
            children: [
              Text(timeIn, style: TextStyle(fontSize: 13, color: subTextColor)),
              const SizedBox(width: 12),
              Text(timeOut, style: TextStyle(fontSize: 13, color: subTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}