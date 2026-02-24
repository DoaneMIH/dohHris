import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/user_service.dart';

class FamilyBackgroundWidget extends StatefulWidget {
  final String token;
  final String employeeId;

  const FamilyBackgroundWidget({
    Key? key,
    required this.token,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<FamilyBackgroundWidget> createState() => _FamilyBackgroundWidgetState();
}

class _FamilyBackgroundWidgetState extends State<FamilyBackgroundWidget> {
  final _userService = UserService();

  List<Map<String, dynamic>> _familyData = [];
  bool _isFamilyBackgroundExpanded = true;
  bool _isFetchingFamily = false;
  String? _familyError;

  Map<String, dynamic> _spouseData = {};
  List<Map<String, dynamic>> _childrenData = [];
  Map<String, dynamic> _fatherData = {};
  Map<String, dynamic> _motherData = {};

  bool _isEditingSpouse = false;
  bool _isEditingFather = false;
  bool _isEditingMother = false;
  int? _editingChildIndex;

  @override
  void initState() {
    super.initState();
    _fetchFamilyDetails();
  }

  Future<void> _fetchFamilyDetails() async {
    print('\n👨‍👩‍👧‍👦 [UserDetailsPage] FETCHING FAMILY DETAILS');

    final employeeId = widget.employeeId;
    if (employeeId.isEmpty) {
      print('❌ [UserDetailsPage] No employee ID found');
      setState(() {
        _familyError = 'Employee ID not found';
        _isFetchingFamily = false;
      });
      return;
    }

    setState(() {
      _isFetchingFamily = true;
      _familyError = null;
    });

    try {
      print('📞 [UserDetailsPage] Calling API for employee: $employeeId');

      final response = await _userService.getFamilyDetails(
        widget.token,
        employeeId.toString(),
      );

      print('📦 [UserDetailsPage] Response received: ${response['success']}');

      if (response['success']) {
        final List<dynamic> familyList = response['data']['familyList'] ?? [];

        setState(() {
          _familyData = familyList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _isFetchingFamily = false;

          _parseSpouseData();
          _parseChildrenData();
          _parseFatherData();
          _parseMotherData();
        });

        print(
          '✅ [UserDetailsPage] Loaded ${_familyData.length} family members',
        );
      } else {
        setState(() {
          _familyError = response['error'] ?? 'Failed to fetch family details';
          _isFetchingFamily = false;
        });
        print('❌ [UserDetailsPage] Error: $_familyError');
      }
    } catch (e) {
      print('💥 [UserDetailsPage] Exception fetching family: $e');
      setState(() {
        _familyError = 'Error loading family details: $e';
        _isFetchingFamily = false;
      });
    }
  }

  void _parseSpouseData() {
    final spouse = _familyData.firstWhere(
      (member) => member['familyMemberType'] == 'SPOUSE',
      orElse: () => {},
    );

    if (spouse.isNotEmpty) {
      _spouseData = {
        'id': spouse['id'],
        'firstName': spouse['f_FirstName'] ?? '',
        'middleName': spouse['f_MiddleName'] ?? '',
        'lastName': spouse['f_LastName'] ?? '',
        'nameExtension': spouse['suffix'] ?? '',
        'occupation': spouse['occupation'] ?? '',
        'employer': spouse['employer'] ?? '',
        'businessAddress': spouse['employerAddress'] ?? '',
        'telephoneNo': spouse['telephone'] ?? '',
      };
      // print('✅ [UserDetailsPage] Spouse data parsed: ${_spouseData['firstName']} ${_spouseData['lastName']}');
    } else {
      _spouseData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'nameExtension': '',
        'occupation': '',
        'employer': '',
        'businessAddress': '',
        'telephoneNo': '',
      };
    }
  }

  void _parseChildrenData() {
    final children = _familyData
        .where((member) => member['familyMemberType'] == 'CHILD')
        .toList();

    _childrenData = children
        .map(
          (child) => {
            'id': child['id'],
            'name':
                '${child['f_FirstName'] ?? ''} ${child['f_MiddleName'] ?? ''} ${child['f_LastName'] ?? ''}'
                    .trim(),
            'birthday': child['f_Birthdate'] ?? '',
          },
        )
        .toList();
  }

  void _parseFatherData() {
    final father = _familyData.firstWhere(
      (member) => member['familyMemberType'] == 'FATHER',
      orElse: () => {},
    );

    if (father.isNotEmpty) {
      _fatherData = {
        'id': father['id'],
        'firstName': father['f_FirstName'] ?? '',
        'middleName': father['f_MiddleName'] ?? '',
        'lastName': father['f_LastName'] ?? '',
        'nameExtension': father['suffix'] ?? '',
      };
    } else {
      _fatherData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'nameExtension': '',
      };
    }
  }

