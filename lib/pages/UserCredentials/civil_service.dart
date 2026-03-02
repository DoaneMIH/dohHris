import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class CivilServiceWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const CivilServiceWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<CivilServiceWidget> createState() => _CivilServiceWidgetState();
}

class _CivilServiceWidgetState extends State<CivilServiceWidget> {
  final _userService = UserService();
  bool _isCivilServiceExpanded = true;
  List<Map<String, dynamic>> _civilServiceData = [];
  int? _editingCivilServiceIndex;
  Set<int> _collapsedCivilServiceIndexes = <int>{};
  List<Map<String, dynamic>> _civilServiceEligibilityListData = [];

  @override
  void initState() {
    super.initState();
    _fetchCivilServiceEligibilityData();
  }

  Future<void> _fetchCivilServiceEligibilityData() async {
    print('\n📜 [UserDetailsPage] FETCHING CIVIL SERVICE ELIGIBILITY');
    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping civil service eligibility fetch');
      return;
    }
    try {
      final response = await _userService.getCivilServiceEligibilityDetails(
        widget.token,
        employeeId.toString(),
      );
      if (response['success']) {
        final List<dynamic> eligibilityList =
            response['data']['eligibilityList'] ?? [];
        setState(() {
          _civilServiceEligibilityListData = eligibilityList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _parseCivilServiceEligibilityData();
        });
        print('✅ Loaded ${_civilServiceEligibilityListData.length} civil service eligibility records');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseCivilServiceEligibilityData() {
    _civilServiceData = _civilServiceEligibilityListData.map((eligibility) {
      return {
        'id': eligibility['id'],
        'serviceEligibility': eligibility['serviceEligibility'] ?? '',
        'rating': eligibility['rating'] ?? '',
        'examPlace': eligibility['examPlace'] ?? '',
        'examDate': eligibility['examDate'] ?? '',
        'licenseNo': eligibility['licenseNo'] ?? '',
      };
    }).toList();
    _collapsedCivilServiceIndexes = List<int>.generate(
      _civilServiceData.length,
      (index) => index,
    ).toSet();
    print('📜 Parsed ${_civilServiceData.length} civil service eligibility records');
  }

  // ─── Save / Delete ─────────────────────────────────────────────────────────

  Future<void> _saveCivilServiceEligibility(int index) async {
    final eligibility = _civilServiceData[index];
    if (eligibility['serviceEligibility']?.toString().trim().isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the career service before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    try {
      final employeeId = widget.employeeId;
      final eligibilityData = {
        'serviceEligibility': eligibility['serviceEligibility'] ?? '',
        'rating': eligibility['rating'] ?? '',
        'examPlace': eligibility['examPlace'] ?? '',
        'examDate': eligibility['examDate'] ?? '',
        'licenseNo': eligibility['licenseNo'] ?? '',
      };
      final response =
          eligibility.containsKey('id') && eligibility['id'] != null
          ? await _userService.updateCivilServiceEligibility(
              widget.token, eligibility['id'].toString(), eligibilityData)
          : await _userService.addCivilServiceEligibility(
              widget.token, employeeId.toString(), eligibilityData);
      if (mounted) Navigator.pop(context);
      if (response['success']) {
        await _fetchCivilServiceEligibilityData();
        if (mounted) {
          setState(() => _editingCivilServiceIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Civil service eligibility saved successfully'),
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
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteCivilServiceEligibility(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Civil Service Eligibility'),
        content: const Text('Are you sure you want to delete this civil service eligibility record?'),
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
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    try {
      final eligibility = _civilServiceData[index];
      if (eligibility.containsKey('id') && eligibility['id'] != null) {
        final response = await _userService.deleteCivilServiceEligibility(
          widget.token, eligibility['id'].toString());
        if (mounted) Navigator.pop(context);
        if (response['success']) {
          await _fetchCivilServiceEligibilityData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Civil service eligibility deleted'), backgroundColor: Colors.green),
            );
          }
        } else {
          throw Exception(response['error']);
        }
      } else {
        if (mounted) Navigator.pop(context);
        setState(() {
          _civilServiceData.removeAt(index);
          if (_editingCivilServiceIndex == index) _editingCivilServiceIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Shared helpers ────────────────────────────────────────────────────────

  static const List<Map<String, String>> _eligibilityItems = [
    {'value': 'CSE',    'label': 'Career Service Eligibility'},
    {'value': 'RA1080', 'label': 'RA 1080 (Board/Bar) Under Special Laws'},
    {'value': 'CES',    'label': 'Career Executive Service'},
    {'value': 'CSEE',   'label': 'Career Service Executive Examination'},
    {'value': 'BE',     'label': 'Barangay Eligibility'},
    {'value': 'DL',     'label': "Driver's License"},
    {'value': 'OTHERS', 'label': 'Others'},
  ];

  String _eligibilityLabel(String? val) {
    for (final item in _eligibilityItems) {
      if (item['value'] == val) return item['label']!;
    }
    return val ?? 'N/A';
  }

  InputDecoration _fieldDecoration(String label, {bool isDate = false}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        floatingLabelStyle: const TextStyle(fontSize: 16, color: Color(0xFF2C5F4F)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2C5F4F), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
        suffixIcon: isDate
            ? const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2C5F4F))
            : null,
      );

  Widget _dialogHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF2C5F4F),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.save, size: 16), SizedBox(width: 6), Text('Save')],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // ─── Eligibility Type Bottom Sheet ────────────────────────────────────────

  Future<void> _showEligibilityBottomSheet({
    required BuildContext ctx,
    required String currentValue,
    required void Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Cap at 60% screen height so the list scrolls when needed
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.6,
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Eligibility Type',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C5F4F),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),

              // Scrollable options list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _eligibilityItems.length,
                  itemBuilder: (_, index) {
                    final item = _eligibilityItems[index];
                    final isSelected = item['value'] == currentValue;
                    return InkWell(
                      onTap: () {
                        onSelected(item['value']!);
                        Navigator.of(sheetCtx).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        color: isSelected
                            ? const Color(0xFF2C5F4F).withOpacity(0.08)
                            : Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['label']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? const Color(0xFF2C5F4F) : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, size: 18, color: Color(0xFF2C5F4F)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEligibilitySelector({
    required String selectedValue,
    required BuildContext ctx,
    required void Function(String) onChanged,
  }) {
    final label = _eligibilityLabel(selectedValue);
    return GestureDetector(
      onTap: () => _showEligibilityBottomSheet(
        ctx: ctx,
        currentValue: selectedValue,
        onSelected: onChanged,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedValue.isEmpty
                  ? const Text('Eligibility Type', style: TextStyle(fontSize: 14, color: Colors.grey))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Eligibility Type',
                          style: TextStyle(fontSize: 11, color: Color(0xFF2C5F4F), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
            ),
            const Icon(Icons.arrow_drop_down, size: 22, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ─── Add Civil Service Dialog ─────────────────────────────────────────────

  void _showAddCivilServiceDialog() {
    String selectedEligibility = 'CSE';
    final ratingController    = TextEditingController();
    final examDateController  = TextEditingController();
    final examPlaceController = TextEditingController();
    final licenseNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(ctx).size.width * 0.025,
                vertical: 24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader('Add Civil Service Eligibility'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEligibilitySelector(
                            selectedValue: selectedEligibility,
                            ctx: ctx,
                            onChanged: (v) => setDialogState(() => selectedEligibility = v),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: ratingController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Rating'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: examDateController,
                            readOnly: true,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Date of Exam', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(ctx, examDateController.text);
                              if (d != null) setDialogState(() => examDateController.text = d);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: examPlaceController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Place of Exam'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: licenseNoController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('License Number'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                      final newEntry = {
                        'serviceEligibility': selectedEligibility,
                        'rating':    ratingController.text.trim(),
                        'examDate':  examDateController.text,
                        'examPlace': examPlaceController.text.trim(),
                        'licenseNo': licenseNoController.text.trim(),
                      };
                      Navigator.of(ctx).pop();
                      setState(() {
                        _civilServiceData.insert(0, newEntry);
                        _collapsedCivilServiceIndexes =
                            _collapsedCivilServiceIndexes.map((i) => i + 1).toSet();
                        _editingCivilServiceIndex = null;
                      });
                      _saveCivilServiceEligibility(0);
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

  // ─── Edit Civil Service Dialog ────────────────────────────────────────────

  void _showEditCivilServiceDialog(int index) {
    final service = _civilServiceData[index];
    String selectedEligibility =
        _eligibilityItems.any((e) => e['value'] == service['serviceEligibility'])
            ? service['serviceEligibility']
            : 'CSE';
    final ratingController    = TextEditingController(text: service['rating']    ?? '');
    final examDateController  = TextEditingController(text: service['examDate']  ?? '');
    final examPlaceController = TextEditingController(text: service['examPlace'] ?? '');
    final licenseNoController = TextEditingController(text: service['licenseNo'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(ctx).size.width * 0.025,
                vertical: 24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader('Edit Civil Service Eligibility'),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEligibilitySelector(
                            selectedValue: selectedEligibility,
                            ctx: ctx,
                            onChanged: (v) => setDialogState(() => selectedEligibility = v),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: ratingController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Rating'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: examDateController,
                            readOnly: true,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Date of Exam', isDate: true),
                            onTap: () async {
                              final d = await _pickDate(ctx, examDateController.text);
                              if (d != null) setDialogState(() => examDateController.text = d);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: examPlaceController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('Place of Exam'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: licenseNoController,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDecoration('License Number'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _dialogActions(ctx, () {
                      setState(() {
                        _civilServiceData[index]['serviceEligibility'] = selectedEligibility;
                        _civilServiceData[index]['rating']    = ratingController.text.trim();
                        _civilServiceData[index]['examDate']  = examDateController.text;
                        _civilServiceData[index]['examPlace'] = examPlaceController.text.trim();
                        _civilServiceData[index]['licenseNo'] = licenseNoController.text.trim();
                      });
                      Navigator.of(ctx).pop();
                      _saveCivilServiceEligibility(index);
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

  Widget _buildCivilServiceCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
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
                  'CIVIL SERVICE ELIGIBILITY',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                GestureDetector(
                  onTap: () => _showAddCivilServiceDialog(),
                  child: const Icon(Icons.add_circle, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_isCivilServiceExpanded)
            Container(
              padding: const EdgeInsets.all(7.0),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _civilServiceData.isEmpty
                      ? [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No civil service records found.\nTap + to add.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                          ),
                        ]
                      : [
                          ..._civilServiceData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> service = entry.value;
                            bool isCollapsed = _collapsedCivilServiceIndexes.contains(index);
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
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            if (isCollapsed) {
                                              _collapsedCivilServiceIndexes.remove(index);
                                            } else {
                                              _collapsedCivilServiceIndexes.add(index);
                                            }
                                          }),
                                          child: Text(
                                            _eligibilityLabel(service['serviceEligibility']),
                                            style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          if (isCollapsed) {
                                            _collapsedCivilServiceIndexes.remove(index);
                                          } else {
                                            _collapsedCivilServiceIndexes.add(index);
                                          }
                                        }),
                                        child: Icon(
                                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                                          size: 20, color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        position: PopupMenuPosition.under,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          side: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(Icons.more_horiz, size: 18, color: Colors.black87),
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditCivilServiceDialog(index);
                                          } else if (value == 'delete') {
                                            _deleteCivilServiceEligibility(index);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            height: 30,
                                            child: Row(
                                              children: const [
                                                Icon(Icons.edit, size: 15, color: Colors.black87),
                                                SizedBox(width: 8),
                                                Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuDivider(height: 8),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            height: 30,
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, size: 15, color: Colors.red.shade600),
                                                const SizedBox(width: 8),
                                                Text('Delete',
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red.shade600)),
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
                                          _buildInfoFieldInline('Rating',         service['rating']),
                                          const SizedBox(height: 10),
                                          _buildInfoFieldInline('Date of Exam',   service['examDate']),
                                          const SizedBox(height: 10),
                                          _buildInfoFieldInline('Place of Exam',  service['examPlace']),
                                          const SizedBox(height: 10),
                                          _buildInfoFieldInline('License Number', service['licenseNo']),
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

  @override
  Widget build(BuildContext context) {
    return _buildCivilServiceCard();
  }
}