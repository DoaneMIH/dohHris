import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/pages/dtr_page.dart';
import 'package:mobile_application/services/authenticated_photo.dart';
import '../services/user_service.dart';
import 'login_page.dart';

class UserDetailsPageContent extends StatefulWidget {
  final String token;
  final String baseUrl;

  const UserDetailsPageContent({
    Key? key,
    required this.token,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<UserDetailsPageContent> createState() => _UserDetailsPageContentState();
}

class _UserDetailsPageContentState extends State<UserDetailsPageContent> {
  final _userService = UserService();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;
  bool _isFamilyBackgroundExpanded = true;

  // Family data fetching
  List<Map<String, dynamic>> _familyData = [];
  bool _isFetchingFamily = false;
  String? _familyError;

  // Family background data structures
  Map<String, dynamic> _spouseData = {};
  List<Map<String, dynamic>> _childrenData = [];
  Map<String, dynamic> _fatherData = {};
  Map<String, dynamic> _motherData = {};

  // Edit mode flags
  bool _isEditingPersonalInfo = false;
  bool _isEditingSpouse = false;
  bool _isEditingFather = false;
  bool _isEditingMother = false;
  int? _editingChildIndex;

  // Personal information data for editing
  Map<String, dynamic> _personalInfoData = {};

  //Educationl Information data for editing
  List<Map<String, dynamic>> _educationListData = [];


  // Educational background data
  bool _isEducationalBackgroundExpanded = true;
  List<Map<String, dynamic>> _educationData = [];
  int? _editingEducationIndex;

  // Civil service eligibility data
  bool _isCivilServiceExpanded = true;
  List<Map<String, dynamic>> _civilServiceData = [];
  int? _editingCivilServiceIndex;

  // Work experience data
  bool _isWorkExperienceExpanded = true;
  List<Map<String, dynamic>> _workExperienceData = [];
  int? _editingWorkExperienceIndex;

  // Voluntary work data
  bool _isVoluntaryWorkExpanded = true;
  List<Map<String, dynamic>> _voluntaryWorkData = [];
  int? _editingVoluntaryWorkIndex;

  // Learning and development data
  bool _isLearningDevelopmentExpanded = true;
  List<Map<String, dynamic>> _learningDevelopmentData = [];
  int? _editingLearningDevelopmentIndex;

  bool _isOtherInformationExpanded = true;
  List<Map<String, dynamic>> _specialSkillsData = [];
  int? _editingSpecialSkillIndex;

  List<Map<String, dynamic>> _nonAcademicDistinctionsData = [];
  int? _editingNonAcademicDistinctionIndex;

  List<Map<String, dynamic>> _membershipData = [];
  int? _editingMembershipIndex;

  String _otherInformationInquiry = '';
  bool _isEditingOtherInquiry = false;

  // References data
  List<Map<String, dynamic>> _referencesData = [];
  int? _editingReferenceIndex;

  // Government ID data
  bool _isEditingGovernmentID = false;
  Map<String, dynamic> _governmentIDData = {};

  // Selected menu state
  String _selectedMenu = 'Personal Information';

  // Drawer menu expansion states
  bool _isInformationExpanded = false;
  bool _isServicesExpanded = false;

  @override
  void initState() {
    super.initState();
    print('\n📄 [UserDetailsPage] Page initialized');
    print('🎫 [UserDetailsPage] Token: ${widget.token.substring(0, 20)}...');
    print('🌐 [UserDetailsPage] Base URL: ${widget.baseUrl}');
    _fetchUserDetails();
    // _initializeFamilyData();
    // _fetchFamilyDetails();
  }

  Future<void> _fetchUserDetails() async {
    print('\n🔄🔄🔄 [UserDetailsPage] FETCHING USER DETAILS 🔄🔄🔄');
    print('⏳ [UserDetailsPage] Fetching user profile with token...');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _userService.getUserDetails(widget.token);

    print('📦 [UserDetailsPage] Result received from UserService');
    print('📦 [UserDetailsPage] Success: ${result['success']}');
    print('📦 [UserDetailsPage] Full result data: $result');

    setState(() {
      if (result['success']) {
        _userDetails = result['data'];
        print('✅ [UserDetailsPage] User profile loaded successfully');
        print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
        print(
          '📅 [UserDetailsPage] Employee birthdate: ${_userDetails?['employee']?['birthdate']}',
        );
        print(
          '🏠 [UserDetailsPage] Employee birthplace: ${_userDetails?['employee']?['birthplace']}',
        );
        print(
          '💍 [UserDetailsPage] Employee civilStatus: ${_userDetails?['employee']?['civilStatus']}',
        );
        print(
          '🌍 [UserDetailsPage] Employee citizenship: ${_userDetails?['employee']?['citizenship']}',
        );
        print(
          '📷 [UserDetailsPage] Profile photo: ${_userDetails?['employee']?['photoUrl'] ?? 'No photo'}',
        );

        //     // ⭐ ADD THESE 3 LINES:
        // if (_userDetails?['employee'] != null) {
        //   _personalInfoData = Map<String, dynamic>.from(_userDetails!['employee']);
        // }

        if (_userDetails?['employee'] != null) {
          _personalInfoData = Map<String, dynamic>.from(
            _userDetails!['employee'],
          );

          // ⭐ Remove photo-related fields - they should NEVER be in personalInfoData
          final photoFields = [
            'photo',
            'photoUrl',
            'profilePhoto',
            'image',
            'profileImage',
            'photo_url',
          ];
          photoFields.forEach((field) => _personalInfoData.remove(field));

          // ⭐ Remove protected fields - they should NEVER be modified via personal info updates
          final protectedFields = ['employmentStatus', 'employment_status'];
          protectedFields.forEach((field) => _personalInfoData.remove(field));

          print(
            '✅ [UserDetailsPage] Personal info initialized (${_personalInfoData.length} fields, photo and protected fields excluded)',
          );
        }

        print('✅ [UserDetailsPage] User profile loaded successfully');
        _fetchFamilyDetails(); // Fetch family details after loading user profile
        // Fetch education data
        _fetchEducationData();
      } else {
        _error = result['error'];
        print('❌ [UserDetailsPage] Error loading user profile: $_error');
      }
      _isLoading = false;
    });

    print('🏁 [UserDetailsPage] Fetch user profile completed');
    print('🔄🔄🔄 END FETCHING USER DETAILS 🔄🔄🔄\n');
  }

  Future<void> _fetchFamilyDetails() async {
    print('\n👨‍👩‍👧‍👦 [UserDetailsPage] FETCHING FAMILY DETAILS');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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


  
  Future<void> _fetchEducationData() async {
  print('\n📚 [UserDetailsPage] FETCHING EDUCATION DATA');
  
  final employeeId = _userDetails?['employee']?['id'];
  if (employeeId == null) {
    print('❌ No employee ID, skipping education fetch');
    return;
  }

  try {
    final response = await _userService.getEducationDetails(
      widget.token, 
      employeeId.toString(),
    );
    
    if (response['success']) {
      final List<dynamic> educationList = response['data']['educationList'] ?? [];
      
      setState(() {
        _educationListData = educationList.map((item) => Map<String, dynamic>.from(item)).toList();
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
        case 'E': return 'ELEMENTARY';
        case 'S': return 'SECONDARY';
        case 'V': return 'VOCATIONAL/TRADE COURSE';
        case 'C': return 'COLLEGE';
        case 'G': return 'GRADUATE STUDIES';
        default: return code ?? '';
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
  
  print('📚 Parsed ${_educationData.length} education records');
}

Future<void> _saveEducation(int index) async {
  final education = _educationData[index];
  
  // Validate school name
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
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) throw Exception('Employee ID not found');

    // Convert level name to code
    String getLevelCode(String? levelName) {
      switch (levelName?.toUpperCase()) {
        case 'ELEMENTARY': return 'E';
        case 'SECONDARY': return 'S';
        case 'VOCATIONAL/TRADE COURSE': return 'V';
        case 'COLLEGE': return 'C';
        case 'GRADUATE STUDIES': return 'G';
        default: return 'E';
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
        ? await _userService.updateEducation(widget.token, education['id'].toString(), educationData)
        : await _userService.addEducation(widget.token, employeeId.toString(), educationData);

    if (mounted) Navigator.pop(context);

    if (response['success']) {
      await _fetchEducationData();
      if (mounted) {
        setState(() => _editingEducationIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education saved successfully'), backgroundColor: Colors.green),
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

Future<void> _deleteEducation(int index) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Education'),
      content: const Text('Are you sure you want to delete this education record?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
    final education = _educationData[index];
    
    if (education.containsKey('id') && education['id'] != null) {
      final response = await _userService.deleteEducation(widget.token, education['id'].toString());
      if (mounted) Navigator.pop(context);
      
      if (response['success']) {
        await _fetchEducationData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Education deleted'), backgroundColor: Colors.green),
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
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }
}




  Future<void> _savePersonalInformation() async {
    print('\n========================================');
    print('💾 [UserDetailsPage] SAVE PERSONAL INFORMATION');
    print('========================================');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Get employee ID
      final employeeId = _userDetails?['employee']?['id'];
      print('📋 [UserDetailsPage] Employee ID: $employeeId');

      if (employeeId == null) {
        throw Exception('Employee ID not found in user details');
      }

      print('📝 [UserDetailsPage] Personal Information Data to Save:');
      _personalInfoData.forEach((key, value) {
        print('   - $key: $value');
      });
      print('----------------------------------------');

      print(
        '⏳ [UserDetailsPage] Calling UserService.updatePersonalInformation...',
      );

      // Call the user service to update personal information
      final response = await _userService.updatePersonalInformation(
        widget.token,
        employeeId.toString(),
        _personalInfoData,
      );

      print('📥 [UserDetailsPage] Response received from UserService');
      print('📥 [UserDetailsPage] Success: ${response['success']}');
      if (response['error'] != null) {
        print('📥 [UserDetailsPage] Error: ${response['error']}');
      }
      print('----------------------------------------');

      // Close loading dialog
      if (mounted) {
        print('🔄 [UserDetailsPage] Closing loading dialog...');
        Navigator.pop(context);
      }

      if (response['success']) {
        print(
          '✅ [UserDetailsPage] Save successful! Refreshing user details...',
        );

        // Refresh user details
        await _fetchUserDetails();

        print('✅ [UserDetailsPage] User details refreshed');

        // Exit edit mode
        if (mounted) {
          setState(() {
            _isEditingPersonalInfo = false;
          });
          print('✅ [UserDetailsPage] Exited edit mode');
        }
        if (mounted) {
          print('✅ [UserDetailsPage] Showing success SnackBar');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal information updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        print('✅ [UserDetailsPage] Personal information saved successfully');
        print('========================================\n');
      } else {
        print('❌ [UserDetailsPage] Save failed');
        throw Exception(
          response['error'] ?? 'Failed to update personal information',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [UserDetailsPage] ERROR SAVING PERSONAL INFORMATION');
      print('💥 [UserDetailsPage] Error: $e');
      print('💥 [UserDetailsPage] Error Type: ${e.runtimeType}');
      print('💥 [UserDetailsPage] Stack Trace:');
      print(stackTrace);
      print('========================================\n');

      // Close loading dialog if still open
      if (mounted) {
        print('🔄 [UserDetailsPage] Closing loading dialog (error state)...');
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        print('❌ [UserDetailsPage] Showing error SnackBar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveSpouse() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

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
    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) throw Exception('Employee ID not found');

    // Better name parsing
    final nameParts = name.split(' ').where((part) => part.isNotEmpty).toList();
    
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
        ? await _userService.updateFamilyMember(widget.token, child['id'].toString(), familyData)
        : await _userService.addFamilyMember(widget.token, employeeId.toString(), familyData);

    if (mounted) Navigator.pop(context);

    if (response['success']) {
      await _fetchFamilyDetails();
      if (mounted) {
        setState(() => _editingChildIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child saved successfully'), backgroundColor: Colors.green),
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
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

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
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

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

  void _logout() {
    print('🚪 [UserDetailsPage] Logout button pressed');
    print('🔄 [UserDetailsPage] Navigating back to LoginPage...');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 7),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/bp_logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DOH WV CHD',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                    ),
                  ),
                  Text(
                    'HRIS',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xFF00674F),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
        drawer: Drawer(
          width: 300,
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 80,
                child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: Color(0xFF00674F)),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Information Section with Dropdown
              ExpansionTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00674F),
                ),
                title: const Text(
                  'Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00674F),
                  ),
                ),
                iconColor: const Color.fromARGB(255, 0, 0, 0),
                collapsedIconColor: const Color.fromARGB(255, 0, 0, 0),
                initiallyExpanded: _isInformationExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isInformationExpanded = expanded;
                  });
                },
                children: [
                  _buildDrawerItem(
                    'Personal Information',
                    Icons.person,
                    _selectedMenu == 'Personal Information',
                  ),
                  _buildDrawerItem(
                    'Family Background',
                    Icons.family_restroom,
                    _selectedMenu == 'Family Background',
                  ),
                  _buildDrawerItem(
                    'Educational Background',
                    Icons.school,
                    _selectedMenu == 'Educational Background',
                  ),
                  _buildDrawerItem(
                    'Civil Service Eligibility',
                    Icons.verified,
                    _selectedMenu == 'Civil Service Eligibility',
                  ),
                  _buildDrawerItem(
                    'Work Experience',
                    Icons.work,
                    _selectedMenu == 'Work Experience',
                  ),
                  _buildDrawerItem(
                    'Voluntary Work',
                    Icons.volunteer_activism,
                    _selectedMenu == 'Voluntary Work',
                  ),
                  _buildDrawerItem(
                    'Learning and Development',
                    Icons.psychology,
                    _selectedMenu == 'Learning and Development',
                  ),
                  _buildDrawerItem(
                    'Other Information',
                    Icons.info,
                    _selectedMenu == 'Other Information',
                  ),
                ],
              ),
              // Services Section with Dropdown
              ExpansionTile(
                leading: const Icon(
                  Icons.room_service,
                  color: Color(0xFF00674F),
                ),
                title: const Text(
                  'Services',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00674F),
                  ),
                ),
                iconColor: const Color.fromARGB(255, 0, 0, 0),
                collapsedIconColor: const Color.fromARGB(255, 0, 0, 0),
                initiallyExpanded: _isServicesExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isServicesExpanded = expanded;
                  });
                },
                children: [
                  _buildDrawerItem(
                    'Daily Time Record',
                    Icons.access_time,
                    _selectedMenu == 'Daily Time Record',
                  ),
                ],
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUserDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // SCROLLABLE HEADER - Profile Section (Scrolls with content)
                    _buildProfileHeader(),

                    // SWITCHABLE CONTENT - Based on selected menu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: Column(
                        children: [
                          _buildSelectedContent(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // FIXED PROFILE HEADER - Always visible at the top
  Widget _buildProfileHeader() {
    return Container(
      height: 290,
      padding: const EdgeInsets.all(16.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AuthenticatedProfilePhoto(
            photoUrl: _userDetails?['employee']?['photoUrl'],
            // photoUrl: _userDetails?['photoUrl'],  // Remove ['employee']
            baseUrl: widget.baseUrl,
            userName: (_userDetails?['name'] ?? 'User').toString(),
            radius: 70,
            token: widget.token,
            employeeId: _userDetails?['employee']?['id']
                ?.toString(), // Add employeeId
            onPhotoUpdated:
                _fetchUserDetails, // Refresh user details after photo update
          ),
          const SizedBox(width: 25, height: 10),
          // Name and Details
          Flexible(
            child: Column(
              children: [
                // First Name Middle initial Last Name
                Text(
                  "${_userDetails?['employee']?['firstName'] ?? 'N/A'} "
                  "${_userDetails?['employee']?['middleName'] != null && (_userDetails?['employee']?['middleName'] as String).isNotEmpty ? (_userDetails?['employee']?['middleName'] as String)[0] + '. ' : ''}"
                  "${_userDetails?['employee']?['lastName'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Employee ID:",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _userDetails?['employee']?['employeeId']?.toString() ??
                          'N/A',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.badge, size: 18, weight: 200),
                    const SizedBox(width: 6),
                    Text(
                      _userDetails?['employee']?['designation']?['desigCode'] ??
                          'N/A',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Department
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment, size: 18, weight: 200),
                    const SizedBox(width: 6),
                    Text('ICTU', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SWITCHABLE CONTENT - Returns the appropriate widget based on selected menu
  Widget _buildSelectedContent() {
    switch (_selectedMenu) {
      case 'Personal Information':
        return _buildPersonalInformationCard();
      case 'Family Background':
        return _buildFamilyBackgroundCard();
      case 'Educational Background':
        return _buildEducationalBackgroundCard();
      case 'Civil Service Eligibility':
        return _buildCivilServiceCard();
      case 'Work Experience':
        return _buildWorkExperienceCard();
      case 'Voluntary Work':
        return _buildVoluntaryWorkCard();
      case 'Learning and Development':
        return _buildLearningDevelopmentCard();
      case 'Other Information':
        return _buildOtherInformationCard();
      case 'Daily Time Record':
        return _buildDailyTimeRecordCard();
      default:
        return _buildPersonalInformationCard();
    }
  }

  Widget _buildPersonalInformationCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(1),
            width: double.infinity,

            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
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
                        'PERSONAL INFORMATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isEditingPersonalInfo ? Icons.check : Icons.edit,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              if (_isEditingPersonalInfo) {
                                // Save changes (this will automatically exit edit mode)
                                await _savePersonalInformation();
                              } else {
                                if (_userDetails?['employee'] != null) {
                                  final employee = _userDetails!['employee'];

                                  _personalInfoData = {
                                    // Name fields
                                    'lastName': employee['lastName'] ?? '',
                                    'firstName': employee['firstName'] ?? '',
                                    'middleName': employee['middleName'] ?? '',
                                    'suffix': employee['suffix'] ?? '',
                                    'photoUrl': employee['photoUrl'] ?? '',

                                    // Personal info
                                    'sex': employee['sex'] ?? '',
                                    'civilStatus':
                                        employee['civilStatus'] ?? '',
                                    'citizenship':
                                        employee['citizenship'] ?? '',
                                    'birthdate': employee['birthdate'] ?? '',
                                    'birthplace': employee['birthplace'] ?? '',
                                    'employeeId': employee['employeeId'] ?? '',

                                    // Physical attributes
                                    'height': employee['height'] ?? 0,
                                    'weight': employee['weight'] ?? 0,
                                    'bloodType': employee['bloodType'] ?? '',

                                    // Address fields (permanent)
                                    'houseNo': employee['houseNo'] ?? '',
                                    'street': employee['street'] ?? '',
                                    'village': employee['village'] ?? '',
                                    'barangay': employee['barangay'] ?? '',
                                    'municipality':
                                        employee['municipality'] ?? '',
                                    'province': employee['province'] ?? '',
                                    'zipCode': employee['zipCode'] ?? '',

                                    // Address fields (residential)
                                    'resHouseNo': employee['resHouseNo'] ?? '',
                                    'resStreet': employee['resStreet'] ?? '',
                                    'resVillage': employee['resVillage'] ?? '',
                                    'resBarangay':
                                        employee['resBarangay'] ?? '',
                                    'resMunicipality':
                                        employee['resMunicipality'] ?? '',
                                    'resProvince':
                                        employee['resProvince'] ?? '',
                                    'resZipCode': employee['resZipCode'] ?? '',

                                    // Contact info
                                    'telephoneNo':
                                        employee['telephoneNo'] ?? '',
                                    'mobileNo': employee['mobileNo'] ?? '',
                                    'email': employee['email'] ?? '',

                                    // Government IDs (only if you want them editable in personal info)
                                    'tin': employee['tin'] ?? '',
                                    'phic': employee['phic'] ?? '',
                                    'sss': employee['sss'] ?? '',
                                    'pagibig': employee['pagibig'] ?? '',
                                    'gsis': employee['gsis'] ?? '',
                                    'umid': employee['umid'] ?? '',
                                    'philsys': employee['philsys'] ?? '',

                                    'employmentStatus':
                                        employee['employmentStatus'] ?? 'true',
                                  };

                                  // Note: employmentStatus and photo fields are intentionally NOT included

                                  print(
                                    '✅ [UserDetailsPage] Personal info initialized with ${_personalInfoData.length} editable fields',
                                  );
                                }
                                setState(() {
                                  _isEditingPersonalInfo = true;
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content Section
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 12,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isEditingPersonalInfo
                            ? _buildDateFieldInline(
                                'Date of Birth',
                                _personalInfoData['birthdate'],
                                (value) => setState(
                                  () => _personalInfoData['birthdate'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Date of Birth',
                                _userDetails?['employee']?['birthdate'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Place of Birth',
                                _personalInfoData['birthplace'],
                                (value) => setState(
                                  () => _personalInfoData['birthplace'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Place of Birth',
                                _userDetails?['employee']?['birthplace'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Civil Status',
                                _personalInfoData['civilStatus'],
                                (value) => setState(
                                  () =>
                                      _personalInfoData['civilStatus'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Civil Status',
                                _userDetails?['employee']?['civilStatus'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Citizenship',
                                _personalInfoData['citizenship'],
                                (value) => setState(
                                  () =>
                                      _personalInfoData['citizenship'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Citizenship',
                                _userDetails?['employee']?['citizenship'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Sex at Birth',
                                _personalInfoData['sex'],
                                (value) => setState(
                                  () => _personalInfoData['sex'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Sex at Birth',
                                _userDetails?['employee']?['sex'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Blood Type',
                                _personalInfoData['bloodType'],
                                (value) => setState(
                                  () => _personalInfoData['bloodType'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Blood Type',
                                _userDetails?['employee']?['bloodType'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Height (cm)',
                                _personalInfoData['height']?.toString() ?? '',
                                (value) => setState(
                                  () => _personalInfoData['height'] =
                                      int.tryParse(value) ?? 0,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Height (cm)',
                                _userDetails?['employee']?['height'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildEditableFieldInline(
                                'Weight (kg)',
                                _personalInfoData['weight']?.toString() ?? '',
                                (value) => setState(
                                  () => _personalInfoData['weight'] =
                                      int.tryParse(value) ?? 0,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Weight (kg)',
                                _userDetails?['employee']?['weight'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Residential Address',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildEditableFieldInline(
                                    'Barangay',
                                    _personalInfoData['barangay'],
                                    (value) => setState(
                                      () =>
                                          _personalInfoData['barangay'] = value,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEditableFieldInline(
                                    'Municipality',
                                    _personalInfoData['municipality'],
                                    (value) => setState(
                                      () => _personalInfoData['municipality'] =
                                          value,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEditableFieldInline(
                                    'Province',
                                    _personalInfoData['province'],
                                    (value) => setState(
                                      () =>
                                          _personalInfoData['province'] = value,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEditableFieldInline(
                                    'Zip Code',
                                    _personalInfoData['zipCode'],
                                    (value) => setState(
                                      () =>
                                          _personalInfoData['zipCode'] = value,
                                    ),
                                  ),
                                ],
                              )
                            : _buildInfoFieldInline(
                                'Residential Address',
                                "${_userDetails?['employee']?['barangay'] ?? ''}, "
                                    "${_userDetails?['employee']?['municipality'] ?? ''}, "
                                    "${_userDetails?['employee']?['province'] ?? ''}, "
                                    "${_userDetails?['employee']?['zipCode'] ?? ''}",
                              ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'Permanent Address',
                          "${_userDetails?['employee']?['barangay'] ?? ''}, "
                              "${_userDetails?['employee']?['municipality'] ?? ''}, "
                              "${_userDetails?['employee']?['province'] ?? ''}, "
                              "${_userDetails?['employee']?['zipCode'] ?? ''}",
                        ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildPhoneFieldInline(
                                'Telephone No.',
                                _personalInfoData['telephoneNo'],
                                (value) => setState(
                                  () =>
                                      _personalInfoData['telephoneNo'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Telephone No.',
                                _userDetails?['employee']?['telephoneNo'],
                              ),
                        const SizedBox(height: 20),
                        _isEditingPersonalInfo
                            ? _buildPhoneFieldInline(
                                'Mobile No.',
                                _personalInfoData['mobileNo'],
                                (value) => setState(
                                  () => _personalInfoData['mobileNo'] = value,
                                ),
                              )
                            : _buildInfoFieldInline(
                                'Mobile No.',
                                _userDetails?['employee']?['mobileNo'],
                              ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'Email Address',
                          _userDetails?['email'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'Agency Employee No.',
                          _userDetails?['employee']?['employeeId'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'UMID ID No.',
                          _userDetails?['employee']?['umid'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'Pag-ibig No.',
                          _userDetails?['employee']?['pagibig'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'PhilHealth No.',
                          _userDetails?['employee']?['phic'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'PhilSys No. (PSN)',
                          _userDetails?['employee']?['philsys'],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoFieldInline(
                          'TIN No.',
                          _userDetails?['employee']?['tin'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Family Background Card Widget
  Widget _buildFamilyBackgroundCard() {
    if (!_isFetchingFamily && _familyData.isEmpty && _familyError == null) {
      _fetchFamilyDetails();
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFamilyBackgroundExpanded = !_isFamilyBackgroundExpanded;
              });
            },
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteSpouse,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isEditingSpouse ? Icons.check : Icons.edit,
                    size: 20,
                    color: Color(0xFF2C5F4F),
                  ),
                  onPressed: () {
                    // setState(() {
                    //   _isEditingSpouse = !_isEditingSpouse;
                    // });

                    if (_isEditingSpouse) {
                      _saveSpouse();
                    } else {
                      setState(() => _isEditingSpouse = true);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Single container with all fields in grid layout
        Container(
          padding: EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditingSpouse
                  ? _buildEditableFieldInline(
                      'First Name',
                      _spouseData['firstName'],
                      (value) {
                        _spouseData['firstName'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'First Name',
                      _spouseData['firstName'],
                    ),
              const SizedBox(height: 12),
              _isEditingSpouse
                  ? _buildEditableFieldInline(
                      'Middle Name',
                      _spouseData['middleName'],
                      (value) {
                        _spouseData['middleName'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'Middle Name',
                      _spouseData['middleName'],
                    ),
              const SizedBox(height: 12),
              _isEditingSpouse
                  ? _buildEditableFieldInline(
                      'Last Name',
                      _spouseData['lastName'],
                      (value) {
                        _spouseData['lastName'] = value;
                      },
                    )
                  : _buildInfoFieldInline('Last Name', _spouseData['lastName']),
              const SizedBox(height: 12),
              _isEditingSpouse
                  ? _buildEditableFieldInline(
                      'Name Extension',
                      _spouseData['nameExtension'],
                      (value) {
                        _spouseData['nameExtension'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'Name Extension',
                      _spouseData['nameExtension'],
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
            ],
          ),
        ),
      ],
    );
  }

  // Children Section
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
            IconButton(
              icon: const Icon(Icons.add, size: 20, color: Color(0xFF2C5F4F)),
              onPressed: () {
                setState(() {
                  _childrenData.add({'name': '', 'birthday': ''});
                  _editingChildIndex = _childrenData.length - 1;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),

        ..._childrenData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> child = entry.value;
          bool isEditing = _editingChildIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white),
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isEditing ? Icons.check : Icons.edit,
                            size: 18,
                            color: Color(0xFF2C5F4F),
                          ),
                          onPressed: () {
                            if (isEditing) {
                              _saveChild(index);
                            } else {
                              setState(() => _editingChildIndex = index);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteChild(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  // spacing around each child box
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 6,
                  ),
                  // inner spacing of the white box
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
                              'Birthday (MM/DD/YYYY)',
                              child['birthday'],
                              (value) {
                                _childrenData[index]['birthday'] = value;
                              },
                            )
                          : _buildInfoFieldInline(
                              'Birthday (MM/DD/YYYY)',
                              child['birthday'],
                            ),
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

  // Father Section
  Widget _buildFatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

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
            IconButton(
              icon: Icon(
                _isEditingFather ? Icons.check : Icons.edit,
                size: 20,
                color: const Color(0xFF2C5F4F),
              ),
              onPressed: () {
                if (_isEditingFather) {
                  _saveFather();
                } else {
                  setState(() => _isEditingFather = true);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Single container with all fields in grid layout
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditingFather
                      ? _buildEditableFieldInline(
                          'First Name',
                          _fatherData['firstName'],
                          (value) {
                            _fatherData['firstName'] = value;
                          },
                        )
                      : _buildInfoFieldInline(
                          'First Name',
                          _fatherData['firstName'],
                        ),
                  const SizedBox(height: 12),
                  _isEditingFather
                      ? _buildEditableFieldInline(
                          'Middle Name',
                          _fatherData['middleName'],
                          (value) {
                            _fatherData['middleName'] = value;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Middle Name',
                          _fatherData['middleName'],
                        ),
                  const SizedBox(height: 12),
                  _isEditingFather
                      ? _buildEditableFieldInline(
                          'Last Name',
                          _fatherData['lastName'],
                          (value) {
                            _fatherData['lastName'] = value;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Last Name',
                          _fatherData['lastName'],
                        ),
                  const SizedBox(height: 12),
                  _isEditingFather
                      ? _buildEditableFieldInline(
                          'Name Extension',
                          _fatherData['nameExtension'],
                          (value) {
                            _fatherData['nameExtension'] = value;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Name Extension',
                          _fatherData['nameExtension'],
                        ),
                  const SizedBox(height: 10),
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
            IconButton(
              icon: Icon(
                _isEditingMother ? Icons.check : Icons.edit,
                size: 20,
                color: Color(0xFF2C5F4F),
              ),
              onPressed: () {
                if (_isEditingMother) {
                  _saveMother();
                } else {
                  setState(() => _isEditingMother = true);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditingMother
                  ? _buildEditableFieldInline(
                      'First Name',
                      _motherData['firstName'],
                      (value) {
                        _motherData['firstName'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'First Name',
                      _motherData['firstName'],
                    ),
              const SizedBox(height: 12),
              _isEditingMother
                  ? _buildEditableFieldInline(
                      'Middle Name',
                      _motherData['middleName'],
                      (value) {
                        _motherData['middleName'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'Middle Name',
                      _motherData['middleName'],
                    ),
              const SizedBox(height: 12),
              _isEditingMother
                  ? _buildEditableFieldInline(
                      'Last Name',
                      _motherData['lastName'],
                      (value) {
                        _motherData['lastName'] = value;
                      },
                    )
                  : _buildInfoFieldInline('Last Name', _motherData['lastName']),
              const SizedBox(height: 12),
              _isEditingMother
                  ? _buildEditableFieldInline(
                      'Name Extension',
                      _motherData['nameExtension'],
                      (value) {
                        _motherData['nameExtension'] = value;
                      },
                    )
                  : _buildInfoFieldInline(
                      'Name Extension',
                      _motherData['nameExtension'],
                    ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildEducationalBackgroundCard() {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 12,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        InkWell(
          onTap: () {
            setState(() {
              _isEducationalBackgroundExpanded = !_isEducationalBackgroundExpanded;
            });
          },
          child: Container(
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
                const Text(
                  'EDUCATIONAL BACKGROUND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _educationData.add({
                        'level': 'ELEMENTARY',
                        'schoolName': '',
                        'degreeCourse': '',
                        'attendedFrom': '',
                        'attendedTo': '',
                        'highestLevel': '',
                        'yearGraduated': '',
                        'academicHonors': '',
                        'onGoing': false,
                      });
                      _editingEducationIndex = _educationData.length - 1;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        // Content
        if (_isEducationalBackgroundExpanded)
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _educationData.isEmpty
                  ? [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No education records found.\nClick + to add education.',
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
                        bool isEditing = _editingEducationIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isEditing ? Color(0xFF2C5F4F) : Colors.grey[300]!,
                              width: isEditing ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row with level and buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Level dropdown or text
                                  Expanded(
                                    child: isEditing
                                        ? DropdownButtonFormField<String>(
                                            value: education['level'],
                                            decoration: InputDecoration(
                                              labelText: 'Education Level',
                                              labelStyle: TextStyle(fontSize: 12),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              border: OutlineInputBorder(),
                                            ),
                                            items: [
                                              'ELEMENTARY',
                                              'SECONDARY',
                                              'VOCATIONAL/TRADE COURSE',
                                              'COLLEGE',
                                              'GRADUATE STUDIES',
                                            ].map((level) {
                                              return DropdownMenuItem(
                                                value: level,
                                                child: Text(level, style: TextStyle(fontSize: 12)),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _educationData[index]['level'] = value!;
                                              });
                                            },
                                          )
                                        : Text(
                                            education['level'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF2C5F4F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  // Edit and Delete buttons
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isEditing ? Icons.check : Icons.edit,
                                          size: 20,
                                          color: Color(0xFF2C5F4F),
                                        ),
                                        onPressed: () {
                                          if (isEditing) {
                                            _saveEducation(index);
                                          } else {
                                            setState(() {
                                              _editingEducationIndex = index;
                                            });
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteEducation(index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // School Name
                              isEditing
                                  ? _buildEditableFieldInline(
                                      'School Name',
                                      education['schoolName'],
                                      (value) {
                                        _educationData[index]['schoolName'] = value;
                                      },
                                    )
                                  : _buildInfoFieldInline(
                                      'School Name',
                                      education['schoolName'],
                                    ),
                              const SizedBox(height: 12),
                              
                              // Degree/Course
                              isEditing
                                  ? _buildEditableFieldInline(
                                      'Degree/Course',
                                      education['degreeCourse'],
                                      (value) {
                                        _educationData[index]['degreeCourse'] = value;
                                      },
                                    )
                                  : _buildInfoFieldInline(
                                      'Degree/Course',
                                      education['degreeCourse'],
                                    ),
                              const SizedBox(height: 12),
                              
                              // Period Attended - From/To in a row
                              Row(
                                children: [
                                  Expanded(
                                    child: isEditing
                                        ? _buildDateFieldInline(
                                            'From',
                                            education['attendedFrom'],
                                            (value) {
                                              _educationData[index]['attendedFrom'] = value;
                                            },
                                          )
                                        : _buildInfoFieldInline(
                                            'From',
                                            education['attendedFrom'],
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: isEditing
                                        ? _buildDateFieldInline(
                                            'To',
                                            education['attendedTo'],
                                            (value) {
                                              _educationData[index]['attendedTo'] = value;
                                            },
                                          )
                                        : _buildInfoFieldInline(
                                            'To',
                                            education['attendedTo'],
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Highest Level/Year & Year Graduated in a row
                              Row(
                                children: [
                                  Expanded(
                                    child: isEditing
                                        ? _buildEditableFieldInline(
                                            'Highest Level/Units',
                                            education['highestLevel'],
                                            (value) {
                                              _educationData[index]['highestLevel'] = value;
                                            },
                                          )
                                        : _buildInfoFieldInline(
                                            'Highest Level/Units',
                                            education['highestLevel'],
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: isEditing
                                        ? _buildEditableFieldInline(
                                            'Year Graduated',
                                            education['yearGraduated'],
                                            (value) {
                                              _educationData[index]['yearGraduated'] = value;
                                            },
                                          )
                                        : _buildInfoFieldInline(
                                            'Year Graduated',
                                            education['yearGraduated'],
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Academic Honors
                              isEditing
                                  ? _buildEditableFieldInline(
                                      'Academic Honors',
                                      education['academicHonors'],
                                      (value) {
                                        _educationData[index]['academicHonors'] = value;
                                      },
                                    )
                                  : _buildInfoFieldInline(
                                      'Academic Honors',
                                      education['academicHonors'],
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

  // Civil Service Eligibility Section
  Widget _buildCivilServiceCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isCivilServiceExpanded = !_isCivilServiceExpanded;
              });
            },
            child: Container(
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
                  const Text(
                    'CIVIL SERVICE ELIGIBILITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (_isCivilServiceExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Eligibility Records',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _civilServiceData.add({
                              'careerService': '',
                              'rating': '',
                              'dateOfExam': '',
                              'placeOfExam': '',
                              'licenseNumber': '',
                              'validity': '',
                            });
                            _editingCivilServiceIndex =
                                _civilServiceData.length - 1;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._civilServiceData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> service = entry.value;
                    bool isEditing = _editingCivilServiceIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Record ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isEditing ? Icons.check : Icons.edit,
                                      size: 18,
                                      color: Color(0xFF2C5F4F),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _editingCivilServiceIndex = isEditing
                                            ? null
                                            : index;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _civilServiceData.removeAt(index);
                                        if (_editingCivilServiceIndex ==
                                            index) {
                                          _editingCivilServiceIndex = null;
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isEditing
                                    ? _buildEditableFieldInline(
                                        'Career Service/ RA 1080 (Board/ Bar) Under Special Laws/ CES/ CSEE Barangay Eligibility / Driver\'s License',
                                        service['careerService'],
                                        (value) {
                                          service['careerService'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'Career Service/ RA 1080 (Board/ Bar) Under Special Laws/ CES/ CSEE Barangay Eligibility / Driver\'s License',
                                        service['careerService'],
                                      ),
                                const SizedBox(height: 20),
                                // Rating
                                isEditing
                                    ? _buildEditableFieldInline(
                                        'Rating',
                                        service['rating'],
                                        (value) {
                                          service['rating'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'Rating',
                                        service['rating'],
                                      ),
                                const SizedBox(height: 20),
                                isEditing
                                    ? _buildDateFieldInline(
                                        'Date of Exam',
                                        service['dateOfExam'],
                                        (value) {
                                          service['dateOfExam'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'Date of Exam',
                                        service['dateOfExam'],
                                      ),
                                const SizedBox(height: 20),
                                isEditing
                                    ? _buildEditableFieldInline(
                                        'Place of Exam',
                                        service['placeOfExam'],
                                        (value) {
                                          service['placeOfExam'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'Place of Exam',
                                        service['placeOfExam'],
                                      ),
                                const SizedBox(height: 20),
                                isEditing
                                    ? _buildEditableFieldInline(
                                        'License Number',
                                        service['licenseNumber'],
                                        (value) {
                                          service['licenseNumber'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'License Number',
                                        service['licenseNumber'],
                                      ),
                                const SizedBox(height: 20),
                                isEditing
                                    ? _buildEditableFieldInline(
                                        'Validity',
                                        service['validity'],
                                        (value) {
                                          service['validity'] = value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        'Validity',
                                        service['validity'],
                                      ),
                              ],
                            ),
                          ),
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

  // Work Experience Section
  Widget _buildWorkExperienceCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isWorkExperienceExpanded = !_isWorkExperienceExpanded;
              });
            },
            child: Container(
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
                  const Text(
                    'WORK EXPERIENCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isWorkExperienceExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Work History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _workExperienceData.add({
                              'dateFrom': '',
                              'dateTo': '',
                              'positionTitle': '',
                              'department': '',
                              'monthlySalary': '',
                              'salaryGrade': '',
                              'statusOfAppointment': '',
                              'governmentService': '',
                            });
                            _editingWorkExperienceIndex =
                                _workExperienceData.length - 1;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._educationData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> education = entry.value;
                    bool isEditing = _editingEducationIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level (header)
                          Text(
                            education['level'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // School name under the level
                          isEditing
                              ? _buildEditableFieldInline(
                                  'Name of School',
                                  education['schoolName'],
                                  (value) {
                                    _educationData[index]['schoolName'] = value;
                                  },
                                )
                              : _buildInfoFieldInline(
                                  'Name of School',
                                  education['schoolName'],
                                ),
                          const SizedBox(height: 8),

                          // Edit / Delete buttons (always visible, same style as work experience)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.check : Icons.edit,
                                  size: 18,
                                  color: const Color(0xFF2C5F4F),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _editingEducationIndex = isEditing
                                        ? null
                                        : index;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _educationData.removeAt(index);
                                    if (_editingEducationIndex == index) {
                                      _editingEducationIndex = null;
                                    }
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
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

  // Voluntary Work Section
  Widget _buildVoluntaryWorkCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isVoluntaryWorkExpanded = !_isVoluntaryWorkExpanded;
              });
            },
            child: Container(
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
                ],
              ),
            ),
          ),
          if (_isVoluntaryWorkExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Voluntary Work',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _voluntaryWorkData.add({
                              'organization': '',
                              'dateFrom': '',
                              'dateTo': '',
                              'numberOfHours': '',
                              'positionNature': '',
                            });
                            _editingVoluntaryWorkIndex =
                                _voluntaryWorkData.length - 1;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  ..._voluntaryWorkData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> voluntary = entry.value;
                    bool isEditing = _editingVoluntaryWorkIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: organization title on left, edit/delete buttons on right (stays in place)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  voluntary['organization'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isEditing ? Icons.check : Icons.edit,
                                      size: 18,
                                      color: const Color(0xFF2C5F4F),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _editingVoluntaryWorkIndex = isEditing
                                            ? null
                                            : index;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _voluntaryWorkData.removeAt(index);
                                        if (_editingVoluntaryWorkIndex ==
                                            index) {
                                          _editingVoluntaryWorkIndex = null;
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Fields stacked in a column (editable when in edit mode)
                          isEditing
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDateFieldInline(
                                      'Date From',
                                      voluntary['dateFrom'],
                                      (value) {
                                        _voluntaryWorkData[index]['dateFrom'] =
                                            value;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateFieldInline(
                                      'Date To',
                                      voluntary['dateTo'],
                                      (value) {
                                        _voluntaryWorkData[index]['dateTo'] =
                                            value;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _buildEditableFieldInline(
                                      'Number of Hours',
                                      voluntary['numberOfHours'],
                                      (value) {
                                        _voluntaryWorkData[index]['numberOfHours'] =
                                            value;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _buildEditableFieldInline(
                                      'Position / Nature of Work',
                                      voluntary['positionNature'],
                                      (value) {
                                        _voluntaryWorkData[index]['positionNature'] =
                                            value;
                                      },
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoFieldInline(
                                      'Date From',
                                      voluntary['dateFrom'],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoFieldInline(
                                      'Date To',
                                      voluntary['dateTo'],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoFieldInline(
                                      'Number of Hours',
                                      voluntary['numberOfHours'],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoFieldInline(
                                      'Position / Nature of Work',
                                      voluntary['positionNature'],
                                    ),
                                  ],
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

  // Learning and Development Section
  Widget _buildLearningDevelopmentCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isLearningDevelopmentExpanded =
                    !_isLearningDevelopmentExpanded;
              });
            },
            child: Container(
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
                      'LEARNING AND DEVELOPMENT (L&D) INTERVENTIONS/TRAINING PROGRAMS ATTENDED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLearningDevelopmentExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Training Programs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _learningDevelopmentData.add({
                              'title': '',
                              'dateFrom': '',
                              'dateTo': '',
                              'numberOfHours': '',
                              'typeOfLD': '',
                              'conductedBy': '',
                            });
                            _editingLearningDevelopmentIndex =
                                _learningDevelopmentData.length - 1;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Title of Learning and Development Interventions / Training Programs',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._learningDevelopmentData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> training = entry.value;
                    bool isEditing = _editingLearningDevelopmentIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOP: title (left) and buttons (right) in a single row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: isEditing
                                    ? _buildEditableFieldInline(
                                        '',
                                        training['title'],
                                        (value) {
                                          _learningDevelopmentData[index]['title'] =
                                              value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        '',
                                        training['title'],
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isEditing ? Icons.check : Icons.edit,
                                      size: 18,
                                      color: const Color(0xFF2C5F4F),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _editingLearningDevelopmentIndex =
                                            isEditing ? null : index;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _learningDevelopmentData.removeAt(
                                          index,
                                        );
                                        if (_editingLearningDevelopmentIndex ==
                                            index) {
                                          _editingLearningDevelopmentIndex =
                                              null;
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          if (isEditing) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateFieldInline(
                                    'Date From',
                                    training['dateFrom'],
                                    (value) {
                                      _learningDevelopmentData[index]['dateFrom'] =
                                          value;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildDateFieldInline(
                                    'Date To',
                                    training['dateTo'],
                                    (value) {
                                      _learningDevelopmentData[index]['dateTo'] =
                                          value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEditableFieldInline(
                                    'Number of Hours',
                                    training['numberOfHours'],
                                    (value) {
                                      _learningDevelopmentData[index]['numberOfHours'] =
                                          value;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildEditableFieldInline(
                                    'Type of LD',
                                    training['typeOfLD'],
                                    (value) {
                                      _learningDevelopmentData[index]['typeOfLD'] =
                                          value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildEditableFieldInline(
                              'Conducted / Sponsored By',
                              training['conductedBy'],
                              (value) {
                                _learningDevelopmentData[index]['conductedBy'] =
                                    value;
                              },
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            _buildInfoFieldInline(
                              'Date From',
                              training['dateFrom'],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoFieldInline(
                              'Date To',
                              training['dateTo'],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoFieldInline(
                              'Number of Hours',
                              training['numberOfHours'],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoFieldInline(
                              'Type of LD',
                              training['typeOfLD'],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoFieldInline(
                              'Conducted / Sponsored By',
                              training['conductedBy'],
                            ),
                          ],
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

  // Other Information Section
  Widget _buildOtherInformationCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOtherInformationExpanded = !_isOtherInformationExpanded;
              });
            },
            child: Container(
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
                  const Text(
                    'OTHER INFORMATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isOtherInformationExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Special Skills and Hobbies Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Special Skills and Hobbies',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _specialSkillsData.add({'skill': ''});
                                _editingSpecialSkillIndex =
                                    _specialSkillsData.length - 1;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ..._specialSkillsData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> skill = entry.value;
                    bool isEditing = _editingSpecialSkillIndex == index;

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: isEditing
                                ? _buildEditableFieldInline(
                                    '',
                                    skill['skill'],
                                    (value) {
                                      _specialSkillsData[index]['skill'] =
                                          value;
                                    },
                                  )
                                : _buildInfoFieldInline('', skill['skill']),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _editingSpecialSkillIndex = isEditing
                                    ? null
                                    : index;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _specialSkillsData.removeAt(index);
                                if (_editingSpecialSkillIndex == index) {
                                  _editingSpecialSkillIndex = null;
                                }
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 50),

                  // Non-Academic Distinctions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Non-Academic Distinctions /\nRecognition',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _nonAcademicDistinctionsData.add({
                                  'distinction': '',
                                });
                                _editingNonAcademicDistinctionIndex =
                                    _nonAcademicDistinctionsData.length - 1;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  ..._nonAcademicDistinctionsData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> distinction = entry.value;
                    bool isEditing =
                        _editingNonAcademicDistinctionIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: isEditing
                                ? _buildEditableFieldInline(
                                    '',
                                    distinction['distinction'],
                                    (value) {
                                      _nonAcademicDistinctionsData[index]['distinction'] =
                                          value;
                                    },
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    distinction['distinction'],
                                  ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _editingNonAcademicDistinctionIndex = isEditing
                                    ? null
                                    : index;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _nonAcademicDistinctionsData.removeAt(index);
                                if (_editingNonAcademicDistinctionIndex ==
                                    index) {
                                  _editingNonAcademicDistinctionIndex = null;
                                }
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 50),

                  // Membership Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Membership in Association / \nOrganization',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Action',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _membershipData.add({'organization': ''});
                                _editingMembershipIndex =
                                    _membershipData.length - 1;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._membershipData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> membership = entry.value;
                    bool isEditing = _editingMembershipIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: isEditing
                                ? _buildEditableFieldInline(
                                    '',
                                    membership['organization'],
                                    (value) {
                                      _membershipData[index]['organization'] =
                                          value;
                                    },
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    membership['organization'],
                                  ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: Color(0xFF2C5F4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _editingMembershipIndex = isEditing
                                    ? null
                                    : index;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _membershipData.removeAt(index);
                                if (_editingMembershipIndex == index) {
                                  _editingMembershipIndex = null;
                                }
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 50),

                  // Other Information Inquiry Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Other Information Inquiry - (Update Data if Applicable)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isEditingOtherInquiry
                                  ? TextField(
                                      controller: TextEditingController(
                                        text: _otherInformationInquiry,
                                      ),
                                      onChanged: (value) {
                                        _otherInformationInquiry = value;
                                      },
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    )
                                  : Text(
                                      _otherInformationInquiry.isEmpty
                                          ? 'No data'
                                          : _otherInformationInquiry,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditingOtherInquiry ? Icons.check : Icons.edit,
                            size: 18,
                            color: Color(0xFF2C5F4F),
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditingOtherInquiry = !_isEditingOtherInquiry;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // References Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'References',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _referencesData.add({
                              'name': '',
                              'address': '',
                              'telephoneNo': '',
                            });
                            _editingReferenceIndex = _referencesData.length - 1;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ..._referencesData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> reference = entry.value;
                    bool isEditing = _editingReferenceIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: isEditing
                                    ? _buildEditableFieldInline(
                                        '',
                                        reference['name'],
                                        (value) {
                                          _referencesData[index]['name'] =
                                              value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        '',
                                        reference['name'],
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: isEditing
                                    ? _buildEditableFieldInline(
                                        '',
                                        reference['address'],
                                        (value) {
                                          _referencesData[index]['address'] =
                                              value;
                                        },
                                      )
                                    : _buildInfoFieldInline(
                                        '',
                                        reference['address'],
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isEditing ? Icons.check : Icons.edit,
                                      size: 18,
                                      color: Color(0xFF2C5F4F),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _editingReferenceIndex = isEditing
                                            ? null
                                            : index;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _referencesData.removeAt(index);
                                        if (_editingReferenceIndex == index) {
                                          _editingReferenceIndex = null;
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isEditing) ...[
                            const SizedBox(height: 8),
                            _buildPhoneFieldInline(
                              'Telephone No.',
                              reference['telephoneNo'],
                              (value) {
                                _referencesData[index]['telephoneNo'] = value;
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 50),

                  // Government Issued ID Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Government Issued ID (i.e.Passport, GSIS, SSS, PRC, Driver\'s License, etc.)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 97, 97, 97),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditingGovernmentID ? Icons.check : Icons.edit,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingGovernmentID = !_isEditingGovernmentID;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditingGovernmentID) ...[
                          _buildEditableFieldInline(
                            'Issued ID',
                            _governmentIDData['issuedID'],
                            (value) {
                              _governmentIDData['issuedID'] = value;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildEditableFieldInline(
                            'Unified Multi-Purpose ID',
                            _governmentIDData['unifiedMultiPurposeID'],
                            (value) {
                              _governmentIDData['unifiedMultiPurposeID'] =
                                  value;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildEditableFieldInline(
                            'ID/License/Passport No.',
                            _governmentIDData['idNumber'],
                            (value) {
                              _governmentIDData['idNumber'] = value;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildDateFieldInline(
                            'Date Issued',
                            _governmentIDData['dateIssued'],
                            (value) {
                              _governmentIDData['dateIssued'] = value;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildEditableFieldInline(
                            'Place Issued',
                            _governmentIDData['placeIssued'],
                            (value) {
                              _governmentIDData['placeIssued'] = value;
                            },
                          ),
                        ] else ...[
                          _buildInfoFieldInline(
                            'Issued ID',
                            _governmentIDData['issuedID'],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoFieldInline(
                            'Unified Multi-Purpose ID',
                            _governmentIDData['unifiedMultiPurposeID'],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoFieldInline(
                            'ID/License/Passport No.',
                            _governmentIDData['idNumber'],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoFieldInline(
                            'Date Issued',
                            _governmentIDData['dateIssued'],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoFieldInline(
                            'Place Issued',
                            _governmentIDData['placeIssued'],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyTimeRecordCard() {
    return DtrWidget(
      token: widget.token,
      baseUrl: widget.baseUrl,
      userId: _userDetails?['employee']?['employeeId'] ?? 'N/A',
    );
  }

  // Helper method for inline field (no background, just label and value)
  Widget _buildInfoFieldInline(String label, dynamic value) {
    String displayValue = 'N/A'; // Default to N/A
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

  // Helper method for editable inline field
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
              borderSide: BorderSide(color: Color(0xFF2C5F4F)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C5F4F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFieldInline(
    String label,
    String? value,
    Function(String) onChanged,
  ) {
    // Create a controller and set its text to the current value
    final controller = TextEditingController(text: value ?? '');

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
        GestureDetector(
          onTap: () async {
            // Parse existing date if available
            DateTime? initialDate;
            if (value != null && value.isNotEmpty) {
              try {
                final parts = value.split('/');
                if (parts.length == 3) {
                  initialDate = DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[0]), // month
                    int.parse(parts[1]), // day
                  );
                }
              } catch (e) {
                print('Error parsing date: $e');
              }
            }

            // Show date picker
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xFF2C5F4F),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            // Format and update the date
            if (pickedDate != null) {
              final formattedDate =
                  '${pickedDate.year}-'
                  '${pickedDate.month.toString().padLeft(2, '0')}-'
                  '${pickedDate.day.toString().padLeft(2, '0')}';
              controller.text = formattedDate; // Update the controller
              onChanged(formattedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller, // Use controller instead of initialValue
              readOnly: true,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF2C5F4F),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneFieldInline(
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
          keyboardType: TextInputType.phone, // Shows number keyboard
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Only allows digits 0-9
            LengthLimitingTextInputFormatter(11), // Maximum 11 digits
          ],
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          // decoration: InputDecoration(
          //   hintText: '09XXXXXXXXX',
          //   contentPadding: const EdgeInsets.symmetric(vertical: 4),
          //   isDense: true,
          // ),
        ),
      ],
    );
  }

  // Helper method for drawer menu items
  Widget _buildDrawerItem(String title, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF00674F) : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00674F) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF00674F).withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedMenu = title;
        });
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}
