import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class WorkExperienceWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const WorkExperienceWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<WorkExperienceWidget> createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {

  final _userService = UserService();
  bool _isWorkExperienceExpanded = true;
  List<Map<String, dynamic>> _workExperienceListData = [];
  List<Map<String, dynamic>> _workExperienceData = [];
  int? _editingWorkExperienceIndex;
  Set<int> _collapsedWorkExperienceIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _fetchWorkExperienceData();
  }

  Future<void> _fetchWorkExperienceData() async {
    print('\n💼 [UserDetailsPage] FETCHING WORK EXPERIENCE DATA');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping work experience fetch');
      return;
    }

    try {
      final response = await _userService.getWorkExperienceDetails(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> workList =
            response['data']['workExperienceList'] ?? [];

        setState(() {
          _workExperienceListData = workList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseWorkExperienceData();
        });

        print(
          '✅ Loaded ${_workExperienceListData.length} work experience records',
        );
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseWorkExperienceData() {
    _workExperienceData = _workExperienceListData.map((work) {
      // ⭐ FIX: Convert boolean to "Yes"/"No" for display
      String getGovernmentServiceDisplay(dynamic value) {
        if (value == null) return 'No';
        if (value is bool) return value ? 'Yes' : 'No';
        final strValue = value.toString().toUpperCase();
        if (strValue == 'TRUE' || strValue == 'YES' || strValue == '1')
          return 'Yes';
        return 'No';
      }

      return {
        'id': work['id'],
        'dateFrom': work['dateFrom'] ?? '',
        'dateTo': work['dateTo'] ?? '',
        'position': work['position'] ?? '',
        'company': work['company'] ?? '',
        'appointmentStatus': work['appointmentStatus'] ?? '',
        'govtService': getGovernmentServiceDisplay(work['govtService']),
      };
    }).toList();
    _collapsedWorkExperienceIndexes = List<int>.generate(
      _workExperienceData.length,
      (index) => index,
    ).toSet();
    print('💼 Parsed ${_workExperienceData.length} work experience records');
  }

  //ADD WORK EXPERIENCE SAVE AND DELETE FUNCTIONS HERE
  Future<void> _saveWorkExperience(int index) async {
    final work = _workExperienceData[index];

    // Validate position title
    if (work['position']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter position title before saving'),
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

      bool isGovernmentService = false;
      final govServiceValue = work['govtService']?.toString().toUpperCase();
      if (govServiceValue == 'YES' ||
          govServiceValue == 'TRUE' ||
          govServiceValue == '1') {
        isGovernmentService = true;
      }

      final workData = {
        'dateFrom': work['dateFrom'] ?? '',
        'dateTo': work['dateTo'] ?? '',
        'position': work['position'] ?? '',
        'company': work['company'] ?? '',
        'appointmentStatus': work['appointmentStatus'] ?? '',
        'govtService': isGovernmentService,
      };

      final response = work.containsKey('id') && work['id'] != null
          ? await _userService.updateWorkExperience(
              widget.token,
              work['id'].toString(),
              workData,
            )
          : await _userService.addWorkExperience(
              widget.token,
              employeeId.toString(),
              workData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchWorkExperienceData();
        if (mounted) {
          setState(() => _editingWorkExperienceIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work experience saved successfully'),
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

  Future<void> _deleteWorkExperience(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Work Experience'),
        content: const Text(
          'Are you sure you want to delete this work experience record?',
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
      final work = _workExperienceData[index];

      if (work.containsKey('id') && work['id'] != null) {
        final response = await _userService.deleteWorkExperience(
          widget.token,
          work['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchWorkExperienceData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Work experience deleted'),
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
          _workExperienceData.removeAt(index);
          if (_editingWorkExperienceIndex == index)
            _editingWorkExperienceIndex = null;
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


Widget _buildWorkExperienceCard() {
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
                'WORK EXPERIENCE',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _workExperienceData.insert(0, {
                      'dateFrom': '',
                      'dateTo': '',
                      'position': '',
                      'company': '',
                      'appointmentStatus': '',
                      'govtService': '',
                    });
                    _collapsedWorkExperienceIndexes = _collapsedWorkExperienceIndexes.map((i) => i + 1).toSet();
                    _editingWorkExperienceIndex = 0;
                  });
                },
                child: const Icon(Icons.add_circle, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
        // Content
        if (_isWorkExperienceExpanded)
          Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _workExperienceData.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No work experience records found.\nTap + to add work experience.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ]
                    : [
                        ..._workExperienceData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> work = entry.value;
                          bool isEditing = _editingWorkExperienceIndex == index;
                          bool isCollapsed = _collapsedWorkExperienceIndexes.contains(index);

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
                                          ? _buildEditableFieldInline('Position Title', work['position'], (value) { _workExperienceData[index]['position'] = value; })
                                          : Text(work['position'] ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ),
                                    // Collapse/expand arrow
                                    if(!isEditing)
                                    GestureDetector(
                                      onTap: () {
                                        if (!isEditing) {
                                          setState(() {
                                            if (isCollapsed) {
                                              _collapsedWorkExperienceIndexes.remove(index);
                                            } else {
                                              _collapsedWorkExperienceIndexes.add(index);
                                            }
                                          });
                                        }
                                      },
                                      child: Icon(isCollapsed ? Icons.expand_more : Icons.expand_less, size: 20, color: Colors.black),
                                    ),
                                    const SizedBox(width: 4),
                                      // 3-dot menu or save
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
                                                _collapsedWorkExperienceIndexes
                                                    .remove(index);
                                                _editingWorkExperienceIndex =
                                                    index;
                                              });
                                            } else if (value == 'delete') {
                                              _deleteWorkExperience(index);
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.red.shade600,
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
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('From', work['dateFrom'], (value) { _workExperienceData[index]['dateFrom'] = value; })
                                                  : _buildInfoFieldInline('From', work['dateFrom']),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('To', work['dateTo'], (value) { _workExperienceData[index]['dateTo'] = value; })
                                                  : _buildInfoFieldInline('To', work['dateTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        isEditing
                                            ? _buildEditableFieldInline('Department / Agency / Office / Company', work['company'], (value) { _workExperienceData[index]['company'] = value; })
                                            : _buildInfoFieldInline('Department / Agency / Office / Company', work['company']),
                                        const SizedBox(height: 12),
                                        isEditing
                                            ? _buildEditableFieldInline('Status of Appointment', work['appointmentStatus'], (value) { _workExperienceData[index]['appointmentStatus'] = value; })
                                            : _buildInfoFieldInline('Status of Appointment', work['appointmentStatus']),
                                        const SizedBox(height: 12),
                                        isEditing
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Government Service', style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                                  const SizedBox(height: 4),
                                                  DropdownButtonFormField<String>(
                                                    value: work['govtService']?.toString().toUpperCase() == 'TRUE' || work['govtService']?.toString().toUpperCase() == 'YES'
                                                        ? 'Yes'
                                                        : work['govtService']?.toString().toUpperCase() == 'FALSE' || work['govtService']?.toString().toUpperCase() == 'NO'
                                                            ? 'No'
                                                            : null,
                                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), border: UnderlineInputBorder()),
                                                    items: ['Yes', 'No'].map((value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
                                                    onChanged: (value) { setState(() { _workExperienceData[index]['govtService'] = value; }); },
                                                  ),
                                                ],
                                              )
                                            : _buildInfoFieldInline('Government Service', work['govtService']),
                                      if (isEditing) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => setState(() {
                                                  _editingWorkExperienceIndex = null;
                                                  _collapsedWorkExperienceIndexes.add(index);
                                                }),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _saveWorkExperience(index),
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

  // Voluntary Work Section


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

  // Widget _buildPhoneFieldInline(String label, String? value, Function(String) onChanged) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
  //       TextFormField(
  //         initialValue: value ?? '',
  //         onChanged: onChanged,
  //         keyboardType: TextInputType.phone,
  //         inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
  //         style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //           border: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFF2C5F4F))),
  //           enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
  //           focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2)),
  //           contentPadding: const EdgeInsets.symmetric(vertical: 4),
  //           isDense: true,
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    return _buildWorkExperienceCard();
  }

}