import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class LearningDevelopmentWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const LearningDevelopmentWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<LearningDevelopmentWidget> createState() => _LearningDevelopmentWidgetState();
}

class _LearningDevelopmentWidgetState extends State<LearningDevelopmentWidget> {

  final _userService = UserService();
  bool _isLearningDevelopmentExpanded = true;
  List<Map<String, dynamic>> _learningDevelopmentListData = [];
  List<Map<String, dynamic>> _learningDevelopmentData = [];
  int? _editingLearningDevelopmentIndex;
  Set<int> _collapsedLearningDevIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _fetchLearningDevelopmentData();
  }

  Future<void> _fetchLearningDevelopmentData() async {
    print('\n📚 [UserDetailsPage] FETCHING LEARNING AND DEVELOPMENT DATA');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping learning and development fetch');
      return;
    }

    try {
      final response = await _userService.getLearningDevelopmentDetails(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> learningList =
            response['data']['learnDevList'] ?? [];

        setState(() {
          _learningDevelopmentListData = learningList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseLearningDevelopmentData();
        });

        print(
          '✅ Loaded ${_learningDevelopmentListData.length} learning and development records',
        );
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseLearningDevelopmentData() {
    _learningDevelopmentData = _learningDevelopmentListData.map((learning) {
      return {
        'id': learning['id'],
        'title': learning['title'] ?? '',
        'attendedFrom': learning['attendedFrom'] ?? '',
        'attendedTo': learning['attendedTo'] ?? '',
        'hours': learning['hours']?.toString() ?? '', // API: hours
        'ldType': learning['ldType'] ?? '', // API: type  (DB: ld_type)
        'conductedBy': learning['conductedBy'] ?? '',
        'certificate_url': learning['certificate_url'] ?? '', // ⭐ Added
      };
    }).toList();

    _collapsedLearningDevIndexes = List<int>.generate(
      _learningDevelopmentData.length,
      (index) => index,
    ).toSet();
    print(
      '📚 Parsed ${_learningDevelopmentData.length} learning and development records',
    );
  }

  Future<void> _saveLearningDevelopment(int index) async {
    final learning = _learningDevelopmentData[index];

    if (learning['title']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the title before saving'),
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

      // ⭐ Map widget field names → API field names expected by the backend
      final learningData = {
        'title': learning['title'] ?? '',
        'attendedFrom': learning['attendedFrom'] ?? '',
        'attendedTo': learning['attendedTo'] ?? '',
        'hours': learning['hours'] ?? '',
        'ldType': learning['ldType'] ?? '',
        'conductedBy': learning['conductedBy'] ?? '',
        'certificate_url': learning['certificate_url'] ?? '',
      };

      final response = learning.containsKey('id') && learning['id'] != null
          ? await _userService.updateLearningDevelopment(
              widget.token,
              learning['id'].toString(),
              learningData,
            )
          : await _userService.addLearningDevelopment(
              widget.token,
              employeeId.toString(),
              learningData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchLearningDevelopmentData();
        if (mounted) {
          setState(() => _editingLearningDevelopmentIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Learning and development record saved successfully',
              ),
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

  Future<void> _deleteLearningDevelopment(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Learning and Development Record'),
        content: const Text(
          'Are you sure you want to delete this learning and development record?',
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
      final learning = _learningDevelopmentData[index];

      if (learning.containsKey('id') && learning['id'] != null) {
        final response = await _userService.deleteLearningDevelopment(
          widget.token,
          learning['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchLearningDevelopmentData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Learning and development record deleted'),
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
          _learningDevelopmentData.removeAt(index);
          if (_editingLearningDevelopmentIndex == index)
            _editingLearningDevelopmentIndex = null;
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


Widget _buildLearningDevelopmentCard() {
  return Container(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        // Header with Add button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const Expanded(
                child: Text(
                  'LEARNING AND DEVELOPMENT (L&D) INTERVENTIONS/TRAINING PROGRAMS ATTENDED',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _learningDevelopmentData.insert(0, {
                      'title': '',
                      'attendedFrom': '',
                      'attendedTo': '',
                      'hours': '',
                      'ldType': '',
                      'conductedBy': '',
                      'certificate_url': '',
                    });
                    _collapsedLearningDevIndexes = _collapsedLearningDevIndexes.map((i) => i + 1).toSet();
                    _editingLearningDevelopmentIndex = 0;
                  });
                },
                child: const Icon(Icons.add_circle, size: 24, color: Colors.white),
              ),
            ],
          ),
        ),
        if (_isLearningDevelopmentExpanded)
          Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _learningDevelopmentData.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No training records found.\nTap + to add.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ]
                    : [
                        ..._learningDevelopmentData.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Map<String, dynamic> training = entry.value;
                          final bool isEditing = _editingLearningDevelopmentIndex == index;
                          bool isCollapsed = _collapsedLearningDevIndexes.contains(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: isEditing
                                          ? _buildEditableFieldInline('Training Programs', training['title'], (value) { _learningDevelopmentData[index]['title'] = value; })
                                          : Text(training['title'] ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ),
                                    // Collapse/expand arrow
                                    GestureDetector(
                                      onTap: () {
                                        if (!isEditing) {
                                          setState(() {
                                            if (isCollapsed) {
                                              _collapsedLearningDevIndexes.remove(index);
                                            } else {
                                              _collapsedLearningDevIndexes.add(index);
                                            }
                                          });
                                        }
                                      },
                                      child: Icon(isCollapsed ? Icons.expand_more : Icons.expand_less, size: 20, color: Colors.black),
                                    ),
                                    const SizedBox(width: 4),
                                    // 3-dot menu
                                    PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz, size: 22, color: Colors.black54),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            setState(() {
                                              _collapsedLearningDevIndexes.remove(index);
                                              _editingLearningDevelopmentIndex = index;
                                            });
                                          } else if (value == 'delete') {
                                            _deleteLearningDevelopment(index);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.black87), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 14))])),
                                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red))])),
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
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('Date From', training['attendedFrom'], (value) { setState(() { _learningDevelopmentData[index]['attendedFrom'] = value; }); })
                                                  : _buildInfoFieldInline('Date From', training['attendedFrom']),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('Date To', training['attendedTo'], (value) { setState(() { _learningDevelopmentData[index]['attendedTo'] = value; }); })
                                                  : _buildInfoFieldInline('Date To', training['attendedTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildEditableFieldInline('Number of Hours', training['hours'], (value) { setState(() { _learningDevelopmentData[index]['hours'] = value; }); })
                                                  : _buildInfoFieldInline('Number of Hours', training['hours']),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildEditableFieldInline('Type of L&D', training['ldType'], (value) { setState(() { _learningDevelopmentData[index]['ldType'] = value; }); })
                                                  : _buildInfoFieldInline('Type of L&D', training['ldType']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        isEditing
                                            ? _buildEditableFieldInline('Conducted / Sponsored By', training['conductedBy'], (value) { setState(() { _learningDevelopmentData[index]['conductedBy'] = value; }); })
                                            : _buildInfoFieldInline('Conducted / Sponsored By', training['conductedBy']),
                                        if (isEditing) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => setState(() {
                                                  _editingLearningDevelopmentIndex = null;
                                                  _collapsedLearningDevIndexes.add(index);
                                                }),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _saveLearningDevelopment(index),
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

  Widget _buildPhoneFieldInline(String label, String? value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        TextFormField(
          initialValue: value ?? '',
          onChanged: onChanged,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
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
    return _buildLearningDevelopmentCard();
  }

}