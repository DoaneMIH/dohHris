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

        print('✅ Loaded ${_workExperienceListData.length} work experience records');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseWorkExperienceData() {
    _workExperienceData = _workExperienceListData.map((work) {
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

  // ─── Save / Delete UNCHANGED ───────────────────────────────────────────────

  Future<void> _saveWorkExperience(int index) async {
    final work = _workExperienceData[index];

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
        backgroundColor: Colors.white,
        title: const Text('Delete Work Experience'),
        content: const Text(
          'Are you sure you want to delete this work experience record?',
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

  // ─── Add Work Experience Dialog (UNCHANGED logic) ─────────────────────────

  void _showAddWorkExperienceDialog() {
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    final appointmentStatusController = TextEditingController();
    final dateFromController = TextEditingController();
    final dateToController = TextEditingController();
    String? selectedGovtService;

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
                  _dialogHeader('Add Work Experience'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                              controller: positionController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration: _fieldDecoration('Position Title *'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: companyController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration: _fieldDecoration(
                                  'Department / Agency / Office / Company'),
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
                              controller: appointmentStatusController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Status of Appointment'),
                            ),
                            const SizedBox(height: 12),
                            Theme(
                              data: Theme.of(context).copyWith(
                                popupMenuTheme: PopupMenuThemeData(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedGovtService,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                decoration:
                                    _fieldDecoration('Government Service'),
                                items: ['Yes', 'No']
                                    .map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setDialogState(
                                    () => selectedGovtService = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                 

                    // ── Buttons ──
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _dialogActions(ctx, () {
                              if (positionController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter position title'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                      
                              final newEntry = {
                                'position': positionController.text.trim(),
                                'company': companyController.text.trim(),
                                'dateFrom': dateFromController.text,
                                'dateTo': dateToController.text,
                                'appointmentStatus':
                                    appointmentStatusController.text.trim(),
                                'govtService': selectedGovtService ?? 'No',
                              };
                      
                              Navigator.of(ctx).pop();
                      
                              setState(() {
                                _workExperienceData.insert(0, newEntry);
                                _collapsedWorkExperienceIndexes =
                                    _collapsedWorkExperienceIndexes
                                        .map((i) => i + 1)
                                        .toSet();
                                _editingWorkExperienceIndex = null;
                              });
                      
                              _saveWorkExperience(0);
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

  // ─── NEW: Edit Work Experience Dialog ─────────────────────────────────────
  /// Same UI as Add, pre-filled with existing values.
  void _showEditWorkExperienceDialog(int index) {
    final work = _workExperienceData[index];

    final positionController =
        TextEditingController(text: work['position'] ?? '');
    final companyController =
        TextEditingController(text: work['company'] ?? '');
    final appointmentStatusController =
        TextEditingController(text: work['appointmentStatus'] ?? '');
    final dateFromController =
        TextEditingController(text: work['dateFrom'] ?? '');
    final dateToController =
        TextEditingController(text: work['dateTo'] ?? '');

    // Normalize govtService to 'Yes' or 'No' for the dropdown
    final rawGovt = work['govtService']?.toString().toUpperCase() ?? '';
    String? selectedGovtService =
        (rawGovt == 'YES' || rawGovt == 'TRUE') ? 'Yes' : 'No';

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
                  _dialogHeader('Edit Work Experience'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Position Title
                            TextField(
                              controller: positionController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration: _fieldDecoration('Position Title *'),
                            ),
                            const SizedBox(height: 12),

                            // Department / Agency / Office / Company
                            TextField(
                              controller: companyController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration: _fieldDecoration(
                                  'Department / Agency / Office / Company'),
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

                            // Status of Appointment
                            TextField(
                              controller: appointmentStatusController,
                              cursorColor: const Color(0xFF2C5F4F),
                              decoration:
                                  _fieldDecoration('Status of Appointment'),
                            ),
                            const SizedBox(height: 12),

                            // Government Service dropdown
                            Theme(
                              data: Theme.of(ctx).copyWith(
                                popupMenuTheme: PopupMenuThemeData(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedGovtService,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                decoration:
                                    _fieldDecoration('Government Service'),
                                items: ['Yes', 'No']
                                    .map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setDialogState(
                                    () => selectedGovtService = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                 

                    // ── Buttons ──
                    Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _dialogActions(ctx, () {
                              if (positionController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter position title'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                      
                              // Write updated values back to _workExperienceData
                              setState(() {
                                _workExperienceData[index]['position'] =
                                    positionController.text.trim();
                                _workExperienceData[index]['company'] =
                                    companyController.text.trim();
                                _workExperienceData[index]['dateFrom'] =
                                    dateFromController.text;
                                _workExperienceData[index]['dateTo'] =
                                    dateToController.text;
                                _workExperienceData[index]
                                    ['appointmentStatus'] =
                                    appointmentStatusController.text.trim();
                                _workExperienceData[index]['govtService'] =
                                    selectedGovtService ?? 'No';
                              });
                      
                              Navigator.of(ctx).pop();
                              _saveWorkExperience(index); // existing save flow
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
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                GestureDetector(
                  onTap: () => _showAddWorkExperienceDialog(),
                  child: const Icon(Icons.add_circle,
                      size: 20, color: Colors.white),
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
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._workExperienceData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> work = entry.value;
                            bool isCollapsed =
                                _collapsedWorkExperienceIndexes.contains(index);

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
                                              _collapsedWorkExperienceIndexes
                                                  .remove(index);
                                            } else {
                                              _collapsedWorkExperienceIndexes
                                                  .add(index);
                                            }
                                          }),
                                          child: Text(
                                            work['position'] ?? 'N/A',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),

                                      // Collapse/expand arrow
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          if (isCollapsed) {
                                            _collapsedWorkExperienceIndexes
                                                .remove(index);
                                          } else {
                                            _collapsedWorkExperienceIndexes
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
                                            _showEditWorkExperienceDialog(
                                                index); // ← dialog
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
                                                    'From', work['dateFrom']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'To', work['dateTo']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Department / Agency / Office / Company',
                                              work['company']),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Status of Appointment',
                                              work['appointmentStatus']),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Government Service',
                                              work['govtService']),
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
    return _buildWorkExperienceCard();
  }
}