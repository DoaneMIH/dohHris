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
  bool _isAddingPersonRef = false;
  Map<String, dynamic> _newPersonRefData = {};

  @override
  void initState() {
    super.initState();
    _fetchPersonReferenceData();
  }

  // ─── Fetch ─────────────────────────────────────────────────────────────────

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
          parsed =
              rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else if (rawList is Map) {
          parsed = [Map<String, dynamic>.from(rawList)];
        }
        setState(() => _personRefList = parsed);
        print('✅ Person references loaded: ${_personRefList.length} records');
      } else {
        print('⚠️ Person reference fetch failed: ${response['error']}');
      }
    } catch (e) {
      print('💥 Exception fetching person reference: $e');
    }
  }

  // ─── Save / Update / Delete ────────────────────────────────────────────────

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
        backgroundColor: Colors.white,
        title: const Text('Delete Reference'),
        content: const Text(
          'Are you sure you want to delete this reference record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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

  // ─── Shared dialog helpers (L&D style) ────────────────────────────────────

  /// Filled grey field with floating label — matches L&D style.
  InputDecoration _fieldDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        floatingLabelStyle:
            const TextStyle(fontSize: 16, color: Color(0xFF2C5F4F)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2C5F4F), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );

  /// Dark green header banner — matches L&D style.
  Widget _dialogHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF2C5F4F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Save / Cancel button row — matches L&D style.
  Widget _dialogActions(BuildContext ctx, VoidCallback onSave,
      {String saveLabel = 'Save'}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 16),
                  const SizedBox(width: 6),
                  Text(saveLabel),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add Reference Dialog ──────────────────────────────────────────────────

  void _showAddPersonReferenceDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final telephoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(ctx).size.width * 0.025,
                vertical: 24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader('Add Reference'),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco('Reference Name *'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: addressController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco('Address'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: telephoneController,
                            cursorColor: const Color(0xFF2C5F4F),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: _fieldDeco('Telephone No.'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _dialogActions(ctx, () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a reference name'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _newPersonRefData = {
                        'refName': nameController.text.trim(),
                        'refAddress': addressController.text.trim(),
                        'refTelephone': telephoneController.text.trim(),
                      };
                      _isAddingPersonRef = false;
                    });
                    Navigator.of(ctx).pop();
                    _saveNewPersonReference();
                  }, saveLabel: 'Save'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Edit Reference Dialog ─────────────────────────────────────────────────

  void _showEditPersonReferenceDialog(int index) {
    final item = _personRefList[index];

    final nameController =
        TextEditingController(text: item['refName'] ?? '');
    final addressController =
        TextEditingController(text: item['refAddress'] ?? '');
    final telephoneController =
        TextEditingController(text: item['refTelephone'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(ctx).size.width * 0.025,
                vertical: 24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader('Edit Reference'),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco('Reference Name *'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: addressController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco('Address'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: telephoneController,
                            cursorColor: const Color(0xFF2C5F4F),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: _fieldDeco('Telephone No.'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _dialogActions(ctx, () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a reference name'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _personRefList[index]['refName'] =
                          nameController.text.trim();
                      _personRefList[index]['refAddress'] =
                          addressController.text.trim();
                      _personRefList[index]['refTelephone'] =
                          telephoneController.text.trim();
                    });
                    Navigator.of(ctx).pop();
                    _updatePersonReference(index);
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────

  Widget _buildPersonReferenceCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──
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
                  'REFERENCES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddPersonReferenceDialog(),
                  child: const Icon(Icons.add_circle,
                      size: 20, color: Colors.white),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Empty state ──
                if (_personRefList.isEmpty && !_isAddingPersonRef)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(Icons.people_alt_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No reference information added yet.\nTap + to add a reference.',
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

                // ── List of existing references ──
                ...List.generate(_personRefList.length, (index) {
                  final item = _personRefList[index];

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
                        // ── Item header row ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reference ${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              position: PopupMenuPosition.under,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.more_horiz,
                                    size: 18, color: Colors.black87),
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _showEditPersonReferenceDialog(index);
                                } else if (value == 'delete') {
                                  _deletePersonReference(index);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  height: 30,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.edit,
                                          size: 15, color: Colors.black87),
                                      SizedBox(width: 8),
                                      Text('Edit',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(height: 8),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  height: 30,
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          size: 15,
                                          color: Colors.red.shade600),
                                      const SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        _buildInfoFieldInline('Reference Name', item['refName']),
                        const SizedBox(height: 12),
                        _buildInfoFieldInline('Address', item['refAddress']),
                        const SizedBox(height: 12),
                        _buildInfoFieldInline(
                            'Telephone No.', item['refTelephone']),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Field display helper ──────────────────────────────────────────────────

  Widget _buildInfoFieldInline(String label, dynamic value) {
    String displayValue = 'N/A';
    if (value != null &&
        value.toString().isNotEmpty &&
        value.toString() != 'null') {
      displayValue = value.toString();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 1),
        Text(displayValue,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPersonReferenceCard();
  }
}