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

        print('✅ Loaded ${_voluntaryWorkListData.length} voluntary work records');
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

  // ─── Save / Delete UNCHANGED ───────────────────────────────────────────────

  Future<void> _saveVoluntaryWork(int index) async {
    final voluntary = _voluntaryWorkData[index];

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
        backgroundColor: Colors.white,
        title: const Text('Delete Voluntary Work'),
        content: const Text(
          'Are you sure you want to delete this voluntary work record?',
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

  // ─── Shared helpers ────────────────────────────────────────────────────────

  InputDecoration _fieldDecoration(String label, {bool isDate = false}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        floatingLabelStyle: const TextStyle(fontSize: 16, color: Color(0xFF2C5F4F)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
        suffixIcon: isDate
            ? const Icon(Icons.calendar_today,
                size: 16, color: Color(0xFF2C5F4F))
            : null,
      );

  /// Dark green header for dialogs.
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

  /// Full-width Save / Cancel buttons.
  Widget _dialogActions(BuildContext ctx, VoidCallback onSave, {String saveLabel = 'Save'}) {
    return Row(
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 16),
                SizedBox(width: 6),
                Text('Save'),
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
    );
  }

  Future<String?> _pickDate(BuildContext ctx, String current) async {
    DateTime? initial;
    if (current.isNotEmpty) initial = DateTime.tryParse(current);
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2C5F4F),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  // ─── Add Voluntary Work Dialog (UNCHANGED logic) ──────────────────────────

  void _showAddVoluntaryWorkDialog() {
    final organizationController = TextEditingController();
    final hoursController = TextEditingController();
    final workController = TextEditingController();
    final dateFromController = TextEditingController();
    final dateToController = TextEditingController();

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
                  _dialogHeader('Add Voluntary Work'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                              controller: organizationController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Name of Organization *'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: dateFromController,
                                    readOnly: true,
                                    cursorColor: const Color(0xFF2C5F4F),
                                    decoration:
                                        _fieldDecoration('From', isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, dateFromController.text);
                                      if (d != null) {
                                        setDialogState(
                                            () => dateFromController.text = d);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: dateToController,
                                    readOnly: true,
                                    cursorColor: const Color(0xFF2C5F4F),
                                    decoration:
                                        _fieldDecoration('To', isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, dateToController.text);
                                      if (d != null) {
                                        setDialogState(
                                            () => dateToController.text = d);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: hoursController,
                              cursorColor: const Color(0xFF2C5F4F),
                              keyboardType: TextInputType.number,
                              decoration: _fieldDecoration('Number of Hours'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: workController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Position / Nature of Work'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                              if (organizationController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter organization name'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                    
                              final newEntry = {
                                'organization':
                                    organizationController.text.trim(),
                                'dateFrom': dateFromController.text,
                                'dateTo': dateToController.text,
                                'hours': hoursController.text.trim(),
                                'work': workController.text.trim(),
                              };
                    
                              Navigator.of(ctx).pop();
                    
                              setState(() {
                                _voluntaryWorkData.insert(0, newEntry);
                                _collapsedVoluntaryWorkIndexes =
                                    _collapsedVoluntaryWorkIndexes
                                        .map((i) => i + 1)
                                        .toSet();
                                _editingVoluntaryWorkIndex = null;
                              });
                    
                              _saveVoluntaryWork(0);
                            }, saveLabel: 'Add'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── NEW: Edit Voluntary Work Dialog ──────────────────────────────────────
  /// Same UI as Add, pre-filled with existing values.
  void _showEditVoluntaryWorkDialog(int index) {
    final voluntary = _voluntaryWorkData[index];

    final organizationController =
        TextEditingController(text: voluntary['organization'] ?? '');
    final hoursController =
        TextEditingController(text: voluntary['hours'] ?? '');
    final workController =
        TextEditingController(text: voluntary['work'] ?? '');
    final dateFromController =
        TextEditingController(text: voluntary['dateFrom'] ?? '');
    final dateToController =
        TextEditingController(text: voluntary['dateTo'] ?? '');

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
                  _dialogHeader('Edit Voluntary Work'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Name of Organization
                            TextField(
                              controller: organizationController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Name of Organization *'),
                            ),
                            const SizedBox(height: 12),

                            // Date From & Date To side by side
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: dateFromController,
                                    readOnly: true,
                                    cursorColor: const Color(0xFF2C5F4F),
                                    decoration:
                                        _fieldDecoration('From', isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, dateFromController.text);
                                      if (d != null) {
                                        setDialogState(
                                            () => dateFromController.text = d);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: dateToController,
                                    readOnly: true,
                                    cursorColor: const Color(0xFF2C5F4F),
                                    decoration:
                                        _fieldDecoration('To', isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, dateToController.text);
                                      if (d != null) {
                                        setDialogState(
                                            () => dateToController.text = d);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Number of Hours
                            TextField(
                              controller: hoursController,
                              cursorColor: const Color(0xFF2C5F4F),
                              keyboardType: TextInputType.number,
                              decoration: _fieldDecoration('Number of Hours'),
                            ),
                            const SizedBox(height: 12),

                            // Position / Nature of Work
                            TextField(
                              controller: workController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Position / Nature of Work'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                              if (organizationController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter organization name'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                    
                              // Write updated values back to _voluntaryWorkData
                              setState(() {
                                _voluntaryWorkData[index]['organization'] =
                                    organizationController.text.trim();
                                _voluntaryWorkData[index]['dateFrom'] =
                                    dateFromController.text;
                                _voluntaryWorkData[index]['dateTo'] =
                                    dateToController.text;
                                _voluntaryWorkData[index]['hours'] =
                                    hoursController.text.trim();
                                _voluntaryWorkData[index]['work'] =
                                    workController.text.trim();
                              });
                    
                              Navigator.of(ctx).pop();
                              _saveVoluntaryWork(index); // existing save flow
                            }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────

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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddVoluntaryWorkDialog(),
                  child: const Icon(Icons.add_circle,
                      size: 24, color: Colors.white),
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
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._voluntaryWorkData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> voluntary = entry.value;
                            bool isCollapsed =
                                _collapsedVoluntaryWorkIndexes.contains(index);

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
                                  // ── Title row ──
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Tappable title — toggles collapse
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            if (isCollapsed) {
                                              _collapsedVoluntaryWorkIndexes
                                                  .remove(index);
                                            } else {
                                              _collapsedVoluntaryWorkIndexes
                                                  .add(index);
                                            }
                                          }),
                                          child: Text(
                                            voluntary['organization'] ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Collapse/expand arrow
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          if (isCollapsed) {
                                            _collapsedVoluntaryWorkIndexes
                                                .remove(index);
                                          } else {
                                            _collapsedVoluntaryWorkIndexes
                                                .add(index);
                                          }
                                        }),
                                        child: Icon(
                                          isCollapsed
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // 3-dot menu — Edit opens dialog
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        position: PopupMenuPosition.under,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(Icons.more_horiz,
                                              size: 18, color: Colors.black87),
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditVoluntaryWorkDialog(
                                                index); // ← dialog
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
                                                Icon(Icons.edit,
                                                    size: 15,
                                                    color: Colors.black87),
                                                SizedBox(width: 8),
                                                Text('Edit',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500)),
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .red.shade600)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // ── Collapsible display-only fields ──
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'Date From',
                                                    voluntary['dateFrom']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'Date To',
                                                    voluntary['dateTo']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Number of Hours',
                                              voluntary['hours']),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Position / Nature of Work',
                                              voluntary['work']),
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

  // ─── Field display helpers (UNCHANGED) ────────────────────────────────────

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
    return _buildVoluntaryWorkCard();
  }
}