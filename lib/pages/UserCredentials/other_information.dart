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
  // bool _isEditingOtherInfo = false;
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
          // Flatten all entries into the three lists
          _specialSkillsData = [];
          _nonAcademicDistinctionsData = [];
          _membershipData = [];

          for (final item in rawList) {
            final record = Map<String, dynamic>.from(item);

            // Skills
            final skillsRaw = record['skills']?.toString() ?? '';
            if (skillsRaw.isNotEmpty) {
              _specialSkillsData.addAll(
                skillsRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map(
                      (s) => {'skill': s, '_recordId': record['id'].toString()},
                    ),
              );
            }

            // Recognition
            final recognitionRaw = record['recognition']?.toString() ?? '';
            if (recognitionRaw.isNotEmpty) {
              _nonAcademicDistinctionsData.addAll(
                recognitionRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map(
                      (s) => {
                        'distinction': s,
                        '_recordId': record['id'].toString(),
                      },
                    ),
              );
            }

            // Membership
            final membershipRaw = record['membership']?.toString() ?? '';
            if (membershipRaw.isNotEmpty) {
              _membershipData.addAll(
                membershipRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map(
                      (s) => {
                        'organization': s,
                        '_recordId': record['id'].toString(),
                      },
                    ),
              );
            }
          }

          // Keep the first record for save/update reference

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

  Future<void> _saveOtherInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = widget.employeeId;

      // ── 1. Handle EXISTING records: group by _recordId and update only changed fields ──
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
          if (fields.containsKey('skills'))
            'skills': fields['skills']!.join(', '),
          if (fields.containsKey('recognition'))
            'recognition': fields['recognition']!.join(', '),
          if (fields.containsKey('membership'))
            'membership': fields['membership']!.join(', '),
        };
        await _userService.updateOtherInfo(widget.token, entry.key, payload);
      }

      // ── 2. Handle NEW items: each one gets its own addOtherInfo call ──
      // New skills — each becomes its own record
      for (final e in _specialSkillsData) {
        final v = e['skill']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(), {
            'skills': v,
            'recognition': '',
            'membership': '',
          });
        }
      }

      // New recognitions — each becomes its own record
      for (final e in _nonAcademicDistinctionsData) {
        final v = e['distinction']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(), {
            'skills': '',
            'recognition': v,
            'membership': '',
          });
        }
      }

      // New memberships — each becomes its own record
      for (final e in _membershipData) {
        final v = e['organization']?.toString().trim() ?? '';
        if (v.isNotEmpty && e['_recordId'] == null) {
          await _userService.addOtherInfo(widget.token, employeeId.toString(), {
            'skills': '',
            'recognition': '',
            'membership': v,
          });
        }
      }

      if (mounted) Navigator.pop(context);
      await _fetchOtherInfoData();
      if (mounted) {
        // setState(() => _isEditingOtherInfo = false);
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

  Widget _buildOtherInformationCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                Row(
                  children: [
                    if (_isFetchingOtherInfo)
                      const SizedBox(
                        // width: 16,
                        // height: 16,
                        child: CircularProgressIndicator(
                          // strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    // if (!_isFetchingOtherInfo) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        size: 18,
                        color: Colors.white,
                      ),
                      tooltip: 'Add',
                      onPressed: _showAddOtherInfoDialog,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          if (_isOtherInformationExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Special Skills and Hobbies ────────────────────
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
                    final bool isEditing = _editingSpecialSkillIndex == index;

                    return Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: isEditing
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEditableFieldInline(
                                        '',
                                        skill['skill'],
                                        (value) =>
                                            _specialSkillsData[index]['skill'] =
                                                value,
                                      ),
                                      const SizedBox(height: 8),
                                      // ✅ Save and Cancel buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(() {
                                              _editingSpecialSkillIndex = null;
                                            }),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await _saveOtherInfo();
                                              setState(
                                                () =>
                                                    _editingSpecialSkillIndex =
                                                        null,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.save,
                                              size: 16,
                                            ),
                                            label: const Text('Save'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2C5F4F,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : _buildInfoFieldInline('', skill['skill']),
                          ),
                          // ✅ Only show 3-dots when NOT editing
                          if (!isEditing)
                            PopupMenuButton<String>(
                              color: Colors.white,
                              position: PopupMenuPosition.under,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
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
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  setState(
                                    () => _editingSpecialSkillIndex = index,
                                  );
                                } else if (value == 'delete') {
                                  final recordId = skill['_recordId']
                                      ?.toString();
                                  if (recordId == null) {
                                    setState(() {
                                      _specialSkillsData.removeAt(index);
                                      if (_editingSpecialSkillIndex == index)
                                        _editingSpecialSkillIndex = null;
                                    });
                                    return;
                                  }
                                  final response = await _userService
                                      .deleteOtherInfo(widget.token, recordId);
                                  if (response['success']) {
                                    await _fetchOtherInfoData();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Skill deleted successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to delete: ${response['error']}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          // Expanded(
                          //   child: isEditing
                          //       ? _buildEditableFieldInline(
                          //           '',
                          //           skill['skill'],
                          //           (value) => _specialSkillsData[index]['skill'] = value,
                          //         )
                          //       : _buildInfoFieldInline('', skill['skill']),
                          // ),
                          // if (isEditing)
                          //   IconButton(
                          //     icon: const Icon(Icons.check, size: 18, color: Color(0xFF2C5F4F)),
                          //     onPressed: () async {
                          //       if (isEditing || _isEditingOtherInfo) {
                          //         await _saveOtherInfo();
                          //       }
                          //       setState(() { _editingSpecialSkillIndex = null; });
                          //     },
                          //     padding: EdgeInsets.zero,
                          //     constraints: const BoxConstraints(),
                          //   )
                          // else
                          //   PopupMenuButton<String>(
                          //     icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black54),
                          //     padding: EdgeInsets.zero,
                          //     onSelected: (value) async {
                          //       if (value == 'edit') {
                          //         setState(() { _editingSpecialSkillIndex = index; });
                          //       } else if (value == 'delete') {
                          //         final recordId = skill['_recordId']?.toString();
                          //         if (recordId == null) {
                          //           setState(() {
                          //             _specialSkillsData.removeAt(index);
                          //             if (_editingSpecialSkillIndex == index) _editingSpecialSkillIndex = null;
                          //           });
                          //           return;
                          //         }
                          //         final response = await _userService.deleteOtherInfo(widget.token, recordId);
                          //         if (response['success']) {
                          //           await _fetchOtherInfoData();
                          //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill deleted successfully'), backgroundColor: Colors.green));
                          //         } else {
                          //           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${response['error']}'), backgroundColor: Colors.red));
                          //         }
                          //       }
                          //     },
                          //     itemBuilder: (context) => [
                          //       const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.black87), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 14))])),
                          //       const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red))])),
                          //     ],
                          //   ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // ── Non-Academic Distinctions ─────────────────────
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
                    final bool isEditing =
                        _editingNonAcademicDistinctionIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          // Expanded(
                          //   child: isEditing
                          //       ? _buildEditableFieldInline(
                          //           '',
                          //           distinction['distinction'],
                          //           (value) => _nonAcademicDistinctionsData[index]['distinction'] = value,
                          //         )
                          //       : _buildInfoFieldInline('', distinction['distinction']),
                          // ),
                          // if (isEditing)
                          //   IconButton(
                          //     icon: const Icon(Icons.check, size: 18, color: Color(0xFF2C5F4F)),
                          //     onPressed: () async {
                          //       if (isEditing) { await _saveOtherInfo(); }
                          //       setState(() { _editingNonAcademicDistinctionIndex = null; });
                          //     },
                          //     padding: EdgeInsets.zero,
                          //     constraints: const BoxConstraints(),
                          //   )
                          // else
                          //   PopupMenuButton<String>(
                          //     icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black54),
                          //     padding: EdgeInsets.zero,
                          //     onSelected: (value) async {
                          //       if (value == 'edit') {
                          //         setState(() { _editingNonAcademicDistinctionIndex = index; });
                          //       } else if (value == 'delete') {
                          //         final recordId = distinction['_recordId']?.toString();
                          //         if (recordId == null) {
                          //           setState(() {
                          //             _nonAcademicDistinctionsData.removeAt(index);
                          //             if (_editingNonAcademicDistinctionIndex == index) _editingNonAcademicDistinctionIndex = null;
                          //           });
                          //           return;
                          //         }
                          //         final response = await _userService.deleteOtherInfo(widget.token, recordId);
                          //         if (response['success']) {
                          //           await _fetchOtherInfoData();
                          //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Distinction deleted successfully'), backgroundColor: Colors.green));
                          //         } else {
                          //           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${response['error']}'), backgroundColor: Colors.red));
                          //         }
                          //       }
                          //     },
                          //     itemBuilder: (context) => [
                          //       const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.black87), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 14))])),
                          //       const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red))])),
                          //     ],
                          //   ),
                          Expanded(
                            child: isEditing
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEditableFieldInline(
                                        '',
                                        distinction['distinction'],
                                        (value) =>
                                            _nonAcademicDistinctionsData[index]['distinction'] =
                                                value,
                                      ),
                                      const SizedBox(height: 8),
                                      // ✅ Save and Cancel buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(() {
                                              _editingNonAcademicDistinctionIndex =
                                                  null;
                                            }),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await _saveOtherInfo();
                                              setState(
                                                () =>
                                                    _editingNonAcademicDistinctionIndex =
                                                        null,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.save,
                                              size: 16,
                                            ),
                                            label: const Text('Save'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2C5F4F,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    distinction['distinction'],
                                  ),
                          ),
                          // ✅ Only show 3-dots when NOT editing
                          if (!isEditing)
                            PopupMenuButton<String>(
                              color: Colors.white,
                              position: PopupMenuPosition.under,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
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
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  setState(
                                    () => _editingNonAcademicDistinctionIndex =
                                        index,
                                  );
                                } else if (value == 'delete') {
                                  final recordId = distinction['_recordId']
                                      ?.toString();
                                  if (recordId == null) {
                                    setState(() {
                                      _nonAcademicDistinctionsData.removeAt(
                                        index,
                                      );
                                      if (_editingNonAcademicDistinctionIndex ==
                                          index) {
                                        _editingNonAcademicDistinctionIndex =
                                            null;
                                      }
                                    });
                                    return;
                                  }
                                  final response = await _userService
                                      .deleteOtherInfo(widget.token, recordId);
                                  if (response['success']) {
                                    await _fetchOtherInfoData();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Distinction deleted successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to delete: ${response['error']}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // ── Membership in Association / Organization ──────
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
                    final bool isEditing = _editingMembershipIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          // Expanded(
                          //   child: isEditing
                          //       ? _buildEditableFieldInline(
                          //           '',
                          //           membership['organization'],
                          //           (value) => _membershipData[index]['organization'] = value,
                          //         )
                          //       : _buildInfoFieldInline('', membership['organization']),
                          // ),
                          // if (isEditing)
                          //   IconButton(
                          //     icon: const Icon(Icons.check, size: 18, color: Color(0xFF2C5F4F)),
                          //     onPressed: () async {
                          //       if (isEditing) { await _saveOtherInfo(); }
                          //       setState(() { _editingMembershipIndex = null; });
                          //     },
                          //     padding: EdgeInsets.zero,
                          //     constraints: const BoxConstraints(),
                          //   )
                          // else
                          //   PopupMenuButton<String>(
                          //     icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black54),
                          //     padding: EdgeInsets.zero,
                          //     onSelected: (value) async {
                          //       if (value == 'edit') {
                          //         setState(() { _editingMembershipIndex = index; });
                          //       } else if (value == 'delete') {
                          //         final recordId = membership['_recordId']?.toString();
                          //         if (recordId == null) {
                          //           setState(() {
                          //             _membershipData.removeAt(index);
                          //             if (_editingMembershipIndex == index) _editingMembershipIndex = null;
                          //           });
                          //           return;
                          //         }
                          //         final response = await _userService.deleteOtherInfo(widget.token, recordId);
                          //         if (response['success']) {
                          //           await _fetchOtherInfoData();
                          //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membership deleted successfully'), backgroundColor: Colors.green));
                          //         } else {
                          //           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${response['error']}'), backgroundColor: Colors.red));
                          //         }
                          //       }
                          //     },
                          //     itemBuilder: (context) => [
                          //       const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.black87), SizedBox(width: 8), Text('Edit', style: TextStyle(fontSize: 14))])),
                          //       const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red))])),
                          //     ],
                          //   ),
                          Expanded(
                            child: isEditing
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEditableFieldInline(
                                        '',
                                        membership['organization'],
                                        (value) =>
                                            _membershipData[index]['organization'] =
                                                value,
                                      ),
                                      const SizedBox(height: 8),
                                      // ✅ Save and Cancel buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(() {
                                              _editingMembershipIndex = null;
                                            }),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await _saveOtherInfo();
                                              setState(
                                                () => _editingMembershipIndex =
                                                    null,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.save,
                                              size: 16,
                                            ),
                                            label: const Text('Save'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2C5F4F,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    membership['organization'],
                                  ),
                          ),
                          // ✅ Only show 3-dots when NOT editing
                          if (!isEditing)
                            PopupMenuButton<String>(
                              color: Colors.white,
                              position: PopupMenuPosition.under,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
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
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  setState(
                                    () => _editingMembershipIndex = index,
                                  );
                                } else if (value == 'delete') {
                                  final recordId = membership['_recordId']
                                      ?.toString();
                                  if (recordId == null) {
                                    setState(() {
                                      _membershipData.removeAt(index);
                                      if (_editingMembershipIndex == index) {
                                        _editingMembershipIndex = null;
                                      }
                                    });
                                    return;
                                  }
                                  final response = await _userService
                                      .deleteOtherInfo(widget.token, recordId);
                                  if (response['success']) {
                                    await _fetchOtherInfoData();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Membership deleted successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to delete: ${response['error']}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
                    );
                  })
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Add this new method for the dialog
    void _showAddOtherInfoDialog() {
    final TextEditingController skillController = TextEditingController();
    final TextEditingController distinctionController = TextEditingController();
    final TextEditingController membershipController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool hasSkillText = skillController.text.isNotEmpty;
            bool hasDistinctionText = distinctionController.text.isNotEmpty;
            bool hasMembershipText = membershipController.text.isNotEmpty;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025, // 2.5% each side = 95% width
                vertical: 24,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
                    const Text(
                      'Add Other Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C5F4F)),
                    ),
                    const SizedBox(height: 16),

                    // ── Scrollable content ──
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fill in only ONE field below:',
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),

                            // Special Skills Field
                            TextField(
                              controller: skillController,
                              enabled: !hasDistinctionText && !hasMembershipText,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Special Skill/Hobby',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: (!hasDistinctionText && !hasMembershipText) ? Colors.black : Colors.grey,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 1.5),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2.0),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (value) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 16),

                            // Non-Academic Distinction Field
                            TextField(
                              controller: distinctionController,
                              enabled: !hasSkillText && !hasMembershipText,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Non-Academic Distinction/Recognition',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: (!hasSkillText && !hasMembershipText) ? Colors.black : Colors.grey,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 1.5),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2.0),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (value) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 16),

                            // Membership Field
                            TextField(
                              controller: membershipController,
                              enabled: !hasSkillText && !hasDistinctionText,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Membership in Association/Organization',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: (!hasSkillText && !hasDistinctionText) ? Colors.black : Colors.grey,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 1.5),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2.0),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (value) => setDialogState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Action Buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C5F4F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (skillController.text.isNotEmpty) {
                              setState(() {
                                _specialSkillsData.add({'skill': skillController.text});
                                _editingSpecialSkillIndex = null;
                              });
                            } else if (distinctionController.text.isNotEmpty) {
                              setState(() {
                                _nonAcademicDistinctionsData.add({'distinction': distinctionController.text});
                                _editingNonAcademicDistinctionIndex = null;
                              });
                            } else if (membershipController.text.isNotEmpty) {
                              setState(() {
                                _membershipData.add({'organization': membershipController.text});
                                _editingMembershipIndex = null;
                              });
                            }

                            Navigator.of(context).pop();
                            _saveOtherInfo();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget _buildPersonReferenceCard() {

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
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableFieldInline(
    String label,
    String? value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value ?? '',
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF2C5F4F)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            isDense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildOtherInformationCard();
  }
}
