import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class CivilServiceWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const CivilServiceWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<CivilServiceWidget> createState() => _CivilServiceWidgetState();
}

class _CivilServiceWidgetState extends State<CivilServiceWidget> {

  final _userService = UserService();
  bool _isCivilServiceExpanded = true;
  List<Map<String, dynamic>> _civilServiceData = [];
  int? _editingCivilServiceIndex;
  Set<int> _collapsedCivilServiceIndexes = <int>{};
  List<Map<String, dynamic>> _civilServiceEligibilityListData = [];

  @override
  void initState() {
    super.initState();
    _fetchCivilServiceEligibilityData();
  }

  Future<void> _fetchCivilServiceEligibilityData() async {
    print('\n📜 [UserDetailsPage] FETCHING CIVIL SERVICE ELIGIBILITY');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping civil service eligibility fetch');
      return;
    }

    try {
      final response = await _userService.getCivilServiceEligibilityDetails(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> eligibilityList =
            response['data']['eligibilityList'] ?? [];

        setState(() {
          _civilServiceEligibilityListData = eligibilityList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseCivilServiceEligibilityData();
        });

        print(
          '✅ Loaded ${_civilServiceEligibilityListData.length} civil service eligibility records',
        );
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseCivilServiceEligibilityData() {
    _civilServiceData = _civilServiceEligibilityListData.map((eligibility) {
      return {
        'id': eligibility['id'],
        'serviceEligibility': eligibility['serviceEligibility'] ?? '',
        'rating': eligibility['rating'] ?? '',
        'examPlace': eligibility['examPlace'] ?? '',
        'examDate': eligibility['examDate'] ?? '',
        'licenseNo': eligibility['licenseNo'] ?? '',
        // 'validity': eligibility['validity'] ?? '',
      };
    }).toList();
    _collapsedCivilServiceIndexes = List<int>.generate(
      _civilServiceData.length,
      (index) => index,
    ).toSet();
    print(
      '📜 Parsed ${_civilServiceData.length} civil service eligibility records',
    );
  }

  Future<void> _saveCivilServiceEligibility(int index) async {
    final eligibility = _civilServiceData[index];

    if (eligibility['serviceEligibility']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the career service before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = widget.employeeId;

      // ⭐ Map widget field names → API field names
      final eligibilityData = {
        'serviceEligibility': eligibility['serviceEligibility'] ?? '',
        'rating': eligibility['rating'] ?? '',
        'examPlace': eligibility['examPlace'] ?? '',
        'examDate': eligibility['examDate'] ?? '',
        'licenseNo': eligibility['licenseNo'] ?? '',
        // 'validity': eligibility['validity'] ?? '',
      };

      final response =
          eligibility.containsKey('id') && eligibility['id'] != null
          ? await _userService.updateCivilServiceEligibility(
              widget.token,
              eligibility['id'].toString(),
              eligibilityData,
            )
          : await _userService.addCivilServiceEligibility(
              widget.token,
              employeeId.toString(),
              eligibilityData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchCivilServiceEligibilityData();
        if (mounted) {
          setState(() => _editingCivilServiceIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Civil service eligibility saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCivilServiceEligibility(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Civil Service Eligibility'),
        content: const Text(
          'Are you sure you want to delete this civil service eligibility record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final eligibility = _civilServiceData[index];

      if (eligibility.containsKey('id') && eligibility['id'] != null) {
        final response = await _userService.deleteCivilServiceEligibility(
          widget.token,
          eligibility['id'].toString(),
        );

        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchCivilServiceEligibilityData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Civil service eligibility deleted'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(response['error']);
        }
      } else {
        if (mounted) Navigator.pop(context);
        setState(() {
          _civilServiceData.removeAt(index);
          if (_editingCivilServiceIndex == index) {
            _editingCivilServiceIndex = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


    Widget _buildCivilServiceCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with Add button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2C5F4F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CIVIL SERVICE ELIGIBILITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _civilServiceData.insert(0, {
                        'careerService': '',
                        'rating': '',
                        'examDate': '',
                        'examPlace': '',
                        'licenseNo': '',
                        'validity': '',
                        'serviceEligibility': 'CSE',
                      });
                      _collapsedCivilServiceIndexes = _collapsedCivilServiceIndexes.map((i) => i + 1).toSet();
                      _editingCivilServiceIndex = 0;
                    });
                  },
                  child: const Icon(Icons.add_circle, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          // Content
          if (_isCivilServiceExpanded)
            Container(
              padding: const EdgeInsets.all(7.0),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _civilServiceData.isEmpty
                      ? [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No civil service records found.\nTap + to add.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._civilServiceData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> service = entry.value;
                            bool isEditing = _editingCivilServiceIndex == index;
                            bool isCollapsed = _collapsedCivilServiceIndexes.contains(index);

                            String eligibilityLabel(String? val) {
                              const map = {
                                'CSE': 'Career Service Eligibility',
                                'RA1080': 'RA 1080 (Board/Bar) Under Special Laws',
                                'CES': 'Career Executive Service',
                                'CSEE': 'Career Service Executive Examination',
                                'BE': 'Barangay Eligibility',
                                'DL': 'Driver\'s License',
                                'OTHERS': 'Others',
                              };
                              return map[val] ?? val ?? 'N/A';
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: isEditing
                                            ? DropdownButtonFormField<String>(
                                                value: service['serviceEligibility'],
                                                isExpanded: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'Eligibility Type',
                                                  labelStyle: TextStyle(fontSize: 12),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: [
                                                  {'value': 'CSE', 'label': 'Career Service Eligibility'},
                                                  {'value': 'RA1080', 'label': 'RA 1080 (Board/Bar) Under Special Laws'},
                                                  {'value': 'CES', 'label': 'Career Executive Service'},
                                                  {'value': 'CSEE', 'label': 'Career Service Executive Examination'},
                                                  {'value': 'BE', 'label': 'Barangay Eligibility'},
                                                  {'value': 'DL', 'label': 'Driver\'s License'},
                                                  {'value': 'OTHERS', 'label': 'Others'},
                                                ].map((item) {
                                                  return DropdownMenuItem(
                                                    value: item['value'],
                                                    child: Text(item['label']!, style: const TextStyle(fontSize: 12)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _civilServiceData[index]['serviceEligibility'] = value!;
                                                  });
                                                },
                                              )
                                            : Text(
                                                eligibilityLabel(service['serviceEligibility']),
                                                style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                      ),
                                      // Collapse/expand arrow
                                         if (!isEditing)
                                      GestureDetector(
                                        onTap: () {
                                          if (!isEditing) {
                                            setState(() {
                                              if (isCollapsed) {
                                                _collapsedCivilServiceIndexes.remove(index);
                                              } else {
                                                _collapsedCivilServiceIndexes.add(index);
                                              }
                                            });
                                          }
                                        },
                                        child: Icon(
                                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // 3-dot menu or save button
                                      
                                      if (!isEditing)
                                        PopupMenuButton<String>(
                                          color: Colors.white,
                                          position: PopupMenuPosition.under,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          icon: Container(
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                              Icons.more_horiz,
                                              size: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              setState(() {
                                                _collapsedCivilServiceIndexes
                                                    .remove(index);
                                                _editingCivilServiceIndex = index;
                                              });
                                            } else if (value == 'delete') {
                                              _deleteCivilServiceEligibility(index);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                           PopupMenuItem<String>(
                            value: 'edit',
                            height: 30,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                                            const PopupMenuDivider(height: 8),
                            PopupMenuItem<String>(
                              value: 'delete',
                              height: 30,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                          ],
                                        ),
                                    ],
                                  ),

                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          isEditing
                                              ? _buildEditableFieldInline('Rating', service['rating'], (value) { service['rating'] = value; })
                                              : _buildInfoFieldInline('Rating', service['rating']),
                                          const SizedBox(height: 10),
                                          isEditing
                                              ? _buildDateFieldInline('Date of Exam', service['examDate'], (value) { service['examDate'] = value; })
                                              : _buildInfoFieldInline('Date of Exam', service['examDate']),
                                          const SizedBox(height: 10),
                                          isEditing
                                              ? _buildEditableFieldInline('Place of Exam', service['examPlace'], (value) { service['examPlace'] = value; })
                                              : _buildInfoFieldInline('Place of Exam', service['examPlace']),
                                          const SizedBox(height: 10),
                                          isEditing
                                              ? _buildEditableFieldInline('License Number', service['licenseNo'], (value) { service['licenseNo'] = value; })
                                              : _buildInfoFieldInline('License Number', service['licenseNo']),
                                         if (isEditing) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => setState(() {
                                                  _editingCivilServiceIndex = null;
                                                  _collapsedCivilServiceIndexes.add(index);
                                                }),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _saveCivilServiceEligibility(index),
                                                icon: const Icon(Icons.save, size: 16),
                                                label: const Text('Save'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2C5F4F),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  textStyle: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoFieldInline(String label, dynamic value) {
    String displayValue = 'N/A';
    if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
      displayValue = value.toString();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 1),
        Text(displayValue, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEditableFieldInline(String label, String? value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value ?? '',
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFF2C5F4F))),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            isDense: true,
          ),
        ),
      ],
    );
  }

  
  Widget _buildDateFieldInline(String label, String? value, Function(String) onChanged) {
    final controller = TextEditingController(text: value ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () async {
            DateTime? initialDate;
            if (value != null && value.isNotEmpty) {
              try {
                initialDate = DateTime.tryParse(value);
              } catch (e) {}
            }
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF2C5F4F), onPrimary: Colors.white, onSurface: Colors.black)),
                child: child!,
              ),
            );
            if (pickedDate != null) {
              final formatted = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              controller.text = formatted;
              onChanged(formatted);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today, size: 20, color: Color(0xFF2C5F4F)),
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildCivilServiceCard();
  }

}