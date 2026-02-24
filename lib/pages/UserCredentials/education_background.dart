import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class EducationalBackgroundWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const EducationalBackgroundWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<EducationalBackgroundWidget> createState() => _EducationalBackgroundWidgetState();
}

class _EducationalBackgroundWidgetState extends State<EducationalBackgroundWidget> {

  final _userService = UserService();
  List<Map<String, dynamic>> _educationListData = [];
  List<Map<String, dynamic>> _educationData = [];
  int? _editingEducationIndex;
  Set<int> _collapsedEducationIndexes = <int>{};
  bool _isEducationalBackgroundExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchEducationData();
  }

  Future<void> _fetchEducationData() async {
    print('\n📚 [UserDetailsPage] FETCHING EDUCATION DATA');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping education fetch');
      return;
    }

    try {
      final response = await _userService.getEducationDetails(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> educationList =
            response['data']['educationList'] ?? [];

        setState(() {
          _educationListData = educationList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseEducationData();
        });

        print('✅ Loaded ${_educationListData.length} education records');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseEducationData() {
    _educationData = _educationListData.map((edu) {
      String getLevelName(String? code) {
        switch (code?.toUpperCase()) {
          case 'E':
            return 'ELEMENTARY';
          case 'S':
            return 'SECONDARY';
          case 'V':
            return 'VOCATIONAL/TRADE COURSE';
          case 'C':
            return 'COLLEGE';
          case 'G':
            return 'GRADUATE STUDIES';
          default:
            return code ?? '';
        }
      }

      return {
        'id': edu['id'],
        'level': getLevelName(edu['level']),
        'schoolName': edu['school'] ?? '',
        'degreeCourse': edu['degreeCourse'] ?? '',
        'attendedFrom': edu['attendedFrom'] ?? '',
        'attendedTo': edu['attendedTo'] ?? '',
        'highestLevel': edu['highestLevel'] ?? '',
        'yearGraduated': edu['yearGraduated'] ?? '',
        'academicHonors': edu['academicHonors'] ?? '',
        'onGoing': edu['onGoing'] ?? false,
      };
    }).toList();

    _collapsedEducationIndexes = List<int>.generate(
      _educationData.length,
      (index) => index,
    ).toSet();
    print('📚 Parsed ${_educationData.length} education records');
  }

  Future<void> _saveEducation(int index) async {
    final education = _educationData[index];

    // Validate school name
    if (education['schoolName']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter school name before saving'),
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

      // Convert level name to code
      String getLevelCode(String? levelName) {
        switch (levelName?.toUpperCase()) {
          case 'ELEMENTARY':
            return 'E';
          case 'SECONDARY':
            return 'S';
          case 'VOCATIONAL/TRADE COURSE':
            return 'V';
          case 'COLLEGE':
            return 'C';
          case 'GRADUATE STUDIES':
            return 'G';
          default:
            return 'E';
        }
      }

      final educationData = {
        'level': getLevelCode(education['level']),
        'school': education['schoolName'] ?? '',
        'degreeCourse': education['degreeCourse'] ?? '',
        'attendedFrom': education['attendedFrom'] ?? '',
        'attendedTo': education['attendedTo'] ?? '',
        'highestLevel': education['highestLevel'] ?? '',
        'yearGraduated': education['yearGraduated'] ?? '',
        'academicHonors': education['academicHonors'] ?? '',
        'onGoing': education['onGoing'] ?? false,
      };

      final response = education.containsKey('id') && education['id'] != null
          ? await _userService.updateEducation(
              widget.token,
              education['id'].toString(),
              educationData,
            )
          : await _userService.addEducation(
              widget.token,
              employeeId.toString(),
              educationData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchEducationData();
        if (mounted) {
          setState(() => _editingEducationIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Education saved successfully'),
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

  Future<void> _deleteEducation(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Education'),
        content: const Text(
          'Are you sure you want to delete this education record?',
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
      final education = _educationData[index];

      if (education.containsKey('id') && education['id'] != null) {
        final response = await _userService.deleteEducation(
          widget.token,
          education['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchEducationData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Education deleted'),
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
          _educationData.removeAt(index);
          if (_editingEducationIndex == index) _editingEducationIndex = null;
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


 Widget _buildEducationalBackgroundCard() {
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
                  'EDUCATIONAL BACKGROUND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                // Add button in the header
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final newEntry = {
                        'level': 'ELEMENTARY',
                        'schoolName': '',
                        'degreeCourse': '',
                        'attendedFrom': '',
                        'attendedTo': '',
                        'highestLevel': '',
                        'yearGraduated': '',
                        'academicHonors': '',
                        'onGoing': false,
                      };
                      // Insert at the beginning
                      _educationData.insert(0, newEntry);
                      // Update collapsed indexes — shift all existing indexes up by 1
                      _collapsedEducationIndexes = _collapsedEducationIndexes
                          .map((i) => i + 1)
                          .toSet();
                      // New entry at index 0 is expanded and in edit mode
                      _editingEducationIndex = 0;
                    });
                  },
                  child: const Icon(
                    Icons.add_circle,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          if (_isEducationalBackgroundExpanded)
            Container(
              padding: const EdgeInsets.all(7.0),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _educationData.isEmpty
                      ? [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Text(
                                'No education records found.\nTap + to add education.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._educationData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> education = entry.value;
                            bool isEditing = _editingEducationIndex == index;
                            bool isCollapsed = _collapsedEducationIndexes.contains(index);

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
                                  // Title row: tapping title toggles collapse, 3-dot menu on right
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Tappable title area — toggles collapse/expand
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (!isEditing) {
                                              setState(() {
                                                if (isCollapsed) {
                                                  _collapsedEducationIndexes.remove(index);
                                                } else {
                                                  _collapsedEducationIndexes.add(index);
                                                }
                                              });
                                            }
                                          },
                                          child: isEditing
                                              ? DropdownButtonFormField<String>(
                                                  value: education['level'],
                                                  decoration: const InputDecoration(
                                                    labelText: 'Education Level',
                                                    labelStyle: TextStyle(fontSize: 12),
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  items: [
                                                    'ELEMENTARY',
                                                    'SECONDARY',
                                                    'VOCATIONAL/TRADE COURSE',
                                                    'COLLEGE',
                                                    'GRADUATE STUDIES',
                                                  ].map((level) {
                                                    return DropdownMenuItem(
                                                      value: level,
                                                      child: Text(level, style: const TextStyle(fontSize: 12)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _educationData[index]['level'] = value!;
                                                    });
                                                  },
                                                )
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      education['level'] ?? 'N/A',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (isCollapsed)
                                                      Text(
                                                        education['schoolName'] ?? 'N/A',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      // Collapse/expand arrow
                                       if (!isEditing)
                                      GestureDetector(
                                        onTap: () {
                                          if (!isEditing) {
                                            setState(() {
                                              if (isCollapsed) {
                                                _collapsedEducationIndexes.remove(index);
                                              } else {
                                                _collapsedEducationIndexes.add(index);
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

                                      // 3-dot menu button — always visible on the right
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
                                                // Expand the card and enter edit mode
                                                _collapsedEducationIndexes
                                                    .remove(index);
                                                _editingEducationIndex = index;
                                              });
                                            } else if (value == 'delete') {
                                              _deleteEducation(index);
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

                                  // Collapsible content
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // School Name
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'School Name',
                                                  education['schoolName'],
                                                  (value) { _educationData[index]['schoolName'] = value; },
                                                )
                                              : _buildInfoFieldInline('School Name', education['schoolName']),
                                          const SizedBox(height: 12),

                                          // Degree/Course
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'Degree/Course',
                                                  education['degreeCourse'],
                                                  (value) { _educationData[index]['degreeCourse'] = value; },
                                                )
                                              : _buildInfoFieldInline('Degree/Course', education['degreeCourse']),
                                          const SizedBox(height: 12),

                                          // Period Attended - From/To
                                          Row(
                                            children: [
                                              Expanded(
                                                child: isEditing
                                                    ? _buildDateFieldInline(
                                                        'From',
                                                        education['attendedFrom'],
                                                        (value) { _educationData[index]['attendedFrom'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('From', education['attendedFrom']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: isEditing
                                                    ? _buildDateFieldInline(
                                                        'To',
                                                        education['attendedTo'],
                                                        (value) { _educationData[index]['attendedTo'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('To', education['attendedTo']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Highest Level/Units & Year Graduated
                                          Row(
                                            children: [
                                              Expanded(
                                                child: isEditing
                                                    ? _buildEditableFieldInline(
                                                        'Highest Level/Units',
                                                        education['highestLevel'],
                                                        (value) { _educationData[index]['highestLevel'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('Highest Level/Units', education['highestLevel']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: isEditing
                                                    ? _buildEditableFieldInline(
                                                        'Year Graduated',
                                                        education['yearGraduated'],
                                                        (value) { _educationData[index]['yearGraduated'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('Year Graduated', education['yearGraduated']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Academic Honors
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'Academic Honors',
                                                  education['academicHonors'],
                                                  (value) { _educationData[index]['academicHonors'] = value; },
                                                )
                                              : _buildInfoFieldInline('Academic Honors', education['academicHonors']),
                                        if (isEditing) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => setState(() {
                                                  _editingEducationIndex = null;
                                                  _collapsedEducationIndexes.add(index);
                                                }),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _saveEducation(index),
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
                                  ], // End of collapsible content
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
  Widget build(Object context) {
    return _buildEducationalBackgroundCard();
  }

}