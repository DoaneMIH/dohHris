import 'package:flutter/material.dart';
import 'package:mobile_application/services/user_service.dart';

class LearningDevelopmentWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const LearningDevelopmentWidget({
    super.key,
    required this.token,
    required this.employeeId,
  });

  @override
  State<LearningDevelopmentWidget> createState() =>
      _LearningDevelopmentWidgetState();
}

class _LearningDevelopmentWidgetState
    extends State<LearningDevelopmentWidget> {
  final _userService = UserService();
  final bool _isLearningDevelopmentExpanded = true;
  List<Map<String, dynamic>> _learningDevelopmentListData = [];
  List<Map<String, dynamic>> _learningDevelopmentData = [];
  int? _editingLearningDevelopmentIndex;
  Set<int> _collapsedLearningDevIndexes = <int>{};


  @override
  void initState() {
    super.initState();
    _fetchLearningDevelopmentData();
  }

  // ─── Fetch / Parse UNCHANGED ───────────────────────────────────────────────

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
        'hours': learning['hours']?.toString() ?? '',
        'ldType': learning['ldType'] ?? '',
        'conductedBy': learning['conductedBy'] ?? '',
        'certificate_url': learning['certificate_url'] ?? '',
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

  // ─── Save / Delete UNCHANGED ───────────────────────────────────────────────

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    try {
      final employeeId = widget.employeeId;
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
              content:
                  Text('Learning and development record saved successfully'),
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

  Future<void> _deleteLearningDevelopment(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  title: Text(
    'Delete Learning and Development Record',
    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
  ),
  content: Text(
    'Are you sure you want to delete this learning and development record?',
    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context, false),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300] : Colors.black,
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

  // ─── Shared dialog helpers ─────────────────────────────────────────────────
InputDecoration _fieldDecoration(String label, {bool isDate = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey),
    floatingLabelStyle: TextStyle(
      fontSize: 16,
      color: isDark ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,
    ),
    filled: true,
    fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: isDark ? const Color(0xFF424242) : Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: isDark ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    isDense: true,
    suffixIcon: isDate
        ? Icon(Icons.calendar_today, size: 16,
            color: isDark ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,)
        : null,
  );
}

  /// Dark green header banner for dialogs.
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

  /// Full-width Cancel / Save button row.
  Widget _dialogActions(BuildContext ctx, VoidCallback onSave, {String saveLabel = 'Save'}) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
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
              backgroundColor: isDark ? const Color(0xFF3A3A3A) : Colors.grey[200],
              foregroundColor: isDark ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Cancel'),
            ),
          ),
        ],
      ),
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

  // ─── Add L&D Dialog (logic UNCHANGED) ─────────────────────────────────────

  void _showAddLearningDevelopmentDialog() {
    final titleController = TextEditingController();
    final hoursController = TextEditingController();
    final ldTypeController = TextEditingController();
    final conductedByController = TextEditingController();
    final attendedFromController = TextEditingController();
    final attendedToController = TextEditingController();

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
                  _dialogHeader('Add Training / L&D'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                              controller: titleController,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration:
                                  _fieldDecoration('Training Program Title *'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: attendedFromController,
                                    readOnly: true,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: _fieldDecoration('Date From',
                                        isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, attendedFromController.text);
                                      if (d != null) {
                                        setDialogState(() =>
                                            attendedFromController.text = d);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: attendedToController,
                                    readOnly: true,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: _fieldDecoration('Date To',
                                        isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, attendedToController.text);
                                      if (d != null) {
                                        setDialogState(() =>
                                            attendedToController.text = d);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: hoursController,
                                    cursorColor: Theme.of(context).primaryColor,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration('No. of Hours'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: ldTypeController,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: _fieldDecoration('Type of L&D'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: conductedByController,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration:
                                  _fieldDecoration('Conducted / Sponsored By'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _dialogActions(ctx, () {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter the training program title'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            final newEntry = {
                              'title': titleController.text.trim(),
                              'attendedFrom': attendedFromController.text,
                              'attendedTo': attendedToController.text,
                              'hours': hoursController.text.trim(),
                              'ldType': ldTypeController.text.trim(),
                              'conductedBy': conductedByController.text.trim(),
                              'certificate_url': '',
                            };
                            Navigator.of(ctx).pop();
                            setState(() {
                              _learningDevelopmentData.insert(0, newEntry);
                              _collapsedLearningDevIndexes =
                                  _collapsedLearningDevIndexes
                                      .map((i) => i + 1)
                                      .toSet();
                              _editingLearningDevelopmentIndex = null;
                            });
                            _saveLearningDevelopment(0);
                          }, saveLabel: 'Add'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── NEW: Edit L&D Dialog ──────────────────────────────────────────────────
  /// Same UI as Add, pre-filled with the existing record's values.
  void _showEditLearningDevelopmentDialog(int index) {
    final training = _learningDevelopmentData[index];

    final titleController =
        TextEditingController(text: training['title'] ?? '');
    final hoursController =
        TextEditingController(text: training['hours'] ?? '');
    final ldTypeController =
        TextEditingController(text: training['ldType'] ?? '');
    final conductedByController =
        TextEditingController(text: training['conductedBy'] ?? '');
    final attendedFromController =
        TextEditingController(text: training['attendedFrom'] ?? '');
    final attendedToController =
        TextEditingController(text: training['attendedTo'] ?? '');

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
                  _dialogHeader('Edit Training / L&D'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Training Program Title
                            TextField(
                              controller: titleController,
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                              decoration:
                                  _fieldDecoration('Training Program Title *'),
                            ),
                            const SizedBox(height: 12),

                            // Date From & Date To side by side
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: attendedFromController,
                                    style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                                    readOnly: true,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: _fieldDecoration('Date From',
                                        isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, attendedFromController.text);
                                      if (d != null) {
                                        setDialogState(() =>
                                            attendedFromController.text = d);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: attendedToController,
                                    style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                                    readOnly: true,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: _fieldDecoration('Date To',
                                        isDate: true),
                                    onTap: () async {
                                      final d = await _pickDate(
                                          ctx, attendedToController.text);
                                      if (d != null) {
                                        setDialogState(() =>
                                            attendedToController.text = d);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // No. of Hours & Type of L&D side by side
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: hoursController,
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration('No. of Hours'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: ldTypeController,
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                                    decoration: _fieldDecoration('Type of L&D'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Conducted / Sponsored By
                            TextField(
                              controller: conductedByController,
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
),
                              decoration:
                                  _fieldDecoration('Conducted / Sponsored By'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _dialogActions(ctx, () {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter the training program title'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Write updated values back to _learningDevelopmentData
                            setState(() {
                              _learningDevelopmentData[index]['title'] =
                                  titleController.text.trim();
                              _learningDevelopmentData[index]['attendedFrom'] =
                                  attendedFromController.text;
                              _learningDevelopmentData[index]['attendedTo'] =
                                  attendedToController.text;
                              _learningDevelopmentData[index]['hours'] =
                                  hoursController.text.trim();
                              _learningDevelopmentData[index]['ldType'] =
                                  ldTypeController.text.trim();
                              _learningDevelopmentData[index]['conductedBy'] =
                                  conductedByController.text.trim();
                            });

                            Navigator.of(ctx).pop();
                            _saveLearningDevelopment(index); // existing save flow
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

  Widget _buildLearningDevelopmentCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with Add button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const Expanded(
                  child: Text(
                    'LEARNING AND DEVELOPMENT (L&D) INTERVENTIONS/TRAINING PROGRAMS ATTENDED',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddLearningDevelopmentDialog(),
                  child: const Icon(Icons.add_circle,
                      size: 24, color: Colors.white),
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
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._learningDevelopmentData.asMap().entries.map(
                            (entry) {
                              final int index = entry.key;
                              final Map<String, dynamic> training = entry.value;
                              bool isCollapsed =
                                  _collapsedLearningDevIndexes.contains(index);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
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
                                                _collapsedLearningDevIndexes
                                                    .remove(index);
                                              } else {
                                                _collapsedLearningDevIndexes
                                                    .add(index);
                                              }
                                            }),
                                            child: Text(
                                              training['title'] ?? 'N/A',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                   color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,),
                                            ),
                                          ),
                                        ),

                                        // Collapse/expand arrow
                                        GestureDetector(
                                          onTap: () => setState(() {
                                            if (isCollapsed) {
                                              _collapsedLearningDevIndexes
                                                  .remove(index);
                                            } else {
                                              _collapsedLearningDevIndexes
                                                  .add(index);
                                            }
                                          }),
                                          child: Icon(
                                            isCollapsed
                                                ? Icons.expand_more
                                                : Icons.expand_less,
                                            size: 20,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 4),

                                        // 3-dot menu — Edit opens popup dialog
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
                                            child: Icon(Icons.more_horiz,
                                                size: 18,
                                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,),
                                          ),
                                          padding: EdgeInsets.zero,
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditLearningDevelopmentDialog(
                                                  index); // ← opens dialog
                                            } else if (value == 'delete') {
                                              _deleteLearningDevelopment(index);
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
                                                  Text('Edit',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87
                                                              )),
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
                                                      color:
                                                          Colors.red.shade600),
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
                                              children: [
                                                Expanded(
                                                  child: _buildInfoFieldInline(
                                                      'Date From',
                                                      training['attendedFrom']),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _buildInfoFieldInline(
                                                      'Date To',
                                                      training['attendedTo']),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildInfoFieldInline(
                                                      'Number of Hours',
                                                      training['hours']),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _buildInfoFieldInline(
                                                      'Type of L&D',
                                                      training['ldType']),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            _buildInfoFieldInline(
                                                'Conducted / Sponsored By',
                                                training['conductedBy']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ).toList(),
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
  if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
    displayValue = value.toString();
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 1),
      Text(displayValue,
          style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
              fontWeight: FontWeight.bold)),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return _buildLearningDevelopmentCard();
  }
}