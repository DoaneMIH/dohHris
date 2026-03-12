import 'package:flutter/material.dart';
import 'package:mobile_application/services/user_service.dart';

class EducationalBackgroundWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const EducationalBackgroundWidget({
    super.key,
    required this.token,
    required this.employeeId,
  });

  @override
  State<EducationalBackgroundWidget> createState() =>
      _EducationalBackgroundWidgetState();
}

class _EducationalBackgroundWidgetState
    extends State<EducationalBackgroundWidget> {
  final _userService = UserService();
  List<Map<String, dynamic>> _educationListData = [];
  List<Map<String, dynamic>> _educationData = [];
  int? _editingEducationIndex;
  Set<int> _collapsedEducationIndexes = <int>{};
  // bool _isNewEduc = false;
  final bool _isEducationalBackgroundExpanded = true;

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

  // ─── Save / Delete UNCHANGED ───────────────────────────────────────────────

  Future<void> _saveEducation(int index) async {
    final education = _educationData[index];

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final employeeId = widget.employeeId;

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
              backgroundColor: Color(0xFF1F2A45),
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
        backgroundColor: Colors.white,
        title: const Text('Delete Education'),
        content: const Text(
          'Are you sure you want to delete this education record?',
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
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                backgroundColor: Color(0xFF1F2A45),
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

  // ─── Shared helpers ────────────────────────────────────────────────────────

  /// Shared field decoration — filled grey style.
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
          ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
          : Theme.of(context).primaryColor,              // ← dark green in light
    ),
    filled: true,
    fillColor: isDark
        ? const Color(0xFF2C2C2C)       // ← dark fill
        : const Color(0xFFF5F5F5),      // ← light fill
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
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    isDense: true,
    suffixIcon: isDate
        ? Icon(
            Icons.calendar_today,
            size: 18,
            color: isDark
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).primaryColor,
          )
        : null,
  );
}
  /// Dark green header for dialogs.
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

  // ── Shared helper: dialog action buttons ─────────────────────────────────
  Widget _dialogActions(BuildContext ctx, VoidCallback onSave, {String saveLabel = 'Save'}) {
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

  /// Date picker helper shared between Add and Edit dialogs.
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

  // ─── NEW: Education Level Popup Bottom Sheet ──────────────────────────────
  /// Shows a bottom sheet popup for selecting education level.
  /// Matches the text field style (filled grey, same border radius).
  Future<void> _showLevelBottomSheet({
    required BuildContext ctx,
    required String currentLevel,
    required List<String> levels,
    required void Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: ctx,
     backgroundColor: Theme.of(context).scaffoldBackgroundColor,  // ← was Colors.white
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Education Level',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary
      : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              // Level options
              ...levels.map((level) {
                final isSelected = level == currentLevel;
                return InkWell(
                  onTap: () {
                    onSelected(level);
                    Navigator.of(sheetCtx).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    color: isSelected
                         ? Theme.of(context).primaryColor.withOpacity(0.08)
                                    : Colors.transparent,   // ← was Colors.white? const Color(0xFF2C5F4F).withOpacity(0.08)
                       
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                     ? Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).primaryColor
    : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,


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
                            color: Theme.of(context).brightness == Brightness.dark
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

  /// Builds the education level selector button that mimics the text field style
  /// but opens a bottom sheet popup on tap.
  Widget _buildLevelSelector({
    required String selectedLevel,
    required List<String> levels,
    required BuildContext ctx,
    required void Function(String) onChanged,
  }) {
    return GestureDetector(
      onTap: () => _showLevelBottomSheet(
        ctx: ctx,
        currentLevel: selectedLevel,
        levels: levels,
        onSelected: onChanged,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2C2C2C)   // ← dark fill
      : const Color(0xFFF5F5F5),  // ← light fill
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedLevel.isEmpty
                  ? const Text(
                      'Education Level',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Text(
                          'Education Level',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary
      : Theme.of(context).primaryColor,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedLevel,
                          style: TextStyle(
                            fontSize: 14,
                             color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                          ),
                        ),
                      ],
                    ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 22,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add Education Dialog ─────────────────────────────────────────────────

  void _showAddEducationDialog() {
    String selectedLevel = 'ELEMENTARY';
    final schoolController = TextEditingController();
    final degreeController = TextEditingController();
    final attendedFromController = TextEditingController();
    final attendedToController = TextEditingController();
    final highestLevelController = TextEditingController();
    final yearGraduatedController = TextEditingController();
    final academicHonorsController = TextEditingController();
    bool onGoing = false;

    final levels = [
      'ELEMENTARY',
      'SECONDARY',
      'VOCATIONAL/TRADE COURSE',
      'COLLEGE',
      'GRADUATE STUDIES',
    ];

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
                // vertical: 24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader('Add Education'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Education Level popup button ──
                          _buildLevelSelector(
                            selectedLevel: selectedLevel,
                            levels: levels,
                            ctx: ctx,
                            onChanged: (v) =>
                                setDialogState(() => selectedLevel = v),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: schoolController,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              // ← add this to every TextField
                              fontSize: 13,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color ??
                                  Colors.black87,
                            ),
                            decoration: _fieldDecoration('School Name *'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: degreeController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: _fieldDecoration('Degree / Course'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: attendedFromController,
                            readOnly: true,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Attended From', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(
                                  ctx, attendedFromController.text);
                              if (d != null) {
                                setDialogState(
                                    () => attendedFromController.text = d);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: attendedToController,
                            readOnly: true,
                            enabled: !onGoing,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Attended To', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(
                                  ctx, attendedToController.text);
                              if (d != null) {
                                setDialogState(
                                    () => attendedToController.text = d);
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Checkbox(
                                value: onGoing,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (v) {
                                  setDialogState(() {
                                    onGoing = v!;
                                    if (onGoing) attendedToController.clear();
                                  });
                                },
                              ),
                               Text('On-going',
                                  style: TextStyle(fontSize: 13,
                                   color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                  )),
                                  
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: highestLevelController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Highest Level Earned'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: yearGraduatedController,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Year Graduated'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: academicHonorsController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: _fieldDecoration('Academic Honors'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Buttons ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: _dialogActions(ctx, () {
                      if (schoolController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter school name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final newEntry = {
                        'level': selectedLevel,
                        'schoolName': schoolController.text.trim(),
                        'degreeCourse': degreeController.text.trim(),
                        'attendedFrom': attendedFromController.text,
                        'attendedTo': attendedToController.text,
                        'highestLevel': highestLevelController.text.trim(),
                        'yearGraduated': yearGraduatedController.text.trim(),
                        'academicHonors': academicHonorsController.text.trim(),
                        'onGoing': onGoing,
                      };

                      Navigator.of(ctx).pop();

                      setState(() {
                        _educationData.insert(0, newEntry);
                        _collapsedEducationIndexes = _collapsedEducationIndexes
                            .map((i) => i + 1)
                            .toSet();
                        _editingEducationIndex = null;
                        // _isNewEduc = false;
                      });

                      _saveEducation(0);
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

  // ─── Edit Education Dialog ────────────────────────────────────────────────
  void _showEditEducationDialog(int index) {
    final education = _educationData[index];

    String selectedLevel =
        (education['level']?.toString().isNotEmpty ?? false)
            ? education['level']
            : 'ELEMENTARY';

    final schoolController =
        TextEditingController(text: education['schoolName'] ?? '');
    final degreeController =
        TextEditingController(text: education['degreeCourse'] ?? '');
    final attendedFromController =
        TextEditingController(text: education['attendedFrom'] ?? '');
    final attendedToController =
        TextEditingController(text: education['attendedTo'] ?? '');
    final highestLevelController =
        TextEditingController(text: education['highestLevel'] ?? '');
    final yearGraduatedController =
        TextEditingController(text: education['yearGraduated'] ?? '');
    final academicHonorsController =
        TextEditingController(text: education['academicHonors'] ?? '');
    bool onGoing = education['onGoing'] ?? false;

    final levels = [
      'ELEMENTARY',
      'SECONDARY',
      'VOCATIONAL/TRADE COURSE',
      'COLLEGE',
      'GRADUATE STUDIES',
    ];

    if (!levels.contains(selectedLevel)) selectedLevel = 'ELEMENTARY';

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
                  _dialogHeader('Edit Education'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Education Level popup button ──
                          _buildLevelSelector(
                            selectedLevel: selectedLevel,
                            levels: levels,
                            ctx: ctx,
                            onChanged: (v) =>
                                setDialogState(() => selectedLevel = v),
                          ),
                          const SizedBox(height: 12),

                          // School Name
                          TextField(
                            controller: schoolController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: _fieldDecoration('School Name *'),
                          ),
                          const SizedBox(height: 12),

                          // Degree / Course
                          TextField(
                            controller: degreeController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: _fieldDecoration('Degree / Course'),
                          ),
                          const SizedBox(height: 12),

                          // Attended From
                          TextField(
                            controller: attendedFromController,
                            readOnly: true,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Attended From', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(
                                  ctx, attendedFromController.text);
                              if (d != null) {
                                setDialogState(
                                    () => attendedFromController.text = d);
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // Attended To
                          TextField(
                            controller: attendedToController,
                            readOnly: true,
                            enabled: !onGoing,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Attended To', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(
                                  ctx, attendedToController.text);
                              if (d != null) {
                                setDialogState(
                                    () => attendedToController.text = d);
                              }
                            },
                          ),
                          const SizedBox(height: 4),

                          // On-going checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: onGoing,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (v) {
                                  setDialogState(() {
                                    onGoing = v!;
                                    if (onGoing) attendedToController.clear();
                                  });
                                },
                              ),
                              const Text('On-going',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Highest Level Earned
                          TextField(
                            controller: highestLevelController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration:
                                _fieldDecoration('Highest Level Earned'),
                          ),
                          const SizedBox(height: 12),

                          // Year Graduated
                          TextField(
                            controller: yearGraduatedController,
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Year Graduated'),
                          ),
                          const SizedBox(height: 12),

                          // Academic Honors
                          TextField(
                            controller: academicHonorsController,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: _fieldDecoration('Academic Honors'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Buttons ──
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                      if (schoolController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter school name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Write updated values back to _educationData
                      setState(() {
                        _educationData[index]['level'] = selectedLevel;
                        _educationData[index]['schoolName'] =
                            schoolController.text.trim();
                        _educationData[index]['degreeCourse'] =
                            degreeController.text.trim();
                        _educationData[index]['attendedFrom'] =
                            attendedFromController.text;
                        _educationData[index]['attendedTo'] =
                            attendedToController.text;
                        _educationData[index]['highestLevel'] =
                            highestLevelController.text.trim();
                        _educationData[index]['yearGraduated'] =
                            yearGraduatedController.text.trim();
                        _educationData[index]['academicHonors'] =
                            academicHonorsController.text.trim();
                        _educationData[index]['onGoing'] = onGoing;
                      });

                      Navigator.of(ctx).pop();
                      _saveEducation(index);
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

  Widget _buildEducationalBackgroundCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with Add button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
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
                GestureDetector(
                  onTap: () => _showAddEducationDialog(),
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
                            bool isCollapsed =
                                _collapsedEducationIndexes.contains(index);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                             
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title row — collapse toggle + 3-dot menu
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Tappable title area
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isCollapsed) {
                                                _collapsedEducationIndexes
                                                    .remove(index);
                                              } else {
                                                _collapsedEducationIndexes
                                                    .add(index);
                                              }
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                education['level'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                   color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white          // ← white in dark
        : Colors.black,         // ← black in lightblack,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (isCollapsed)
                                                Text(
                                                  education['schoolName'] ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]   // ← lighter in dark
          : Colors.grey[600],  // ← same in light
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Collapse / expand arrow
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isCollapsed) {
                                              _collapsedEducationIndexes
                                                  .remove(index);
                                            } else {
                                              _collapsedEducationIndexes
                                                  .add(index);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isCollapsed
                                              ? Icons.expand_more
                                              : Icons.expand_less,
                                          size: 20,
                                         color: Theme.of(context).brightness == Brightness.dark
      ? Colors.white    // ← white in dark
      : Colors.black,   // ← black in light
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // 3-dot menu
                                      PopupMenuButton<String>(
                                        color: Theme.of(context).scaffoldBackgroundColor,
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
                                            color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black87,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditEducationDialog(index);
                                          } else if (value == 'delete') {
                                            _deleteEducation(index);
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
                                                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                     color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
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

                                  // Collapsible display-only fields
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoFieldInline(
                                              'School Name',
                                              education['schoolName']),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Degree/Course',
                                              education['degreeCourse']),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'From',
                                                    education['attendedFrom']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'To',
                                                    education['attendedTo']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'Highest Level/Units',
                                                    education['highestLevel']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildInfoFieldInline(
                                                    'Year Graduated',
                                                    education['yearGraduated']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildInfoFieldInline(
                                              'Academic Honors',
                                              education['academicHonors']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
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
        Text(
          label,
          style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]   // ← lighter grey in dark
              : Colors.grey[600],  // ← same as before in light
          fontWeight: FontWeight.w500,
        ),
      ),
        const SizedBox(height: 1),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 15,
            color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black87,
            fontWeight: FontWeight.bold,
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