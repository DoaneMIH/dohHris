import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class PersonReferenceWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const PersonReferenceWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<PersonReferenceWidget> createState() => _PersonReferenceWidgetState();
}

class _PersonReferenceWidgetState extends State<PersonReferenceWidget> {

  final _userService = UserService();
  List<Map<String, dynamic>> _personRefList = [];
  int? _editingPersonRefIndex;
  bool _isAddingPersonRef = false;
  Map<String, dynamic> _newPersonRefData = {};

  @override
  void initState() {
    super.initState();
    _fetchPersonReferenceData();
  }

 Future<void> _fetchPersonReferenceData() async {
    print('\n👥 [UserDetailsPage] FETCHING ALL PERSON REFERENCES');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping person reference fetch');
      return;
    }


    try {
      final response = await _userService.getAllPersonReferences(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final data = response['data'];
        final dynamic rawList = data['personRefList'] ?? data['personRef'];
        List<Map<String, dynamic>> parsed = [];
        if (rawList is List) {
          parsed = rawList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else if (rawList is Map) {
          parsed = [Map<String, dynamic>.from(rawList)];
        }
        setState(() {
          _personRefList = parsed;
        });
        print('✅ Person references loaded: ${_personRefList.length} records');
      } else {
        print('⚠️ Person reference fetch failed: ${response['error']}');
      }
    } catch (e) {
      print('💥 Exception fetching person reference: $e');
    }
  }

  /// Save a new person reference (add form).
  Future<void> _saveNewPersonReference() async {
    if ((_newPersonRefData['refName'] ?? '').toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reference name before saving'),
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

      final payload = {
        'refName': _newPersonRefData['refName']?.toString().trim() ?? '',
        'refAddress': _newPersonRefData['refAddress']?.toString().trim() ?? '',
        'refTelephone':
            _newPersonRefData['refTelephone']?.toString().trim() ?? '',
      };

      final response = await _userService.addPersonReference(
        widget.token,
        employeeId.toString(),
        payload,
      );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchPersonReferenceData();
        if (mounted) {
          setState(() {
            _isAddingPersonRef = false;
            _newPersonRefData = {};
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reference added successfully'),
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

  /// Update an existing person reference at [index] in [_personRefList].
  Future<void> _updatePersonReference(int index) async {
    final item = _personRefList[index];
    if ((item['refName'] ?? '').toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reference name before saving'),
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
      final payload = {
        'refName': item['refName']?.toString().trim() ?? '',
        'refAddress': item['refAddress']?.toString().trim() ?? '',
        'refTelephone': item['refTelephone']?.toString().trim() ?? '',
      };

      final response = await _userService.updatePersonReference(
        widget.token,
        item['id'].toString(),
        payload,
      );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchPersonReferenceData();
        if (mounted) {
          setState(() => _editingPersonRefIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reference updated successfully'),
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
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePersonReference(int index) async {
    final item = _personRefList[index];
    if (item['id'] == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reference'),
        content: const Text(
          'Are you sure you want to delete this reference record?',
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
      final response = await _userService.deletePersonReference(
        widget.token,
        item['id'].toString(),
      );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchPersonReferenceData();
        if (mounted) {
          setState(() => _editingPersonRefIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reference deleted'),
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
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildPersonReferenceCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──────────────────────────────────────────────────
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
                const Text(
                  'REFERENCES',
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
                    _newPersonRefData = {
                      'refName': '',
                      'refAddress': '',
                      'refTelephone': '',
                    };
                   _isAddingPersonRef = true;
                  _editingPersonRefIndex = null;
                  });
                },
                child: const Icon(Icons.add_circle, size: 24, color: Colors.white),
              ),
                // if (_isFetchingPersonRef)
                //   const SizedBox(
                //     width: 16,
                //     height: 16,
                //     child: CircularProgressIndicator(
                //       strokeWidth: 2,
                //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //     ),
                //   ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Add-new form ────────────────────────────────────────
                if (_isAddingPersonRef) ...[
                  const Divider(),
                  const Text(
                    'New Reference',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C5F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Reference Name',
                    _newPersonRefData['refName'],
                    (v) => setState(() => _newPersonRefData['refName'] = v),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Address',
                    _newPersonRefData['refAddress'],
                    (v) => setState(() => _newPersonRefData['refAddress'] = v),
                  ),
                  const SizedBox(height: 12),
                  _buildPhoneFieldInline(
                    'Telephone No.',
                    _newPersonRefData['refTelephone'],
                    (v) =>
                        setState(() => _newPersonRefData['refTelephone'] = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _isAddingPersonRef = false;
                          _newPersonRefData = {};
                        }),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveNewPersonReference,
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5F4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],

                // ── Empty state ─────────────────────────────────────────
                if (_personRefList.isEmpty && !_isAddingPersonRef)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No reference information added yet.\nTap "Add Reference" to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── List of existing references ─────────────────────────
                ...List.generate(_personRefList.length, (index) {
                  final item = _personRefList[index];
                  final bool isEditing = _editingPersonRefIndex == index;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index > 0 || _isAddingPersonRef)
                        const Divider(height: 32),

                      // Item header row with edit / delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reference ${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C5F4F),
                            ),
                          ),
                          if (isEditing)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await _fetchPersonReferenceData();
                                    setState(() => _editingPersonRefIndex = null);
                                  },
                                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton.icon(
                                  onPressed: () => _updatePersonReference(index),
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
                            )
                          else
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz, size: 22, color: Colors.black54),
                              padding: EdgeInsets.zero,
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  setState(() {
                                    _editingPersonRefIndex = index;
                                    _isAddingPersonRef = false;
                                  });
                                } else if (value == 'delete') {
                                  _deletePersonReference(index);
                                } else if (value == 'cancel') {
                                  await _fetchPersonReferenceData();
                                  setState(() => _editingPersonRefIndex = null);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.black87), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 14))]),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red))]),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Fields — editable or read-only
                      isEditing
                          ? _buildEditableFieldInline(
                              'Reference Name',
                              item['refName'],
                              (v) => setState(
                                () => _personRefList[index]['refName'] = v,
                              ),
                            )
                          : _buildInfoFieldInline(
                              'Reference Name',
                              item['refName'],
                            ),

                      const SizedBox(height: 12),

                      isEditing
                          ? _buildEditableFieldInline(
                              'Address',
                              item['refAddress'],
                              (v) => setState(
                                () => _personRefList[index]['refAddress'] = v,
                              ),
                            )
                          : _buildInfoFieldInline('Address', item['refAddress']),

                      const SizedBox(height: 12),

                      isEditing
                          ? _buildPhoneFieldInline(
                              'Telephone No.',
                              item['refTelephone'],
                              (v) => setState(
                                () =>
                                    _personRefList[index]['refTelephone'] = v,
                              ),
                            )
                          : _buildInfoFieldInline(
                              'Telephone No.',
                              item['refTelephone'],
                            ),

                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
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
    return _buildPersonReferenceCard();
  }

}