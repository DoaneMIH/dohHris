import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class VoluntaryWorkWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const VoluntaryWorkWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<VoluntaryWorkWidget> createState() => _VoluntaryWorkWidgetState();
}

class _VoluntaryWorkWidgetState extends State<VoluntaryWorkWidget> {

  final _userService = UserService();
  bool _isVoluntaryWorkExpanded = true;
  List<Map<String, dynamic>> _voluntaryWorkListData = [];
  List<Map<String, dynamic>> _voluntaryWorkData = [];
  int? _editingVoluntaryWorkIndex;
  Set<int> _collapsedVoluntaryWorkIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _fetchVoluntaryWorkData();
  }

  Future<void> _fetchVoluntaryWorkData() async {
    print('\n🤝 [UserDetailsPage] FETCHING VOLUNTARY WORK DATA');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping voluntary work fetch');
      return;
    }

    try {
      final response = await _userService.getVoluntaryWorkDetails(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> voluntaryList =
            response['data']['voluntaryWorkList'] ?? [];

        setState(() {
          _voluntaryWorkListData = voluntaryList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseVoluntaryWorkData();
        });

        print(
          '✅ Loaded ${_voluntaryWorkListData.length} voluntary work records',
        );
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseVoluntaryWorkData() {
    _voluntaryWorkData = _voluntaryWorkListData.map((voluntary) {
      return {
        'id': voluntary['id'],
        'organization': voluntary['organization'] ?? '',
        'dateFrom': voluntary['dateFrom'] ?? '',
        'dateTo': voluntary['dateTo'] ?? '',
        'hours': voluntary['hours']?.toString() ?? '',
        'work': voluntary['work'] ?? '',
      };
    }).toList();
    _collapsedVoluntaryWorkIndexes = List<int>.generate(
      _voluntaryWorkData.length,
      (index) => index,
    ).toSet();
    print('🤝 Parsed ${_voluntaryWorkData.length} voluntary work records');
  }

  Future<void> _saveVoluntaryWork(int index) async {
    final voluntary = _voluntaryWorkData[index];

    // Validate organization
    if (voluntary['organization']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter organization name before saving'),
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

      final voluntaryData = {
        'organization': voluntary['organization'] ?? '',
        'dateFrom': voluntary['dateFrom'] ?? '',
        'dateTo': voluntary['dateTo'] ?? '',
        'hours': voluntary['hours'] ?? '',
        'work': voluntary['work'] ?? '',
      };

      final response = voluntary.containsKey('id') && voluntary['id'] != null
          ? await _userService.updateVoluntaryWork(
              widget.token,
              voluntary['id'].toString(),
              voluntaryData,
            )
          : await _userService.addVoluntaryWork(
              widget.token,
              employeeId.toString(),
              voluntaryData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchVoluntaryWorkData();
        if (mounted) {
          setState(() => _editingVoluntaryWorkIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voluntary work saved successfully'),
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

  Future<void> _deleteVoluntaryWork(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voluntary Work'),
        content: const Text(
          'Are you sure you want to delete this voluntary work record?',
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
      final voluntary = _voluntaryWorkData[index];

      if (voluntary.containsKey('id') && voluntary['id'] != null) {
        final response = await _userService.deleteVoluntaryWork(
          widget.token,
          voluntary['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchVoluntaryWorkData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voluntary work deleted'),
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
          _voluntaryWorkData.removeAt(index);
          if (_editingVoluntaryWorkIndex == index)
            _editingVoluntaryWorkIndex = null;
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

  //LEARNING AND DEVELOPMENT FUNCTIONS

Widget _buildVoluntaryWorkCard() {
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
                  'VOLUNTARY WORK OR INVOLVEMENT IN CIVIC / NON-GOVERNMENT / PEOPLE / VOLUNTARY ORGANIZATION/S',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _voluntaryWorkData.insert(0, {
                      'organization': '',
                      'dateFrom': '',
                      'dateTo': '',
                      'hours': '',
                      'work': '',
                    });
                    _collapsedVoluntaryWorkIndexes = _collapsedVoluntaryWorkIndexes.map((i) => i + 1).toSet();
                    _editingVoluntaryWorkIndex = 0;
                  });
                },
                child: const Icon(Icons.add_circle, size: 24, color: Colors.white),
              ),
            ],
          ),
        ),
        // Content
        if (_isVoluntaryWorkExpanded)
          Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _voluntaryWorkData.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No voluntary work records found.\nTap + to add voluntary work.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ]
                    : [
                        ..._voluntaryWorkData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> voluntary = entry.value;
                          bool isEditing = _editingVoluntaryWorkIndex == index;
                          bool isCollapsed = _collapsedVoluntaryWorkIndexes.contains(index);

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
                                          ? _buildEditableFieldInline('Name of Organization', voluntary['organization'], (value) { _voluntaryWorkData[index]['organization'] = value; })
                                          : Text(voluntary['organization'] ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ),
                                    // Collapse/expand arrow
                                    if(!isEditing)
                                    GestureDetector(
                                      onTap: () {
                                        if (!isEditing) {
                                          setState(() {
                                            if (isCollapsed) {
                                              _collapsedVoluntaryWorkIndexes.remove(index);
                                            } else {
                                              _collapsedVoluntaryWorkIndexes.add(index);
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
                                              _collapsedVoluntaryWorkIndexes.remove(index);
                                              _editingVoluntaryWorkIndex = index;
                                            });
                                          } else if (value == 'delete') {
                                            _deleteVoluntaryWork(index);
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
                                                  ? _buildDateFieldInline('From', voluntary['dateFrom'], (value) { _voluntaryWorkData[index]['dateFrom'] = value; })
                                                  : _buildInfoFieldInline('Date From', voluntary['dateFrom']),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('To', voluntary['dateTo'], (value) { _voluntaryWorkData[index]['dateTo'] = value; })
                                                  : _buildInfoFieldInline('Date To', voluntary['dateTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        isEditing
                                            ? _buildEditableFieldInline('Number of Hours', voluntary['hours'], (value) { _voluntaryWorkData[index]['hours'] = value; })
                                            : _buildInfoFieldInline('Number of Hours', voluntary['hours']),
                                        const SizedBox(height: 12),
                                        isEditing
                                            ? _buildEditableFieldInline('Position / Nature of Work', voluntary['work'], (value) { _voluntaryWorkData[index]['work'] = value; })
                                            : _buildInfoFieldInline('Position / Nature of Work', voluntary['work']),
                                    if (isEditing) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => setState(() {
                                                  _editingVoluntaryWorkIndex = null;
                                                  _collapsedVoluntaryWorkIndexes.add(index);
                                                }),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _saveVoluntaryWork(index),
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

  // Learning and Development Section


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
    return _buildVoluntaryWorkCard();
  }

}