  void _parseMotherData() {
    final mother = _familyData.firstWhere(
      (member) => member['familyMemberType'] == 'MOTHER',
      orElse: () => {},
    );

    if (mother.isNotEmpty) {
      _motherData = {
        'id': mother['id'],
        'firstName': mother['f_FirstName'] ?? '',
        'middleName': mother['f_MiddleName'] ?? '',
        'lastName': mother['f_LastName'] ?? '',
        'nameExtension': mother['suffix'] ?? '',
      };
    } else {
      _motherData = {
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'nameExtension': '',
      };
    }
  }
  Future<void> _saveSpouse() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = widget.employeeId;

      final familyData = {
        'f_FirstName': _spouseData['firstName'] ?? '',
        'f_MiddleName': _spouseData['middleName'] ?? '',
        'f_LastName': _spouseData['lastName'] ?? '',
        'suffix': _spouseData['nameExtension'] ?? '',
        'occupation': _spouseData['occupation'] ?? '',
        'employer': _spouseData['employer'] ?? '',
        'employerAddress': _spouseData['businessAddress'] ?? '',
        'telephone': _spouseData['telephoneNo'] ?? '',
        'familyMemberType': 'SPOUSE',
      };

      final response =
          _spouseData.containsKey('id') && _spouseData['id'] != null
          ? await _userService.updateFamilyMember(
              widget.token,
              _spouseData['id'].toString(),
              familyData,
            )
          : await _userService.addFamilyMember(
              widget.token,
              employeeId.toString(),
              familyData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchFamilyDetails();
        if (mounted) {
          setState(() => _isEditingSpouse = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Spouse saved successfully'),
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

  Future<void> _deleteSpouse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spouse'),
        content: const Text('Are you sure?'),
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
      if (_spouseData.containsKey('id') && _spouseData['id'] != null) {
        final response = await _userService.deleteFamilyMember(
          widget.token,
          _spouseData['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchFamilyDetails();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Spouse deleted'),
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
          _spouseData = {
            'firstName': '',
            'middleName': '',
            'lastName': '',
            'nameExtension': '',
            'occupation': '',
            'employer': '',
            'businessAddress': '',
            'telephoneNo': '',
          };
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

  Future<void> _saveChild(int index) async {
    // Validate child data
    final child = _childrenData[index];
    final name = child['name']?.toString().trim() ?? '';

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the child\'s name before saving'),
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

      // Better name parsing
      final nameParts = name
          .split(' ')
          .where((part) => part.isNotEmpty)
          .toList();

      String firstName = '';
      String middleName = '';
      String lastName = '';

      if (nameParts.length == 1) {
        firstName = nameParts[0];
      } else if (nameParts.length == 2) {
        firstName = nameParts[0];
        lastName = nameParts[1];
      } else if (nameParts.length >= 3) {
        firstName = nameParts[0];
        lastName = nameParts.last;
        middleName = nameParts.sublist(1, nameParts.length - 1).join(' ');
      }

      final familyData = {
        'f_FirstName': firstName,
        'f_MiddleName': middleName,
        'f_LastName': lastName,
        'f_Birthdate': child['birthday']?.toString().trim() ?? '',
        'familyMemberType': 'CHILD',
      };

      final response = child.containsKey('id') && child['id'] != null
          ? await _userService.updateFamilyMember(
              widget.token,
              child['id'].toString(),
              familyData,
            )
          : await _userService.addFamilyMember(
              widget.token,
              employeeId.toString(),
              familyData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchFamilyDetails();
        if (mounted) {
          setState(() => _editingChildIndex = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Child saved successfully'),
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

  Future<void> _deleteChild(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Child'),
        content: const Text('Are you sure?'),
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
      final child = _childrenData[index];

      if (child.containsKey('id') && child['id'] != null) {
        final response = await _userService.deleteFamilyMember(
          widget.token,
          child['id'].toString(),
        );
        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchFamilyDetails();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Child deleted'),
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
          _childrenData.removeAt(index);
          if (_editingChildIndex == index) _editingChildIndex = null;
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

  Future<void> _saveFather() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = widget.employeeId;

      final familyData = {
        'f_FirstName': _fatherData['firstName'] ?? '',
        'f_MiddleName': _fatherData['middleName'] ?? '',
        'f_LastName': _fatherData['lastName'] ?? '',
        'suffix': _fatherData['nameExtension'] ?? '',
        'familyMemberType': 'FATHER',
      };

      final response =
          _fatherData.containsKey('id') && _fatherData['id'] != null
          ? await _userService.updateFamilyMember(
              widget.token,
              _fatherData['id'].toString(),
              familyData,
            )
          : await _userService.addFamilyMember(
              widget.token,
              employeeId.toString(),
              familyData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchFamilyDetails();
        if (mounted) {
          setState(() => _isEditingFather = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Father saved successfully'),
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

  Future<void> _saveMother() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = widget.employeeId;

      final familyData = {
        'f_FirstName': _motherData['firstName'] ?? '',
        'f_MiddleName': _motherData['middleName'] ?? '',
        'f_LastName': _motherData['lastName'] ?? '',
        'suffix': _motherData['nameExtension'] ?? '',
        'familyMemberType': 'MOTHER',
      };

      final response =
          _motherData.containsKey('id') && _motherData['id'] != null
          ? await _userService.updateFamilyMember(
              widget.token,
              _motherData['id'].toString(),
              familyData,
            )
          : await _userService.addFamilyMember(
              widget.token,
              employeeId.toString(),
              familyData,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchFamilyDetails();
        if (mounted) {
          setState(() => _isEditingMother = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mother saved successfully'),
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

  //FETCH WORK EXPERIENCE DATA
  Widget _buildFamilyBackgroundCard() {
    if (!_isFetchingFamily && _familyData.isEmpty && _familyError == null) {
      _fetchFamilyDetails();
    }
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                    'FAMILY BACKGROUND',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_isFetchingFamily)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isFamilyBackgroundExpanded)
            _isFetchingFamily
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _familyError != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _familyError!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchFamilyDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSpouseSection(),
                        const SizedBox(height: 20),
                        _buildChildrenSection(),
                        const SizedBox(height: 20),
                        _buildFatherSection(),
                        const SizedBox(height: 20),
                        _buildMotherSection(),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }

  // Spouse Section
  Widget _buildSpouseSection() {
    // A spouse record exists only when the parsed data contains an 'id' from the API
    final bool hasSpouse =
        _spouseData.containsKey('id') && _spouseData['id'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SPOUSE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            // Show Add button only when there is no spouse yet
            if (!hasSpouse && !_isEditingSpouse)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _spouseData = {
                      'firstName': '',
                      'middleName': '',
                      'lastName': '',
                      'nameExtension': '',
                      'occupation': '',
                      'employer': '',
                      'businessAddress': '',
                      'telephoneNo': '',
                    };
                    _isEditingSpouse = true;
                  });
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Color(0xFF2C5F4F),
                ),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            // Show Edit + Delete buttons only when spouse exists (or currently adding)
            if (!_isEditingSpouse)
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
                onSelected: (value) {
                  if (value == 'edit') {
                    setState(() => _isEditingSpouse = true);
                  } else if (value == 'delete') {
                    _deleteSpouse();
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
                  if (hasSpouse) ...[
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
                ],
              ),
          ],
        ),

        // If no spouse and not editing, show a subtle empty-state hint
        if (!hasSpouse && !_isEditingSpouse)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No spouse information added yet.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Show fields only when spouse exists or when adding/editing
        if (hasSpouse || _isEditingSpouse) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingSpouse) ...[
                  _buildEditableFieldInline(
                    'First Name',
                    _spouseData['firstName'],
                    (value) {
                      _spouseData['firstName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Middle Name',
                    _spouseData['middleName'],
                    (value) {
                      _spouseData['middleName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Last Name',
                    _spouseData['lastName'],
                    (value) {
                      _spouseData['lastName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Name Extension',
                    _spouseData['nameExtension'],
                    (value) {
                      _spouseData['nameExtension'] = value;
                    },
                  ),
                ] else
                  _buildInfoFieldInline(
                    'Name',
                    [
                          _spouseData['firstName'],
                          _spouseData['middleName'],
                          _spouseData['lastName'],
                          _spouseData['nameExtension'],
                        ]
                        .where(
                          (v) => v != null && v.toString().trim().isNotEmpty,
                        )
                        .join(' '),
                  ),
                const SizedBox(height: 12),
                _isEditingSpouse
                    ? _buildEditableFieldInline(
                        'Occupation',
                        _spouseData['occupation'],
                        (value) {
                          _spouseData['occupation'] = value;
                        },
                      )
                    : _buildInfoFieldInline(
                        'Occupation',
                        _spouseData['occupation'],
                      ),
                const SizedBox(height: 12),
                _isEditingSpouse
                    ? _buildPhoneFieldInline(
                        'Telephone No.',
                        _spouseData['telephoneNo'],
                        (value) {
                          _spouseData['telephoneNo'] = value;
                        },
                      )
                    : _buildInfoFieldInline(
                        'Telephone No.',
                        _spouseData['telephoneNo'],
                      ),
                const SizedBox(height: 12),
                _isEditingSpouse
                    ? _buildEditableFieldInline(
                        'Employer / Business Name',
                        _spouseData['employer'],
                        (value) {
                          _spouseData['employer'] = value;
                        },
                      )
                    : _buildInfoFieldInline(
                        'Employer / Business Name',
                        _spouseData['employer'],
                      ),
                const SizedBox(height: 12),
                _isEditingSpouse
                    ? _buildEditableFieldInline(
                        'Business Address',
                        _spouseData['businessAddress'],
                        (value) {
                          _spouseData['businessAddress'] = value;
                        },
                      )
                    : _buildInfoFieldInline(
                        'Business Address',
                        _spouseData['businessAddress'],
                      ),
                const SizedBox(height: 25),
                if (_isEditingSpouse) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _isEditingSpouse = false;
                        }),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _saveSpouse(),
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
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }


Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CHILDREN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            // Single 3-dot menu at the top level for adding
            if (_editingChildIndex == null)
              PopupMenuButton<String>(
                color: Colors.white,
                        position: PopupMenuPosition.under,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.more_horiz, size: 20, color: Colors.black)),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'add') {
                    setState(() {
                      _childrenData.add({'name': '', 'birthday': ''});
                      _editingChildIndex = _childrenData.length - 1;
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle, size: 18, color: Color(0xFF2C5F4F)),
                        SizedBox(width: 8),
                        Text('Add Child'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        ..._childrenData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> child = entry.value;
          bool isEditing = _editingChildIndex == index;

          var hasChild = child.containsKey('id') && child['id'] != null;
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Child ${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    // Hide the 3-dot menu when this child is being edited
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
                        onSelected: (value) {
                          if (value == 'edit') {
                            setState(() => _editingChildIndex = index);
                          } else if (value == 'delete') {
                            _deleteChild(index);
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
                          if (hasChild)
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

                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isEditing
                          ? _buildEditableFieldInline(
                              'Name of Children',
                              child['name'],
                              (value) {
                                _childrenData[index]['name'] = value;
                              },
                            )
                          : _buildInfoFieldInline(
                              'Name of Children',
                              child['name'],
                            ),
                      const SizedBox(height: 8),
                      isEditing
                          ? _buildDateFieldInline(
                              'Birthday (YYYY-MM-DD)',
                              child['birthday'],
                              (value) {
                                _childrenData[index]['birthday'] = value;
                              },
                            )
                          : _buildInfoFieldInline(
                              'Birthday (YYYY-MM-DD)',
                              child['birthday'],
                            ),
                      const SizedBox(height: 25),
                      // Show Cancel and Save buttons when editing
                      if (isEditing) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(() {
                                _editingChildIndex = null; // FIXED: Cancel editing
                              }),
                              child: const Text(
                                'Cancel', 
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _saveChild(index),
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }


  Widget _buildFatherSection() {
    final bool hasFather =
        _fatherData.containsKey('id') && _fatherData['id'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'FATHER',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            // Show Add button only when there is no father record yet
            if (!hasFather && !_isEditingFather)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _fatherData = {
                      'firstName': '',
                      'middleName': '',
                      'lastName': '',
                      'nameExtension': '',
                    };
                    _isEditingFather = true;
                  });
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Color(0xFF2C5F4F),
                ),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            // Show 3-dot menu when father record exists or currently editing
            if (!_isEditingFather)
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
                onSelected: (value) {
                  if (value == 'edit') {
                    if (_isEditingFather) {
                      _saveFather();
                    } else {
                      setState(() => _isEditingFather = true);
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
                ],
              ),
          ],
        ),

        if (!hasFather && !_isEditingFather)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No father information added yet.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        if (hasFather || _isEditingFather)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    if (_isEditingFather) ...[
                      _buildEditableFieldInline(
                        'First Name',
                        _fatherData['firstName'],
                        (value) {
                          _fatherData['firstName'] = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildEditableFieldInline(
                        'Middle Name',
                        _fatherData['middleName'],
                        (value) {
                          _fatherData['middleName'] = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildEditableFieldInline(
                        'Last Name',
                        _fatherData['lastName'],
                        (value) {
                          _fatherData['lastName'] = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildEditableFieldInline(
                        'Name Extension',
                        _fatherData['nameExtension'],
                        (value) {
                          _fatherData['nameExtension'] = value;
                        },
                      ),
                    ] else
                      _buildInfoFieldInline(
                        'Name',
                        [
                              _fatherData['firstName'],
                              _fatherData['middleName'],
                              _fatherData['lastName'],
                              _fatherData['nameExtension'],
                            ]
                            .where(
                              (v) =>
                                  v != null && v.toString().trim().isNotEmpty,
                            )
                            .join(' '),
                      ),

                if (_isEditingFather) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _isEditingFather = false;
                        }),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _saveFather(),
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
                    
                  ),
                ],

                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Mother Section
  Widget _buildMotherSection() {
    // A mother record exists only when the parsed data contains an 'id' from the API
    final bool hasMother =
        _motherData.containsKey('id') && _motherData['id'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "MOTHER'S MAIDEN NAME",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            // Show Add button only when there is no mother record yet
            if (!hasMother && !_isEditingMother)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _motherData = {
                      'firstName': '',
                      'middleName': '',
                      'lastName': '',
                      'nameExtension': '',
                    };
                    _isEditingMother = true;
                  });
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Color(0xFF2C5F4F),
                ),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            // Show Edit button when mother record exists or currently adding
            if (!_isEditingMother)
          
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
                onSelected: (value) {
                  if (value == 'edit') {
                    if (_isEditingMother) {
                      _saveMother();
                    } else {
                      setState(() => _isEditingMother = true);
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
                ],
              ),
          ],
        ),

        // If no mother and not editing, show a subtle empty-state hint
        if (!hasMother && !_isEditingMother)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No mother information added yet.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Show fields only when mother record exists or when adding/editing
        if (hasMother || _isEditingMother)
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingMother) ...[
                  _buildEditableFieldInline(
                    'First Name',
                    _motherData['firstName'],
                    (value) {
                      _motherData['firstName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Middle Name',
                    _motherData['middleName'],
                    (value) {
                      _motherData['middleName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Last Name',
                    _motherData['lastName'],
                    (value) {
                      _motherData['lastName'] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildEditableFieldInline(
                    'Name Extension',
                    _motherData['nameExtension'],
                    (value) {
                      _motherData['nameExtension'] = value;
                    },
                  ),
                ] else
                  _buildInfoFieldInline(
                    'Name',
                    [
                          _motherData['firstName'],
                          _motherData['middleName'],
                          _motherData['lastName'],
                          _motherData['nameExtension'],
                        ]
                        .where(
                          (v) => v != null && v.toString().trim().isNotEmpty,
                        )
                        .join(' '),
                  ),
               if (_isEditingMother) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _isEditingMother = false;
                        }),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _saveMother(),
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
                  ),
                ],
              ],
            ),
          ),
      ],
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
                final parts = value.split('/');
                if (parts.length == 3) {
                  initialDate = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
                }
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
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF2C5F4F)),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
    return _buildFamilyBackgroundCard();
  }
}