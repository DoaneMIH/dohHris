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

  // ─── Save / Delete ─────────────────────────────────────────────────────────

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
            SnackBar(
              content: const Text('Work experience saved successfully'),
              backgroundColor: Theme.of(context).primaryColor,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Delete Work Experience',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this work experience record?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black,
            ),
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
              SnackBar(
                content: Text('Work experience deleted'),
                backgroundColor: Theme.of(context).primaryColor,
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

  InputDecoration _fieldDecoration(String label, {bool isDate = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey[400] : Colors.grey,
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 16,
        color: isDark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).primaryColor,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF424242) : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
      suffixIcon: isDate
          ? Icon(
              Icons.calendar_today,
              size: 16,
              color: isDark
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _dialogHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
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

  Widget _dialogActions(BuildContext ctx, VoidCallback onSave,
      {String saveLabel = 'Save'}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
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
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200],
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
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
            primary: Color(0xFF1F2A45),
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

  // ─── Government Service Bottom Sheet ──────────────────────────────────────

  Future<void> _showGovtServiceBottomSheet({
    required BuildContext ctx,
    required String currentValue,
    required void Function(String) onSelected,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: ctx,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Government Service',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ...['Yes', 'No'].map((option) {
                final isSelected = option == currentValue;
                return InkWell(
                  onTap: () {
                    onSelected(option);
                    Navigator.of(sheetCtx).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.08)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? (isDark
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).primaryColor)
                                  : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color ??
                                      Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            size: 18,
                            color: isDark
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGovtServiceSelector({
  required String selectedValue,
  required BuildContext ctx,
  required void Function(String) onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return GestureDetector(
    onTap: () => _showGovtServiceBottomSheet(
      ctx: ctx,
      currentValue: selectedValue,
      onSelected: onChanged,
    ),
    child: InputDecorator(
      decoration: _fieldDecoration('Government Service').copyWith(
        suffixIcon: Icon(
          Icons.arrow_drop_down,
          size: 22,
          color: isDark ? Colors.grey[400] : Colors.grey,
        ),
      ),
      child: Text(
        selectedValue,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
        ),
      ),
    ),
  );
}

  // ─── Add Work Experience Dialog ────────────────────────────────────────────

  void _showAddWorkExperienceDialog() {
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    final appointmentStatusController = TextEditingController();
    final dateFromController = TextEditingController();
    final dateToController = TextEditingController();
    String selectedGovtService = 'No';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
                            decoration: _fieldDecoration('Position Title *'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: companyController,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
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
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.black87,
                                  ),
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
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.black87,
                                  ),
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
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
                            decoration:
                                _fieldDecoration('Status of Appointment'),
                          ),
                          const SizedBox(height: 12),
                          // ── Government Service bottom sheet selector ──
                          _buildGovtServiceSelector(
                            selectedValue: selectedGovtService,
                            ctx: ctx,
                            onChanged: (v) =>
                                setDialogState(() => selectedGovtService = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                      if (positionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter position title'),
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
                        'govtService': selectedGovtService,
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

  // ─── Edit Work Experience Dialog ───────────────────────────────────────────

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

    final rawGovt = work['govtService']?.toString().toUpperCase() ?? '';
    String selectedGovtService =
        (rawGovt == 'YES' || rawGovt == 'TRUE') ? 'Yes' : 'No';

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          TextField(
                            controller: positionController,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
                            decoration: _fieldDecoration('Position Title *'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: companyController,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
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
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.black87,
                                  ),
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
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.black87,
                                  ),
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
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
                            decoration:
                                _fieldDecoration('Status of Appointment'),
                          ),
                          const SizedBox(height: 12),
                          // ── Government Service bottom sheet selector ──
                          _buildGovtServiceSelector(
                            selectedValue: selectedGovtService,
                            ctx: ctx,
                            onChanged: (v) =>
                                setDialogState(() => selectedGovtService = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                      if (positionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter position title'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _workExperienceData[index]['position'] =
                            positionController.text.trim();
                        _workExperienceData[index]['company'] =
                            companyController.text.trim();
                        _workExperienceData[index]['dateFrom'] =
                            dateFromController.text;
                        _workExperienceData[index]['dateTo'] =
                            dateToController.text;
                        _workExperienceData[index]['appointmentStatus'] =
                            appointmentStatusController.text.trim();
                        _workExperienceData[index]['govtService'] =
                            selectedGovtService;
                      });

                      Navigator.of(ctx).pop();
                      _saveWorkExperience(index);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
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
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
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
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      PopupMenuButton<String>(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        position: PopupMenuPosition.under,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.more_horiz,
                                            size: 18,
                                            color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color ??
                                                Colors.black87,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditWorkExperienceDialog(
                                                index);
                                          } else if (value == 'delete') {
                                            _deleteWorkExperience(index);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            height: 30,
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    size: 15,
                                                    color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color ??
                                                        Colors.black87),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color ??
                                                        Colors.black87,
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
                                                Icon(Icons.delete,
                                                    size: 15,
                                                    color: Colors.red.shade600),
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

  // ─── Field display helpers ─────────────────────────────────────────────────

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
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Colors.black87,
            fontWeight: FontWeight.bold,
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