import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class OtherInformationWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const OtherInformationWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<OtherInformationWidget> createState() => _OtherInformationWidgetState();
}

class _OtherInformationWidgetState extends State<OtherInformationWidget> {
  final _userService = UserService();
  bool _isOtherInformationExpanded = true;
  bool _isFetchingOtherInfo = false;
  List<Map<String, dynamic>> _specialSkillsData = [];
  int? _editingSpecialSkillIndex;
  List<Map<String, dynamic>> _nonAcademicDistinctionsData = [];
  int? _editingNonAcademicDistinctionIndex;
  List<Map<String, dynamic>> _membershipData = [];
  int? _editingMembershipIndex;

  @override
  void initState() {
    super.initState();
    _fetchOtherInfoData();
  }

  // ─── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> _fetchOtherInfoData() async {
    print('\n📋 [UserDetailsPage] FETCHING OTHER INFO');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ No employee ID, skipping other info fetch');
      return;
    }

    setState(() => _isFetchingOtherInfo = true);

    try {
      final response = await _userService.getAllOtherInfo(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final List<dynamic> rawList = response['data']['otherInfoList'] ?? [];

        setState(() {
          _specialSkillsData = [];
          _nonAcademicDistinctionsData = [];
          _membershipData = [];

          for (final item in rawList) {
            final record = Map<String, dynamic>.from(item);

            final skillsRaw = record['skills']?.toString() ?? '';
            if (skillsRaw.isNotEmpty) {
              _specialSkillsData.addAll(
                skillsRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map((s) => {'skill': s, '_recordId': record['id'].toString()}),
              );
            }

            final recognitionRaw = record['recognition']?.toString() ?? '';
            if (recognitionRaw.isNotEmpty) {
              _nonAcademicDistinctionsData.addAll(
                recognitionRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map((s) => {'distinction': s, '_recordId': record['id'].toString()}),
              );
            }

            final membershipRaw = record['membership']?.toString() ?? '';
            if (membershipRaw.isNotEmpty) {
              _membershipData.addAll(
                membershipRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map((s) => {'organization': s, '_recordId': record['id'].toString()}),
              );
            }
          }

          _isFetchingOtherInfo = false;
        });

        print('✅ Other info loaded: ${rawList.length} records');
      } else {
        print('⚠️ Other info fetch failed: ${response['error']}');
        setState(() => _isFetchingOtherInfo = false);
      }
    } catch (e) {
      print('💥 Exception fetching other info: $e');
      setState(() => _isFetchingOtherInfo = false);
    }
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveOtherInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final employeeId = widget.employeeId;

      final Map<String, Map<String, List<String>>> grouped = {};

      void addToGroup(String recordId, String field, String value) {
        grouped.putIfAbsent(recordId, () => {});
        grouped[recordId]!.putIfAbsent(field, () => []);
        grouped[recordId]![field]!.add(value);
      }

      for (final e in _specialSkillsData) {
        final v = e['skill']?.toString().trim() ?? '';
        final id = e['_recordId']?.toString();
        if (v.isNotEmpty && id != null) addToGroup(id, 'skills', v);
      }
      for (final e in _nonAcademicDistinctionsData) {
        final v = e['distinction']?.toString().trim() ?? '';
        final id = e['_recordId']?.toString();
        if (v.isNotEmpty && id != null) addToGroup(id, 'recognition', v);
      }
      for (final e in _membershipData) {
        final v = e['organization']?.toString().trim() ?? '';
        final id = e['_recordId']?.toString();
        if (v.isNotEmpty && id != null) addToGroup(id, 'membership', v);
      }

      for (final entry in grouped.entries) {
        final fields = entry.value;
        final payload = {
          if (fields.containsKey('skills')) 'skills': fields['skills']!.join(', '),
          if (fields.containsKey('recognition')) 'recognition': fields['recognition']!.join(', '),
          if (fields.containsKey('membership')) 'membership': fields['membership']!.join(', '),
        };
        await _userService.updateOtherInfo(widget.token, entry.key, payload);
      }

      for (final e in _specialSkillsData) {
        final v = e['skill']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(),
              {'skills': v, 'recognition': '', 'membership': ''});
        }
      }
      for (final e in _nonAcademicDistinctionsData) {
        final v = e['distinction']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(),
              {'skills': '', 'recognition': v, 'membership': ''});
        }
      }
      for (final e in _membershipData) {
        final v = e['organization']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(),
              {'skills': '', 'recognition': '', 'membership': v});
        }
      }

      if (mounted) Navigator.pop(context);
      await _fetchOtherInfoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Other information saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
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

  // ─── Dialog helpers (L&D style) ────────────────────────────────────────────

  /// Filled grey field — matches L&D style, with optional disabled state.
  InputDecoration _fieldDeco(String label, {bool enabled = true}) =>
      
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.grey : Colors.grey[400]),
        floatingLabelStyle: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF2C5F4F) : Colors.grey[400],
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFF0F0F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
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
  Widget _dialogActions(BuildContext ctx, VoidCallback? onSave,
      {String saveLabel = 'Save'}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                backgroundColor: onSave != null
                    ? const Color(0xFF2C5F4F)
                    : Colors.grey[300],
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

  /// Section divider header — kept for Add dialog's "one field only" sections.
  Widget _sectionHeader( String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5F4F),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    );
  }

  // ─── Edit Other Info Dialog ────────────────────────────────────────────────

  Future<void> _showEditOtherInfoDialog(
    String type,
    int index,
    String currentValue,
    String? recordId,
  ) async {
    final controller = TextEditingController(text: currentValue);

    String labelText;
    String dialogTitle;

    switch (type) {
      case 'skill':
        labelText = 'Special Skill/Hobby \n';
        dialogTitle = 'Edit Special Skill/Hobby';
        break;
      case 'distinction':
        labelText = 'Non-Academic Distinction/Recognition';
        dialogTitle = 'Edit Non-Academic Distinction';
        break;
      case 'membership':
      default:
        labelText = 'Membership in Association/Organization';
        dialogTitle = 'Edit Membership';
        break;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
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
                  // ── Header ──
                  _dialogHeader(dialogTitle),

                  // ── Body ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: controller,
                            cursorColor: const Color(0xFF2C5F4F),
                            style: const TextStyle(fontSize: 14),
                            autofocus: true,
                            decoration: _fieldDeco(labelText),
                            onChanged: (v) => setDialogState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Actions ──
                  _dialogActions(
                    ctx,
                    controller.text.trim().isEmpty
                        ? null
                        : () {
                            final newValue = controller.text.trim();
                            setState(() {
                              if (type == 'skill') {
                                _specialSkillsData[index]['skill'] = newValue;
                              } else if (type == 'distinction') {
                                _nonAcademicDistinctionsData[index]
                                    ['distinction'] = newValue;
                              } else if (type == 'membership') {
                                _membershipData[index]['organization'] =
                                    newValue;
                              }
                            });
                            Navigator.of(ctx).pop();
                            _saveOtherInfo();
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
  }

  // ─── Add Other Info Dialog ─────────────────────────────────────────────────

  void _showAddOtherInfoDialog() {
    final TextEditingController skillController = TextEditingController();
    final TextEditingController distinctionController = TextEditingController();
    final TextEditingController membershipController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final bool hasSkillText = skillController.text.isNotEmpty;
            final bool hasDistinctionText = distinctionController.text.isNotEmpty;
            final bool hasMembershipText = membershipController.text.isNotEmpty;

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
                  // ── Header ──
                  _dialogHeader('Add Other Information'),

                  // ── Body ──
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hint banner
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6F3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF2C5F4F)
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline,
                                    size: 16, color: Color(0xFF2C5F4F)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fill in only ONE field below',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2C5F4F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _sectionHeader( 'Special Skill / Hobby'),
                          TextFormField(
                            controller: skillController,
                            enabled: !hasDistinctionText && !hasMembershipText,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco(
                              'Special Skill/Hobby',
                              enabled: !hasDistinctionText && !hasMembershipText,
                            ),
                            onChanged: (v) => setDialogState(() {}),
                          ),
                          const SizedBox(height: 20),

                          _sectionHeader(
                              'Non-Academic Distinction / Recognition'),
                          TextFormField(
                            controller: distinctionController,
                            enabled: !hasSkillText && !hasMembershipText,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco(
                              'Non-Academic Distinction/Recognition',
                              enabled: !hasSkillText && !hasMembershipText,
                            ),
                            onChanged: (v) => setDialogState(() {}),
                          ),
                          const SizedBox(height: 20),

                          _sectionHeader(
                              'Membership in Association / Organization'),
                          TextFormField(
                            controller: membershipController,
                            enabled: !hasSkillText && !hasDistinctionText,
                            cursorColor: const Color(0xFF2C5F4F),
                            decoration: _fieldDeco(
                              'Membership in Association/Organization',
                              enabled: !hasSkillText && !hasDistinctionText,
                            ),
                            onChanged: (v) => setDialogState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Actions ──
                  _dialogActions(ctx, () {
                    if (skillController.text.isNotEmpty) {
                      setState(() {
                        _specialSkillsData
                            .add({'skill': skillController.text});
                        _editingSpecialSkillIndex = null;
                      });
                    } else if (distinctionController.text.isNotEmpty) {
                      setState(() {
                        _nonAcademicDistinctionsData.add(
                            {'distinction': distinctionController.text});
                        _editingNonAcademicDistinctionIndex = null;
                      });
                    } else if (membershipController.text.isNotEmpty) {
                      setState(() {
                        _membershipData.add(
                            {'organization': membershipController.text});
                        _editingMembershipIndex = null;
                      });
                    }
                    Navigator.of(ctx).pop();
                    _saveOtherInfo();
                  }, saveLabel: 'Save'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────

  Widget _buildOtherInformationCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header ──
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
                  'OTHER INFORMATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddOtherInfoDialog(),
                  child: const Icon(Icons.add_circle, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),

          // ── Body ──
          if (_isOtherInformationExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Special Skills ──
                  const Text(
                    'Special Skills and Hobbies',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
                  ),
                  const SizedBox(height: 5),

                  if (_specialSkillsData.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No skills added yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ..._specialSkillsData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> skill = entry.value;
                    return Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                              child:
                                  _buildInfoFieldInline('', skill['skill'])),
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
                                _showEditOtherInfoDialog('skill', index,
                                    skill['skill']?.toString() ?? '',
                                    skill['_recordId']?.toString());
                              } else if (value == 'delete') {
                                _deleteSpecialSkill(index);
                              }
                            },
                            itemBuilder: (context) => _popupItems(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // ── Non-Academic Distinctions ──
                  const Text(
                    'Non-Academic Distinctions /\nRecognition',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
                  ),
                  const SizedBox(height: 5),

                  if (_nonAcademicDistinctionsData.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No distinctions added yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ..._nonAcademicDistinctionsData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> distinction = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildInfoFieldInline(
                                  '', distinction['distinction'])),
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
                                _showEditOtherInfoDialog(
                                    'distinction',
                                    index,
                                    distinction['distinction']?.toString() ?? '',
                                    distinction['_recordId']?.toString());
                              } else if (value == 'delete') {
                                _deleteNonAcademicDistinction(index);
                              }
                            },
                            itemBuilder: (context) => _popupItems(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // ── Membership ──
                  const Text(
                    'Membership in Association /\nOrganization',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_membershipData.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No memberships added yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ..._membershipData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> membership = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildInfoFieldInline(
                                  '', membership['organization'])),
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
                                _showEditOtherInfoDialog(
                                    'membership',
                                    index,
                                    membership['organization']?.toString() ?? '',
                                    membership['_recordId']?.toString());
                              } else if (value == 'delete') {
                                _deleteMembership(index);
                              }
                            },
                            itemBuilder: (context) => _popupItems(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Shared popup menu items ───────────────────────────────────────────────

  List<PopupMenuEntry<String>> _popupItems() => [
        PopupMenuItem<String>(
          value: 'edit',
          height: 30,
          child: Row(
            children: const [
              Icon(Icons.edit, size: 15, color: Colors.black87),
              SizedBox(width: 8),
              Text('Edit',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade600)),
            ],
          ),
        ),
      ];

  // ─── Display helper ────────────────────────────────────────────────────────

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
              color: Colors.grey[600],
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 1),
        Text(
          displayValue,
          style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── Delete confirmations ──────────────────────────────────────────────────

  Future<void> _deleteSpecialSkill(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Special Skill'),
        content: const Text(
            'Are you sure you want to delete this special skill?'),
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

    final skill = _specialSkillsData[index];
    final recordId = skill['_recordId']?.toString();
    if (recordId == null) {
      setState(() {
        _specialSkillsData.removeAt(index);
        if (_editingSpecialSkillIndex == index) _editingSpecialSkillIndex = null;
      });
      return;
    }
    final response =
        await _userService.deleteOtherInfo(widget.token, recordId);
    if (response['success']) {
      await _fetchOtherInfoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Skill deleted successfully'),
            backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete: ${response['error']}'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteNonAcademicDistinction(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Non-Academic Distinction'),
        content: const Text(
            'Are you sure you want to delete this non-academic distinction?'),
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

    final distinction = _nonAcademicDistinctionsData[index];
    final recordId = distinction['_recordId']?.toString();
    if (recordId == null) {
      setState(() {
        _nonAcademicDistinctionsData.removeAt(index);
        if (_editingNonAcademicDistinctionIndex == index)
          _editingNonAcademicDistinctionIndex = null;
      });
      return;
    }
    final response =
        await _userService.deleteOtherInfo(widget.token, recordId);
    if (response['success']) {
      await _fetchOtherInfoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Distinction deleted successfully'),
            backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete: ${response['error']}'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteMembership(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Membership'),
        content: const Text(
            'Are you sure you want to delete this membership record?'),
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

    final membership = _membershipData[index];
    final recordId = membership['_recordId']?.toString();
    if (recordId == null) {
      setState(() {
        _membershipData.removeAt(index);
        if (_editingMembershipIndex == index) _editingMembershipIndex = null;
      });
      return;
    }
    final response =
        await _userService.deleteOtherInfo(widget.token, recordId);
    if (response['success']) {
      await _fetchOtherInfoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Membership deleted successfully'),
            backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete: ${response['error']}'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildOtherInformationCard();
  }
}