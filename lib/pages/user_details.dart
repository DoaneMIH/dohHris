
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/pages/dtr_page.dart';
import 'package:mobile_application/services/authenticated_photo.dart';
import '../services/user_service.dart';
import 'login_page.dart';

class UserDetailsPageContent extends StatefulWidget {
  final String token;
  final String baseUrl;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const UserDetailsPageContent({
    Key? key,
    required this.token,
    required this.baseUrl,
     this.scaffoldKey,
  }) : super(key: key);

  @override
  State<UserDetailsPageContent> createState() => _UserDetailsPageContentState();
}

class _UserDetailsPageContentState extends State<UserDetailsPageContent> {

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Called by MainNavigation to open the side drawer from the bottom nav bar.
  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

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
  List<Map<String, dynamic>> _workExperienceListData = [];
  List<Map<String, dynamic>> _voluntaryWorkListData = [];
  List<Map<String, dynamic>> _learningDevelopmentListData = [];
  List<Map<String, dynamic>> _civilServiceEligibilityListData = [];
  Map<String, dynamic>? _otherInfoRecord;

  // Educational background data
  bool _isEducationalBackgroundExpanded = true;
  List<Map<String, dynamic>> _educationData = [];
  int? _editingEducationIndex;
  Set<int> _collapsedEducationIndexes = <int>{};

  // Civil service eligibility data
  bool _isCivilServiceExpanded = true;
  List<Map<String, dynamic>> _civilServiceData = [];
  int? _editingCivilServiceIndex;
  Set<int> _collapsedCivilServiceIndexes = <int>{};

  // Work experience data
  bool _isWorkExperienceExpanded = true;
  List<Map<String, dynamic>> _workExperienceData = [];
  int? _editingWorkExperienceIndex;
  Set<int> _collapsedWorkExperienceIndexes = <int>{};

  // Voluntary work data
  bool _isVoluntaryWorkExpanded = true;
  List<Map<String, dynamic>> _voluntaryWorkData = [];
  int? _editingVoluntaryWorkIndex;
  Set<int> _collapsedVoluntaryWorkIndexes = <int>{};

  // Learning and development data
  bool _isLearningDevelopmentExpanded = true;
  List<Map<String, dynamic>> _learningDevelopmentData = [];
  int? _editingLearningDevelopmentIndex;
  Set<int> _collapsedLearningDevIndexes = <int>{};

  bool _isOtherInformationExpanded = true;
  List<Map<String, dynamic>> _specialSkillsData = [];
  int? _editingSpecialSkillIndex;

  // References — fetched from API (single record: personRef)
  Map<String, dynamic>? _personRefRecord; // raw API record with 'id'
  bool _isFetchingPersonRef = false;
  bool _isEditingPersonRef = false;
  Map<String, dynamic> _personRefData = {};

  List<Map<String, dynamic>> _nonAcademicDistinctionsData = [];
  int? _editingNonAcademicDistinctionIndex;

  List<Map<String, dynamic>> _membershipData = [];
  int? _editingMembershipIndex;

  bool _isFetchingOtherInfo = false;
  bool _isEditingOtherInfo = false;

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

        // Fetch work experience data
        _fetchWorkExperienceData();

        // Fetch voluntary work data
        _fetchVoluntaryWorkData();

        // Fetch learning and development data
        _fetchLearningDevelopmentData();

        // Fetch civil service eligibility data
        _fetchCivilServiceEligibilityData();

        // Fetch person reference data
        _fetchPersonReferenceData();

        // Fetch other information data
        _fetchOtherInfoData();
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

  Future<void> _deleteEducation(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Education'),
        content: const Text(
          'Are you sure you want to delete this education record?',
        ),
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

  //FETCH WORK EXPERIENCE DATA
  Future<void> _fetchWorkExperienceData() async {
    print('\n💼 [UserDetailsPage] FETCHING WORK EXPERIENCE DATA');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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

        print(
          '✅ Loaded ${_workExperienceListData.length} work experience records',
        );
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }

  void _parseWorkExperienceData() {
    _workExperienceData = _workExperienceListData.map((work) {
      // ⭐ FIX: Convert boolean to "Yes"/"No" for display
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

  //ADD WORK EXPERIENCE SAVE AND DELETE FUNCTIONS HERE
  Future<void> _saveWorkExperience(int index) async {
    final work = _workExperienceData[index];

    // Validate position title
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

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
        title: const Text('Delete Work Experience'),
        content: const Text(
          'Are you sure you want to delete this work experience record?',
        ),
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

  Future<void> _fetchVoluntaryWorkData() async {
    print('\n🤝 [UserDetailsPage] FETCHING VOLUNTARY WORK DATA');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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

        print(
          '✅ Loaded ${_voluntaryWorkListData.length} voluntary work records',
        );
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

  Future<void> _saveVoluntaryWork(int index) async {
    final voluntary = _voluntaryWorkData[index];

    // Validate organization
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

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
        title: const Text('Delete Voluntary Work'),
        content: const Text(
          'Are you sure you want to delete this voluntary work record?',
        ),
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

  //LEARNING AND DEVELOPMENT FUNCTIONS
  Future<void> _fetchLearningDevelopmentData() async {
    print('\n📚 [UserDetailsPage] FETCHING LEARNING AND DEVELOPMENT DATA');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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
        'hours': learning['hours']?.toString() ?? '', // API: hours
        'ldType': learning['ldType'] ?? '', // API: type  (DB: ld_type)
        'conductedBy': learning['conductedBy'] ?? '',
        'certificate_url': learning['certificate_url'] ?? '', // ⭐ Added
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

      // ⭐ Map widget field names → API field names expected by the backend
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
              content: Text(
                'Learning and development record saved successfully',
              ),
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

  Future<void> _deleteLearningDevelopment(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Learning and Development Record'),
        content: const Text(
          'Are you sure you want to delete this learning and development record?',
        ),
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

  Future<void> _fetchCivilServiceEligibilityData() async {
    print('\n📜 [UserDetailsPage] FETCHING CIVIL SERVICE ELIGIBILITY');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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

        print(
          '✅ Loaded ${_civilServiceEligibilityListData.length} civil service eligibility records',
        );
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
        // 'validity': eligibility['validity'] ?? '',
      };
    }).toList();
    _collapsedCivilServiceIndexes = List<int>.generate(
      _civilServiceData.length,
      (index) => index,
    ).toSet();
    print(
      '📜 Parsed ${_civilServiceData.length} civil service eligibility records',
    );
  }

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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

      // ⭐ Map widget field names → API field names
      final eligibilityData = {
        'serviceEligibility': eligibility['serviceEligibility'] ?? '',
        'rating': eligibility['rating'] ?? '',
        'examPlace': eligibility['examPlace'] ?? '',
        'examDate': eligibility['examDate'] ?? '',
        'licenseNo': eligibility['licenseNo'] ?? '',
        // 'validity': eligibility['validity'] ?? '',
      };

      final response =
          eligibility.containsKey('id') && eligibility['id'] != null
          ? await _userService.updateCivilServiceEligibility(
              widget.token,
              eligibility['id'].toString(),
              eligibilityData,
            )
          : await _userService.addCivilServiceEligibility(
              widget.token,
              employeeId.toString(),
              eligibilityData,
            );

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
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCivilServiceEligibility(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Civil Service Eligibility'),
        content: const Text(
          'Are you sure you want to delete this civil service eligibility record?',
        ),
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
      final eligibility = _civilServiceData[index];

      if (eligibility.containsKey('id') && eligibility['id'] != null) {
        final response = await _userService.deleteCivilServiceEligibility(
          widget.token,
          eligibility['id'].toString(),
        );

        if (mounted) Navigator.pop(context);

        if (response['success']) {
          await _fetchCivilServiceEligibilityData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Civil service eligibility deleted'),
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
          _civilServiceData.removeAt(index);
          if (_editingCivilServiceIndex == index) {
            _editingCivilServiceIndex = null;
          }
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

  Future<void> _fetchOtherInfoData() async {
    print('\n📋 [UserDetailsPage] FETCHING OTHER INFO');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
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
          _otherInfoRecord = rawList.isNotEmpty
              ? Map<String, dynamic>.from(rawList.first)
              : null;

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

  void _parseOtherInfoData() {
    if (_otherInfoRecord == null) {
      _specialSkillsData = [];
      _nonAcademicDistinctionsData = [];
      _membershipData = [];
      return;
    }

    // skills is a comma-separated string in the API
    final skillsRaw = _otherInfoRecord!['skills']?.toString() ?? '';
    _specialSkillsData = skillsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => {'skill': s})
        .toList();

    // recognition is a comma-separated string
    final recognitionRaw = _otherInfoRecord!['recognition']?.toString() ?? '';
    _nonAcademicDistinctionsData = recognitionRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => {'distinction': s})
        .toList();

    // membership is a comma-separated string
    final membershipRaw = _otherInfoRecord!['membership']?.toString() ?? '';
    _membershipData = membershipRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => {'organization': s})
        .toList();
  }

  Future<void> _saveOtherInfo() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) throw Exception('Employee ID not found');

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
      await _userService.updateOtherInfo(
        widget.token,
        entry.key,
        payload,
      );
    }

    // ── 2. Handle NEW items: each one gets its own addOtherInfo call ──
    // New skills — each becomes its own record
    for (final e in _specialSkillsData) {
      final v = e['skill']?.toString().trim() ?? '';
      if (v.isNotEmpty && e['_recordId'] == null) {
        await _userService.addOtherInfo(
          widget.token,
          employeeId.toString(),
          {'skills': v, 'recognition': '', 'membership': ''},
        );
      }
    }

    // New recognitions — each becomes its own record
    for (final e in _nonAcademicDistinctionsData) {
      final v = e['distinction']?.toString().trim() ?? '';
      if (v.isNotEmpty && e['_recordId'] == null) {
        await _userService.addOtherInfo(
          widget.token,
          employeeId.toString(),
          {'skills': '', 'recognition': v, 'membership': ''},
        );
      }
    }

    // New memberships — each becomes its own record
    for (final e in _membershipData) {
      final v = e['organization']?.toString().trim() ?? '';
      if (v.isNotEmpty && e['_recordId'] == null) {
        await _userService.addOtherInfo(
          widget.token,
          employeeId.toString(),
          {'skills': '', 'recognition': '', 'membership': v},
        );
      }
    }

    if (mounted) Navigator.pop(context);
    await _fetchOtherInfoData();
    if (mounted) {
      setState(() => _isEditingOtherInfo = false);
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


  Future<void> _fetchPersonReferenceData() async {
    print('\n👥 [UserDetailsPage] FETCHING PERSON REFERENCE');

    final employeeId = _userDetails?['employee']?['id'];
    if (employeeId == null) {
      print('❌ No employee ID, skipping person reference fetch');
      return;
    }

    setState(() => _isFetchingPersonRef = true);

    try {
      final response = await _userService.getPersonReference(
        widget.token,
        employeeId.toString(),
      );

      if (response['success']) {
        final data = response['data'];
        // API may return single object or a list — handle both
        dynamic raw = data['personRef'] ?? data['personRefList'];
        if (raw is List && raw.isNotEmpty) raw = raw.first;
        setState(() {
          _personRefRecord = (raw != null && raw is Map)
              ? Map<String, dynamic>.from(raw)
              : null;
          _parsePersonRefData();
          _isFetchingPersonRef = false;
        });
        print('✅ Person reference loaded: $_personRefRecord');
      } else {
        print('⚠️ Person reference fetch failed: ${response['error']}');
        setState(() => _isFetchingPersonRef = false);
      }
    } catch (e) {
      print('💥 Exception fetching person reference: $e');
      setState(() => _isFetchingPersonRef = false);
    }
  }

  void _parsePersonRefData() {
    if (_personRefRecord == null) {
      _personRefData = {};
      return;
    }

    _personRefData = {
      'id': _personRefRecord!['id'],
      'refName': _personRefRecord!['refName'] ?? '',
      'refAddress': _personRefRecord!['refAddress'] ?? '',
      'refTelephone': _personRefRecord!['refTelephone'] ?? '',
    };
    print('👥 Parsed person reference data: $_personRefData');
  }

  Future<void> _savePersonReference() async {
    if ((_personRefData['refName'] ?? '').toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reference name before saving'),
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

      final payload = {
        'refName': _personRefData['refName']?.toString().trim() ?? '',
        'refAddress': _personRefData['refAddress']?.toString().trim() ?? '',
        'refTelephone': _personRefData['refTelephone']?.toString().trim() ?? '',
      };

      final bool isUpdate =
          _personRefData.containsKey('id') && _personRefData['id'] != null;

      final response = isUpdate
          ? await _userService.updatePersonReference(
              widget.token,
              _personRefData['id'].toString(),
              payload,
            )
          : await _userService.addPersonReference(
              widget.token,
              employeeId.toString(),
              payload,
            );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchPersonReferenceData();
        if (mounted) {
          setState(() => _isEditingPersonRef = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reference saved successfully'),
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

  Future<void> _deletePersonReference() async {
    if (!_personRefData.containsKey('id') || _personRefData['id'] == null)
      return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reference'),
        content: const Text(
          'Are you sure you want to delete this reference record?',
        ),
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
      final response = await _userService.deletePersonReference(
        widget.token,
        _personRefData['id'].toString(),
      );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchPersonReferenceData();
        if (mounted) {
          setState(() {
            _isEditingPersonRef = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reference deleted'),
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
            content: Text('Failed to delete: $e'),
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
    // Use the externally-provided key so MainNavigation can open the drawer,
    // otherwise fall back to the internal key.
    final scaffoldKey = widget.scaffoldKey ?? _scaffoldKey;
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          // Drawer is opened via the bottom nav Menu icon — hide the AppBar hamburger.
          automaticallyImplyLeading: false,
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
        endDrawer: Drawer(
          width: 300,
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // SizedBox(
              //   height: 80,
              //   child: DrawerHeader(
              //     margin: EdgeInsets.zero,
              //     decoration: const BoxDecoration(color: Color(0xFF00674F)),
              //     child: const Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         'Menu',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // Information Section with Dropdown
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
                    'Person References',
                    Icons.info,
                    _selectedMenu == 'Person References',
                  ),
                  _buildDrawerItem(
                    'Other Information',
                    Icons.info,
                    _selectedMenu == 'Other Information',
                  ),
                ],
              ),
              // Services Section with Dropdown
              // ExpansionTile(
              //   leading: const Icon(
              //     Icons.room_service,
              //     color: Color(0xFF00674F),
              //   ),
              //   title: const Text(
              //     'Services',
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       color: Color(0xFF00674F),
              //     ),
              //   ),
              //   iconColor: const Color.fromARGB(255, 0, 0, 0),
              //   collapsedIconColor: const Color.fromARGB(255, 0, 0, 0),
              //   initiallyExpanded: _isServicesExpanded,
              //   onExpansionChanged: (expanded) {
              //     setState(() {
              //       _isServicesExpanded = expanded;
              //     });
              //   },
              //   children: [
              //     _buildDrawerItem(
              //       'Daily Time Record',
              //       Icons.access_time,
              //       _selectedMenu == 'Daily Time Record',
              //     ),
              //   ],
              // ),
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
      height: 295,
      padding: const EdgeInsets.all(16.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: AuthenticatedProfilePhoto(
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
      case 'Person References':
        return _buildPersonReferenceCard();
      case 'Other Information':
        return _buildOtherInformationCard();
      case 'Daily Time Record':
        return _buildDailyTimeRecordCard();
      default:
        return _buildPersonalInformationCard();
    }
  }

   Widget _buildPersonalInformationCard() {
    return Column(
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
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
                                size: 15,
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
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 15,
                      ),
        
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isEditingPersonalInfo
                              ? _buildDateFieldInline(
                                  'Date of Birth (YYYY-MM-DD)',
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
                          if (_isEditingPersonalInfo) ...[
                          
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingPersonalInfo = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00674F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Family Background Card Widget
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
              )
            // Show Edit + Delete buttons only when spouse exists (or currently adding)
            else if (hasSpouse || _isEditingSpouse)
            
              // Row(
              //   children: [
              //     IconButton(
              //       icon: Icon(
              //         _isEditingSpouse ? Icons.check : Icons.edit,
              //         size: 20,
              //         color: Colors.black,
              //       ),
              //       onPressed: () {
              //         if (_isEditingSpouse) {
              //           _saveSpouse();
              //         } else {
              //           setState(() => _isEditingSpouse = true);
              //         }
              //       },
              //       padding: EdgeInsets.zero,
              //       constraints: const BoxConstraints(),
              //     ),
              //     if (hasSpouse) ...[
              //       const SizedBox(width: 8),
              //       IconButton(
              //         icon: const Icon(
              //           Icons.delete,
              //           size: 20,
              //           color: Colors.black,
              //         ),
              //         onPressed: () => _deleteSpouse(),
              //         padding: EdgeInsets.zero,
              //         constraints: const BoxConstraints(),
              //       ),
              //     ],
              //   ],
              // ),
              PopupMenuButton<String>(
  icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
  padding: EdgeInsets.zero,
  onSelected: (value) {
    if (value == 'edit') {
      if (_isEditingSpouse) {
        _saveSpouse();
      } else {
        setState(() => _isEditingSpouse = true);
      }
    } else if (value == 'delete') {
      _deleteSpouse();
    } else if (value == 'cancel') {
      setState(() => _isEditingSpouse = false);
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(_isEditingSpouse ? Icons.check : Icons.edit, size: 20),
          const SizedBox(width: 8),
          Text(_isEditingSpouse ? 'Save' : 'Edit'),
        ],
      ),
    ),
    if (hasSpouse)
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 20),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
      ),
    const PopupMenuItem(
      value: 'cancel',
      child: Row(
        children: [
          Icon(Icons.cancel, size: 20),
          SizedBox(width: 8),
          Text('Cancel'),
        ],
      ),
    ),
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
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Children Section
//   Widget _buildChildrenSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'CHILDREN',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),

//         ..._childrenData.asMap().entries.map((entry) {
//           int index = entry.key;
//           Map<String, dynamic> child = entry.value;
//           bool isEditing = _editingChildIndex == index;

//           return Container(
            
//             padding: const EdgeInsets.all(5),
//             decoration: BoxDecoration(color: Colors.white),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Child ${index + 1}',
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                     // Row(
//                     //   children: [
//                     //     IconButton(
//                     //       icon: Icon(
//                     //         isEditing ? Icons.check : Icons.edit,
//                     //         size: 18,
//                     //         color: Colors.black,
//                     //       ),
//                     //       onPressed: () {
//                     //         if (isEditing) {
//                     //           _saveChild(index);
//                     //         } else {
//                     //           setState(() => _editingChildIndex = index);
//                     //         }
//                     //       },
//                     //       padding: EdgeInsets.zero,
//                     //       constraints: const BoxConstraints(),
//                     //     ),

//                     //     IconButton(
//                     //       icon: const Icon(
//                     //         Icons.delete,
//                     //         size: 18,
//                     //         color: Colors.black,
//                     //       ),
//                     //       onPressed: () => _deleteChild(index),
//                     //       padding: EdgeInsets.zero,
//                     //       constraints: const BoxConstraints(),
//                     //     ),
//                     //   ],
//                     // ),

//                     PopupMenuButton<String>(
//   icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
//   padding: EdgeInsets.zero,
//   onSelected: (value) {
//     if (value == 'edit') {
//       if (isEditing) {
//         _saveChild(index);
//       } else {
//         setState(() => _editingChildIndex = index);
//       }
//     } else if (value == 'delete') {
//       _deleteChild(index);
//     } else if (value == 'cancel') {
//       setState(() => _editingChildIndex = -1);
//     }
//   },
//   itemBuilder: (context) => [
//     PopupMenuItem(
//       value: 'edit',
//       child: Row(
//         children: [
//           Icon(isEditing ? Icons.check : Icons.edit, size: 18),
//           const SizedBox(width: 8),
//           Text(isEditing ? 'Save' : 'Edit'),
//         ],
//       ),
//     ),
//     const PopupMenuItem(
//       value: 'delete',
//       child: Row(
//         children: [
//           Icon(Icons.delete, size: 18),
//           SizedBox(width: 8),
//           Text('Delete'),
//         ],
//       ),
//     ),
//     const PopupMenuItem(
//       value: 'cancel',
//       child: Row(
//         children: [
//           Icon(Icons.cancel, size: 18),
//           SizedBox(width: 8),
//           Text('Cancel'),
//         ],
//       ),
//     ),
//   ],
// ),
//                   ],
//                 ),

//                 Container(
//                   // spacing around each child box
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 2,
//                     vertical: 6,
//                   ),
//                   // inner spacing of the white box
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       isEditing
//                           ? _buildEditableFieldInline(
//                               'Name of Children',
//                               child['name'],
//                               (value) {
//                                 _childrenData[index]['name'] = value;
//                               },
//                             )
//                           : _buildInfoFieldInline(
//                               'Name of Children',
//                               child['name'],
//                             ),
//                       const SizedBox(height: 8),
//                       isEditing
//                           ? _buildDateFieldInline(
//                               'Birthday (YYYY-MM-DD)',
//                               child['birthday'],
//                               (value) {
//                                 _childrenData[index]['birthday'] = value;
//                               },
//                             )
//                           : _buildInfoFieldInline(
//                               'Birthday (YYYY-MM-DD)',
//                               child['birthday'],
//                             ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//         if (_editingChildIndex == null)
//           Align(
//             alignment: Alignment.centerRight,
//             child: IconButton(
//               icon: const Icon(
//                 Icons.add_circle,
//                 size: 25,
//                 color: Color(0xFF2C5F4F),
//               ),
//               onPressed: () {
//                 setState(() {
//                   _childrenData.add({'name': '', 'birthday': ''});
//                   _editingChildIndex = _childrenData.length - 1;
//                 });
//               },
//               tooltip: 'Add Child',
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),
//           ),
       
//       ],
//     );
//   }


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
                icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') {
                          if (isEditing) {
                            _saveChild(index);
                          } else {
                            setState(() => _editingChildIndex = index);
                          }
                        } else if (value == 'delete') {
                          _deleteChild(index);
                        } else if (value == 'cancel') {
                          setState(() => _editingChildIndex = null);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(isEditing ? Icons.check : Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text(isEditing ? 'Save' : 'Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, size: 18),
                              SizedBox(width: 8),
                              Text('Cancel'),
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
  // Widget _buildFatherSection() {
  //   // A father record exists only when the parsed data contains an 'id' from the API
  //   final bool hasFather =
  //       _fatherData.containsKey('id') && _fatherData['id'] != null;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
        

  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           const Text(
  //             'FATHER',
  //             style: TextStyle(
  //               fontSize: 15,
  //               fontWeight: FontWeight.w700,
  //               color: Colors.black,
  //             ),
  //           ),
  //           // Show Add button only when there is no father record yet
  //           if (!hasFather && !_isEditingFather)
  //             TextButton.icon(
  //               onPressed: () {
  //                 setState(() {
  //                   _fatherData = {
  //                     'firstName': '',
  //                     'middleName': '',
  //                     'lastName': '',
  //                     'nameExtension': '',
  //                   };
  //                   _isEditingFather = true;
  //                 });
  //               },
  //               icon: const Icon(
  //                 Icons.add_circle,
  //                 size: 20,
  //                 color: Color(0xFF2C5F4F),
  //               ),
  //               label: const Text(
  //                 'Add',
  //                 style: TextStyle(
  //                   color: Color(0xFF2C5F4F),
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               style: TextButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(horizontal: 4),
  //               ),
  //             )
  //           // Show Edit button when father record exists or currently adding
  //           else if (hasFather || _isEditingFather)
  //             IconButton(
  //               icon: Icon(
  //                 _isEditingFather ? Icons.check : Icons.edit,
  //                 size: 20,
  //                 color: Colors.black,
  //               ),
  //               onPressed: () {
  //                 if (_isEditingFather) {
  //                   _saveFather();
  //                 } else {
  //                   setState(() => _isEditingFather = true);
  //                 }
  //               },
  //               padding: EdgeInsets.zero,
  //               constraints: const BoxConstraints(),
  //             ),
  //         ],
  //       ),

  //       // If no father and not editing, show a subtle empty-state hint
  //       if (!hasFather && !_isEditingFather)
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 8.0),
  //           child: Text(
  //             'No father information added yet.',
  //             style: TextStyle(
  //               fontSize: 13,
  //               color: Colors.grey[500],
  //               fontStyle: FontStyle.italic,
  //             ),
  //           ),
  //         ),

  //       // Show fields only when father record exists or when adding/editing
  //       if (hasFather || _isEditingFather)
  //         Container(
  //           margin: const EdgeInsets.only(bottom: 12),
  //           padding: const EdgeInsets.all(12),
  //           width: double.infinity,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Column(
  //                 children: [
  //                   if (_isEditingFather) ...[
  //                     _buildEditableFieldInline(
  //                       'First Name',
  //                       _fatherData['firstName'],
  //                       (value) {
  //                         _fatherData['firstName'] = value;
  //                       },
  //                     ),
  //                     const SizedBox(height: 12),
  //                     _buildEditableFieldInline(
  //                       'Middle Name',
  //                       _fatherData['middleName'],
  //                       (value) {
  //                         _fatherData['middleName'] = value;
  //                       },
  //                     ),
  //                     const SizedBox(height: 12),
  //                     _buildEditableFieldInline(
  //                       'Last Name',
  //                       _fatherData['lastName'],
  //                       (value) {
  //                         _fatherData['lastName'] = value;
  //                       },
  //                     ),
  //                     const SizedBox(height: 12),
  //                     _buildEditableFieldInline(
  //                       'Name Extension',
  //                       _fatherData['nameExtension'],
  //                       (value) {
  //                         _fatherData['nameExtension'] = value;
  //                       },
  //                     ),
  //                   ] else
  //                     _buildInfoFieldInline(
  //                       'Name',
  //                       [
  //                             _fatherData['firstName'],
  //                             _fatherData['middleName'],
  //                             _fatherData['lastName'],
  //                             _fatherData['nameExtension'],
  //                           ]
  //                           .where(
  //                             (v) =>
  //                                 v != null && v.toString().trim().isNotEmpty,
  //                           )
  //                           .join(' '),
  //                     ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  // }

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
              )
            // Show 3-dot menu when father record exists or currently editing
            else if (hasFather || _isEditingFather)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    if (_isEditingFather) {
                      _saveFather();
                    } else {
                      setState(() => _isEditingFather = true);
                    }
                  }  else if (value == 'cancel') {
                    setState(() => _isEditingFather = false);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(_isEditingFather ? Icons.check : Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(_isEditingFather ? 'Save' : 'Edit'),
                      ],
                    ),
                  ),
                  
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18),
                        SizedBox(width: 8),
                        Text('Cancel'),
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
              )
            // Show Edit button when mother record exists or currently adding
            else if (hasMother || _isEditingMother)
              // IconButton(
              //   icon: Icon(
              //     _isEditingMother ? Icons.check : Icons.edit,
              //     size: 20,
              //     color: Colors.black,
              //   ),
              //   onPressed: () {
              //     if (_isEditingMother) {
              //       _saveMother();
              //     } else {
              //       setState(() => _isEditingMother = true);
              //     }
              //   },
              //   padding: EdgeInsets.zero,
              //   constraints: const BoxConstraints(),
              // ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    if (_isEditingMother) {
                      _saveMother();
                    } else {
                      setState(() => _isEditingMother = true);
                    }
                  }  else if (value == 'cancel') {
                    setState(() => _isEditingMother = false);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(_isEditingMother ? Icons.check : Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(_isEditingMother ? 'Save' : 'Edit'),
                      ],
                    ),
                  ),
                  
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18),
                        SizedBox(width: 8),
                        Text('Cancel'),
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
                const SizedBox(height: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEducationalBackgroundCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
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
                    'EDUCATIONAL BACKGROUND',
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
                            bool isCollapsed = _collapsedEducationIndexes.contains(index);

                            return Container(
                              // margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Clickable title row — toggles collapse/expand
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isCollapsed) {
                                          _collapsedEducationIndexes.remove(index);
                                        } else {
                                          _collapsedEducationIndexes.add(index);
                                        }
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: isEditing
                                              ? DropdownButtonFormField<String>(
                                                  value: education['level'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Education Level',
                                                    labelStyle: TextStyle(fontSize: 12),
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
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
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      education['level'] ?? 'N/A',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (isCollapsed)
                                                      Text(
                                                        education['schoolName'] ?? 'N/A',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                        ),
                                        // Only show expand/collapse arrow icon
                                        Icon(
                                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                                          size: 20,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Collapsible content + edit/delete at bottom
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // School Name
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'School Name',
                                                  education['schoolName'],
                                                  (value) { _educationData[index]['schoolName'] = value; },
                                                )
                                              : _buildInfoFieldInline('School Name', education['schoolName']),
                                          const SizedBox(height: 12),

                                          // Degree/Course
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'Degree/Course',
                                                  education['degreeCourse'],
                                                  (value) { _educationData[index]['degreeCourse'] = value; },
                                                )
                                              : _buildInfoFieldInline('Degree/Course', education['degreeCourse']),
                                          const SizedBox(height: 12),

                                          // Period Attended - From/To
                                          Row(
                                            children: [
                                              Expanded(
                                                child: isEditing
                                                    ? _buildDateFieldInline(
                                                        'From',
                                                        education['attendedFrom'],
                                                        (value) { _educationData[index]['attendedFrom'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('From', education['attendedFrom']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: isEditing
                                                    ? _buildDateFieldInline(
                                                        'To',
                                                        education['attendedTo'],
                                                        (value) { _educationData[index]['attendedTo'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('To', education['attendedTo']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Highest Level/Units & Year Graduated
                                          Row(
                                            children: [
                                              Expanded(
                                                child: isEditing
                                                    ? _buildEditableFieldInline(
                                                        'Highest Level/Units',
                                                        education['highestLevel'],
                                                        (value) { _educationData[index]['highestLevel'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('Highest Level/Units', education['highestLevel']),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: isEditing
                                                    ? _buildEditableFieldInline(
                                                        'Year Graduated',
                                                        education['yearGraduated'],
                                                        (value) { _educationData[index]['yearGraduated'] = value; },
                                                      )
                                                    : _buildInfoFieldInline('Year Graduated', education['yearGraduated']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Academic Honors
                                          isEditing
                                              ? _buildEditableFieldInline(
                                                  'Academic Honors',
                                                  education['academicHonors'],
                                                  (value) { _educationData[index]['academicHonors'] = value; },
                                                )
                                              : _buildInfoFieldInline('Academic Honors', education['academicHonors']),


                                          // Edit and Delete buttons — bottom right after details
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (isEditing) {
                                                    _saveEducation(index);
                                                  } else {
                                                    setState(() {
                                                      _editingEducationIndex = index;
                                                    });
                                                  }
                                                },
                                                child: Icon(
                                                  isEditing ? Icons.check : Icons.edit,
                                                  size: 20,
                                                  color: Color.fromARGB(255, 0, 0, 0),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () => _deleteEducation(index),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Color.fromARGB(255, 0, 0, 0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ], // End of collapsible content
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                ),
              ),
            ),
          // Add Button
          if (_isEducationalBackgroundExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 28,
                  color: Color(0xFF2C5F4F),
                ),
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
                tooltip: 'Add Education',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  // Civil Service Eligibility Section
   Widget _buildCivilServiceCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
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
                                'No civil service records found.\nClick + to add.',
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
                          ..._civilServiceData.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> service = entry.value;
                            bool isEditing = _editingCivilServiceIndex == index;
                            bool isCollapsed = _collapsedCivilServiceIndexes.contains(index);

                            // Helper to get display label from value
                            String eligibilityLabel(String? val) {
                              const map = {
                                'CSE': 'Career Service Eligibility',
                                'RA1080': 'RA 1080 (Board/Bar) Under Special Laws',
                                'CES': 'Career Executive Service',
                                'CSEE': 'Career Service Executive Examination',
                                'BE': 'Barangay Eligibility',
                                'DL': 'Driver\'s License',
                                'OTHERS': 'Others',
                              };
                              return map[val] ?? val ?? 'N/A';
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Clickable title row — toggles collapse/expand
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isCollapsed) {
                                          _collapsedCivilServiceIndexes.remove(index);
                                        } else {
                                          _collapsedCivilServiceIndexes.add(index);
                                        }
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: isEditing
                                              ? DropdownButtonFormField<String>(
                                                  value: service['serviceEligibility'],
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    labelText: 'Eligibility Type',
                                                    labelStyle: TextStyle(fontSize: 12),
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  items: [
                                                    {'value': 'CSE', 'label': 'Career Service Eligibility'},
                                                    {'value': 'RA1080', 'label': 'RA 1080 (Board/Bar) Under Special Laws'},
                                                    {'value': 'CES', 'label': 'Career Executive Service'},
                                                    {'value': 'CSEE', 'label': 'Career Service Executive Examination'},
                                                    {'value': 'BE', 'label': 'Barangay Eligibility'},
                                                    {'value': 'DL', 'label': 'Driver\'s License'},
                                                    {'value': 'OTHERS', 'label': 'Others'},
                                                  ].map((item) {
                                                    return DropdownMenuItem(
                                                      value: item['value'],
                                                      child: Text(item['label']!, style: TextStyle(fontSize: 12)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _civilServiceData[index]['serviceEligibility'] = value!;
                                                    });
                                                  },
                                                )
                                              : Text(
                                                  eligibilityLabel(service['serviceEligibility']),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                        // Only expand/collapse arrow
                                        Icon(
                                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Collapsible content + edit/delete at bottom
                                  if (!isCollapsed) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Rating
                                          isEditing
                                              ? _buildEditableFieldInline('Rating', service['rating'], (value) { service['rating'] = value; })
                                              : _buildInfoFieldInline('Rating', service['rating']),
                                          const SizedBox(height: 10),

                                          // Date of Exam
                                          isEditing
                                              ? _buildDateFieldInline('Date of Exam', service['examDate'], (value) { service['examDate'] = value; })
                                              : _buildInfoFieldInline('Date of Exam', service['examDate']),
                                          const SizedBox(height: 10),

                                          // Place of Exam
                                          isEditing
                                              ? _buildEditableFieldInline('Place of Exam', service['examPlace'], (value) { service['examPlace'] = value; })
                                              : _buildInfoFieldInline('Place of Exam', service['examPlace']),
                                          const SizedBox(height: 10),

                                          // License Number
                                          isEditing
                                              ? _buildEditableFieldInline('License Number', service['licenseNo'], (value) { service['licenseNo'] = value; })
                                              : _buildInfoFieldInline('License Number', service['licenseNo']),

                                       

                                          // Edit and Delete buttons — bottom right after details
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (isEditing) {
                                                    _saveCivilServiceEligibility(index);
                                                  } else {
                                                    setState(() {
                                                      _editingCivilServiceIndex = index;
                                                    });
                                                  }
                                                },
                                                child: Icon(
                                                  isEditing ? Icons.check : Icons.edit,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () => _deleteCivilServiceEligibility(index),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ], // End collapsible content
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                ),
              ),
            ),
            // Add Button
          if (_isCivilServiceExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 28,
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
                tooltip: 'Add Education',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

        ],
      ),
    );
  }

Widget _buildWorkExperienceCard() {
  return Container(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        // Header
        InkWell(
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
                              'No work experience records found.\nClick + to add work experience.',
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
                        ..._workExperienceData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> work = entry.value;
                          bool isEditing = _editingWorkExperienceIndex == index;
                          bool isCollapsed = _collapsedWorkExperienceIndexes.contains(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clickable title row — toggles collapse/expand
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isCollapsed) {
                                        _collapsedWorkExperienceIndexes.remove(index);
                                      } else {
                                        _collapsedWorkExperienceIndexes.add(index);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: isEditing
                                            ? _buildEditableFieldInline(
                                                'Position Title',
                                                work['position'],
                                                (value) {
                                                  _workExperienceData[index]['position'] = value;
                                                },
                                              )
                                            : Text(
                                                work['position'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                      // Only expand/collapse arrow
                                      Icon(
                                        isCollapsed ? Icons.expand_more : Icons.expand_less,
                                        size: 20,
                                        color: Color(0xFF2C5F4F),
                                      ),
                                    ],
                                  ),
                                ),

                                // Collapsible content + edit/delete at bottom
                                if (!isCollapsed) ...[
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date From and Date To
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('From', work['dateFrom'], (value) { _workExperienceData[index]['dateFrom'] = value; })
                                                  : _buildInfoFieldInline('From', work['dateFrom']),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('To', work['dateTo'], (value) { _workExperienceData[index]['dateTo'] = value; })
                                                  : _buildInfoFieldInline('To', work['dateTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Department / Agency / Office / Company
                                        isEditing
                                            ? _buildEditableFieldInline('Department / Agency / Office / Company', work['company'], (value) { _workExperienceData[index]['company'] = value; })
                                            : _buildInfoFieldInline('Department / Agency / Office / Company', work['company']),
                                        const SizedBox(height: 12),

                                        // Status of Appointment
                                        isEditing
                                            ? _buildEditableFieldInline('Status of Appointment', work['appointmentStatus'], (value) { _workExperienceData[index]['appointmentStatus'] = value; })
                                            : _buildInfoFieldInline('Status of Appointment', work['appointmentStatus']),
                                        const SizedBox(height: 12),

                                        // Government Service
                                        isEditing
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Government Service',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  DropdownButtonFormField<String>(
                                                    value: work['govtService']?.toString().toUpperCase() == 'TRUE' ||
                                                            work['govtService']?.toString().toUpperCase() == 'YES'
                                                        ? 'Yes'
                                                        : work['govtService']?.toString().toUpperCase() == 'FALSE' ||
                                                                work['govtService']?.toString().toUpperCase() == 'NO'
                                                            ? 'No'
                                                            : null,
                                                    decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      border: UnderlineInputBorder(),
                                                    ),
                                                    items: ['Yes', 'No'].map((value) {
                                                      return DropdownMenuItem(
                                                        value: value,
                                                        child: Text(value, style: TextStyle(fontSize: 13)),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _workExperienceData[index]['govtService'] = value;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            : _buildInfoFieldInline('Government Service', work['govtService']),

                                        const SizedBox(height: 16),

                                        // Edit and Delete buttons — bottom right after details
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (isEditing) {
                                                  _saveWorkExperience(index);
                                                } else {
                                                  setState(() {
                                                    _editingWorkExperienceIndex = index;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                isEditing ? Icons.check : Icons.edit,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => _deleteWorkExperience(index),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ], // End collapsible content
                              ],
                            ),
                          );
                        }).toList(),
                      ],
              ),
            ),
          ),
           // Add Button
          if (_isWorkExperienceExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 28,
                  color: Color(0xFF2C5F4F),
                ),
                onPressed: () {
                  setState(() {
                    _workExperienceData.add({
                            'dateFrom': '',
                            'dateTo': '',
                            'position': '',
                            'company': '',
                            'appointmentStatus': '',
                            'govtService': '',
                    });
                    _editingWorkExperienceIndex = _workExperienceData.length - 1;
                  });
                },
                tooltip: 'Add Education',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
      ],
    ),
  );
}


  // Voluntary Work Section
  Widget _buildVoluntaryWorkCard() {
  return Container(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        // Header
        InkWell(
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
                              'No voluntary work records found.\nClick + to add voluntary work.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ]
                    : [
                        ..._voluntaryWorkData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> voluntary = entry.value;
                          bool isEditing = _editingVoluntaryWorkIndex == index;
                          bool isCollapsed = _collapsedVoluntaryWorkIndexes.contains(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clickable title row — toggles collapse/expand
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isCollapsed) {
                                        _collapsedVoluntaryWorkIndexes.remove(index);
                                      } else {
                                        _collapsedVoluntaryWorkIndexes.add(index);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: isEditing
                                            ? _buildEditableFieldInline(
                                                'Name of Organization',
                                                voluntary['organization'],
                                                (value) { _voluntaryWorkData[index]['organization'] = value; },
                                              )
                                            : Text(
                                                voluntary['organization'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                      Icon(
                                        isCollapsed ? Icons.expand_more : Icons.expand_less,
                                        size: 20,
                                        color: Color(0xFF2C5F4F),
                                      ),
                                    ],
                                  ),
                                ),

                                // Collapsible content + edit/delete at bottom
                                if (!isCollapsed) ...[
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date From and Date To
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('From', voluntary['dateFrom'], (value) { _voluntaryWorkData[index]['dateFrom'] = value; })
                                                  : _buildInfoFieldInline('Date From', voluntary['dateFrom']),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('To', voluntary['dateTo'], (value) { _voluntaryWorkData[index]['dateTo'] = value; })
                                                  : _buildInfoFieldInline('Date To', voluntary['dateTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Number of Hours
                                        isEditing
                                            ? _buildEditableFieldInline('Number of Hours', voluntary['hours'], (value) { _voluntaryWorkData[index]['hours'] = value; })
                                            : _buildInfoFieldInline('Number of Hours', voluntary['hours']),
                                        const SizedBox(height: 12),

                                        // Position / Nature of Work
                                        isEditing
                                            ? _buildEditableFieldInline('Position / Nature of Work', voluntary['work'], (value) { _voluntaryWorkData[index]['work'] = value; })
                                            : _buildInfoFieldInline('Position / Nature of Work', voluntary['work']),

                                        const SizedBox(height: 16),

                                        // Edit and Delete — bottom right
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (isEditing) {
                                                  _saveVoluntaryWork(index);
                                                } else {
                                                  setState(() {
                                                    _editingVoluntaryWorkIndex = index;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                isEditing ? Icons.check : Icons.edit,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => _deleteVoluntaryWork(index),
                                              child: const Icon(Icons.delete, size: 20, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ], // End collapsible content
                              ],
                            ),
                          );
                        }).toList(),
                      ],
              ),
            ),
          ),
          if (_isVoluntaryWorkExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 28,
                  color: Color(0xFF2C5F4F),
                ),
                onPressed: () {
                  setState(() {
                     _voluntaryWorkData.add({
                            'organization': '',
                            'dateFrom': '',
                            'dateTo': '',
                            'hours': '',
                            'work': '',
                          });
                    _editingVoluntaryWorkIndex = _voluntaryWorkData.length - 1;
                  });
                },
                tooltip: 'Add Education',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
      ],
    ),
  );
}

  // Learning and Development Section
Widget _buildLearningDevelopmentCard() {
  return Container(
    padding: EdgeInsets.zero,
   
    child: Column(
      children: [
        InkWell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2C5F4F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                              'No training records found.\nClick + to add.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ),
                      ]
                    : [
                        ..._learningDevelopmentData.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Map<String, dynamic> training = entry.value;
                          final bool isEditing = _editingLearningDevelopmentIndex == index;
                          bool isCollapsed = _collapsedLearningDevIndexes.contains(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clickable title row — toggles collapse/expand
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isCollapsed) {
                                        _collapsedLearningDevIndexes.remove(index);
                                      } else {
                                        _collapsedLearningDevIndexes.add(index);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: isEditing
                                            ? _buildEditableFieldInline(
                                                'Training Programs',
                                                training['title'],
                                                (value) { _learningDevelopmentData[index]['title'] = value; },
                                              )
                                            : Text(
                                                training['title'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                      Icon(
                                        isCollapsed ? Icons.expand_more : Icons.expand_less,
                                        size: 20,
                                        color: Color(0xFF2C5F4F),
                                      ),
                                    ],
                                  ),
                                ),

                                // Collapsible content + edit/delete at bottom
                                if (!isCollapsed) ...[
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date From / Date To
                                        Row(
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('Date From', training['attendedFrom'], (value) { setState(() { _learningDevelopmentData[index]['attendedFrom'] = value; }); })
                                                  : _buildInfoFieldInline('Date From', training['attendedFrom']),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildDateFieldInline('Date To', training['attendedTo'], (value) { setState(() { _learningDevelopmentData[index]['attendedTo'] = value; }); })
                                                  : _buildInfoFieldInline('Date To', training['attendedTo']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Number of Hours / Type of L&D
                                        Row(
                                          children: [
                                            Expanded(
                                              child: isEditing
                                                  ? _buildEditableFieldInline('Number of Hours', training['hours'], (value) { setState(() { _learningDevelopmentData[index]['hours'] = value; }); })
                                                  : _buildInfoFieldInline('Number of Hours', training['hours']),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: isEditing
                                                  ? _buildEditableFieldInline('Type of L&D', training['ldType'], (value) { setState(() { _learningDevelopmentData[index]['ldType'] = value; }); })
                                                  : _buildInfoFieldInline('Type of L&D', training['ldType']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Conducted / Sponsored By
                                        isEditing
                                            ? _buildEditableFieldInline('Conducted / Sponsored By', training['conductedBy'], (value) { setState(() { _learningDevelopmentData[index]['conductedBy'] = value; }); })
                                            : _buildInfoFieldInline('Conducted / Sponsored By', training['conductedBy']),

                                        const SizedBox(height: 16),

                                        // Edit and Delete — bottom right
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (isEditing) {
                                                  _saveLearningDevelopment(index);
                                                } else {
                                                  setState(() {
                                                    _editingLearningDevelopmentIndex = index;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                isEditing ? Icons.check : Icons.edit,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => _deleteLearningDevelopment(index),
                                              child: const Icon(Icons.delete, size: 20, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ], // End collapsible content
                              ],
                            ),
                          );
                        }).toList(),
                      ],
              ),
            ),
          ),
        if (_isLearningDevelopmentExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, size: 28, color: Color(0xFF2C5F4F)),
                onPressed: () {
                  setState(() {
                     _learningDevelopmentData.add({
                            'title': '',
                            'attendedFrom': '',
                            'attendedTo': '',
                            'hours': '',
                            'ldType': '',
                            'conductedBy': '',
                            'certificate_url': '',
                          });
                   _editingLearningDevelopmentIndex = _learningDevelopmentData.length - 1;
                  });
                },
                tooltip: 'Add Training Program',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

      ],
    ),
  );
}



// Widget _buildOtherInformationCard() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Header ──────────────────────────────────────────────
//           InkWell(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: const BoxDecoration(
//                 color: Color(0xFF2C5F4F),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(8),
//                   topRight: Radius.circular(8),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'OTHER INFORMATION',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   if (_isFetchingOtherInfo)
//                     const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Body ─────────────────────────────────────────────────
//           if (_isOtherInformationExpanded)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Global Save / Edit / Cancel row ──────────────
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       if (_isEditingOtherInfo) ...[
//                         TextButton(
//                           onPressed: () {
//                             // Cancel: re-parse from the cached record
//                             setState(() {
//                               _parseOtherInfoData();
//                               _isEditingOtherInfo = false;
//                               _editingSpecialSkillIndex = null;
//                               _editingNonAcademicDistinctionIndex = null;
//                               _editingMembershipIndex = null;
//                             });
//                           },
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton.icon(
//                           onPressed: _saveOtherInfo,
//                           icon: const Icon(Icons.save, size: 16),
//                           label: const Text('Save'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2C5F4F),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             textStyle: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ] else
//                         IconButton(
//                           icon: const Icon(
//                             Icons.edit,
//                             size: 20,
//                             color: Color(0xFF2C5F4F),
//                           ),
//                           tooltip: 'Edit Other Information',
//                           onPressed: () =>
//                               setState(() => _isEditingOtherInfo = true),
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // ── Special Skills and Hobbies ────────────────────
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Special Skills and Hobbies',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color.fromARGB(255, 97, 97, 97),
//                         ),
//                       ),
//                       if (_isEditingOtherInfo)
//                         Row(
//                           children: [
//                             const SizedBox(width: 8),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.add,
//                                 size: 20,
//                                 color: Color(0xFF2C5F4F),
//                               ),
//                               onPressed: _showAddOtherInfoDialog,
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),

//                   if (_specialSkillsData.isEmpty && !_isEditingOtherInfo)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Text(
//                         'No skills added yet.',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[500],
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),

//                   ..._specialSkillsData.asMap().entries.map((entry) {
//                     final int index = entry.key;
//                     final Map<String, dynamic> skill = entry.value;
//                     final bool isEditing = _editingSpecialSkillIndex == index;

//                     return Container(
//                       padding: const EdgeInsets.only(left: 10),
//                       decoration: const BoxDecoration(color: Colors.white),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: isEditing
//                                 ? _buildEditableFieldInline(
//                                     '',
//                                     skill['skill'],
//                                     (value) =>
//                                         _specialSkillsData[index]['skill'] =
//                                             value,
//                                   )
//                                 : _buildInfoFieldInline('', skill['skill']),
//                           ),
//                           // const SizedBox(width: 8),
//                           if (_isEditingOtherInfo) ...[
//                             IconButton(
//                               icon: Icon(
//                                 isEditing ? Icons.check : Icons.edit,
//                                 size: 18,
//                                 color: const Color(0xFF2C5F4F),
//                               ),
//                               onPressed: () => setState(() {
//                                 _editingSpecialSkillIndex = isEditing
//                                     ? null
//                                     : index;
//                               }),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete,
//                                 size: 18,
//                                 color: Colors.red,
//                               ),
//                               onPressed: () async {
//                                 final recordId = skill['_recordId']?.toString();
//                                 if (recordId == null) {
//                                   setState(() {
//                                     _specialSkillsData.removeAt(index);
//                                     if (_editingSpecialSkillIndex == index) _editingSpecialSkillIndex = null;
//                                   });
//                                   return;
//                                 }
//                                 final response = await _userService.deleteOtherInfo(widget.token, recordId);
//                                 if (response['success']) {
//                                   await _fetchOtherInfoData();
//                                 } else {
//                                   if (mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('Failed to delete: ${response['error']}'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 }
//                               },
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ],
//                       ),
//                     );
//                   }).toList(),

//                   const SizedBox(height: 30),

//                   // ── Non-Academic Distinctions ─────────────────────
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Non-Academic Distinctions /\nRecognition',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color.fromARGB(255, 97, 97, 97),
//                         ),
//                       ),
//                       if (_isEditingOtherInfo)
//                         const Row(
//                           children: [
//                             SizedBox(width: 28), // Space for alignment
//                           ],
//                         ),
//                     ],
//                   ),

//                   if (_nonAcademicDistinctionsData.isEmpty &&
//                       !_isEditingOtherInfo)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Text(
//                         'No distinctions added yet.',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[500],
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),

//                   ..._nonAcademicDistinctionsData.asMap().entries.map((entry) {
//                     final int index = entry.key;
//                     final Map<String, dynamic> distinction = entry.value;
//                     final bool isEditing =
//                         _editingNonAcademicDistinctionIndex == index;

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       padding: const EdgeInsets.only(left: 10),
//                       decoration: const BoxDecoration(color: Colors.white),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: isEditing
//                                 ? _buildEditableFieldInline(
//                                     '',
//                                     distinction['distinction'],
//                                     (value) =>
//                                         _nonAcademicDistinctionsData[index]['distinction'] =
//                                             value,
//                                   )
//                                 : _buildInfoFieldInline(
//                                     '',
//                                     distinction['distinction'],
//                                   ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (_isEditingOtherInfo) ...[
//                             IconButton(
//                               icon: Icon(
//                                 isEditing ? Icons.check : Icons.edit,
//                                 size: 18,
//                                 color: const Color(0xFF2C5F4F),
//                               ),
//                               onPressed: () => setState(() {
//                                 _editingNonAcademicDistinctionIndex = isEditing
//                                     ? null
//                                     : index;
//                               }),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete,
//                                 size: 18,
//                                 color: Colors.red,
//                               ),
//                               onPressed: () async {
//                                 final recordId = distinction['_recordId']?.toString();
//                                 if (recordId == null) {
//                                   setState(() {
//                                     _nonAcademicDistinctionsData.removeAt(index);
//                                     if (_editingNonAcademicDistinctionIndex == index) {
//                                       _editingNonAcademicDistinctionIndex = null;
//                                     }
//                                   });
//                                   return;
//                                 }
//                                 final response = await _userService.deleteOtherInfo(widget.token, recordId);
//                                 if (response['success']) {
//                                   await _fetchOtherInfoData();
//                                 } else {
//                                   if (mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('Failed to delete: ${response['error']}'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 }
//                               },
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ],
//                       ),
//                     );
//                   }).toList(),

//                   const SizedBox(height: 30),

//                   // ── Membership in Association / Organization ──────
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Membership in Association /\nOrganization',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color.fromARGB(255, 97, 97, 97),
//                         ),
//                       ),
//                       if (_isEditingOtherInfo)
//                         const Row(
//                           children: [
                            
//                             SizedBox(width: 28), // Space for alignment
//                           ],
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   if (_membershipData.isEmpty && !_isEditingOtherInfo)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Text(
//                         'No memberships added yet.',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[500],
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),

//                   ..._membershipData.asMap().entries.map((entry) {
//                     final int index = entry.key;
//                     final Map<String, dynamic> membership = entry.value;
//                     final bool isEditing = _editingMembershipIndex == index;

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       padding: const EdgeInsets.only(left: 10),
//                       decoration: const BoxDecoration(color: Colors.white),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: isEditing
//                                 ? _buildEditableFieldInline(
//                                     '',
//                                     membership['organization'],
//                                     (value) =>
//                                         _membershipData[index]['organization'] =
//                                             value,
//                                   )
//                                 : _buildInfoFieldInline(
//                                     '',
//                                     membership['organization'],
//                                   ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (_isEditingOtherInfo) ...[
//                             IconButton(
//                               icon: Icon(
//                                 isEditing ? Icons.check : Icons.edit,
//                                 size: 18,
//                                 color: const Color(0xFF2C5F4F),
//                               ),
//                               onPressed: () => setState(() {
//                                 _editingMembershipIndex = isEditing
//                                     ? null
//                                     : index;
//                               }),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete,
//                                 size: 18,
//                                 color: Colors.red,
//                               ),
//                               onPressed: () async {
//                                 final recordId = membership['_recordId']?.toString();
//                                 if (recordId == null) {
//                                   setState(() {
//                                     _membershipData.removeAt(index);
//                                     if (_editingMembershipIndex == index) _editingMembershipIndex = null;
//                                   });
//                                   return;
//                                 }
//                                 final response = await _userService.deleteOtherInfo(widget.token, recordId);
//                                 if (response['success']) {
//                                   await _fetchOtherInfoData();
//                                 } else {
//                                   if (mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('Failed to delete: ${response['error']}'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 }
//                               },
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Add this new method for the dialog
//   void _showAddOtherInfoDialog() {
//     final TextEditingController skillController = TextEditingController();
//     final TextEditingController distinctionController = TextEditingController();
//     final TextEditingController membershipController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             // Check which fields have text
//             bool hasSkillText = skillController.text.isNotEmpty;
//             bool hasDistinctionText = distinctionController.text.isNotEmpty;
//             bool hasMembershipText = membershipController.text.isNotEmpty;

//             return AlertDialog(
//               title: const Text(
//                 'Add Other Information',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C5F4F),
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Fill in only ONE field below:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Special Skills Field
//                     TextField(
//                       controller: skillController,
//                       enabled: !hasDistinctionText && !hasMembershipText,
//                       decoration: InputDecoration(
//                         labelText: 'Special Skill/Hobby',
//                         labelStyle: TextStyle(
//                           fontSize: 14,
//                           color: (!hasDistinctionText && !hasMembershipText)
//                               ? Colors.black
//                               : Colors.grey,
//                         ),
//                         border: const OutlineInputBorder(),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                       ),
//                       onChanged: (value) => setDialogState(() {}),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Non-Academic Distinction Field
//                     TextField(
//                       controller: distinctionController,
//                       enabled: !hasSkillText && !hasMembershipText,
//                       decoration: InputDecoration(
//                         labelText: 'Non-Academic Distinction/Recognition',
//                         labelStyle: TextStyle(
//                           fontSize: 14,
//                           color: (!hasSkillText && !hasMembershipText)
//                               ? Colors.black
//                               : Colors.grey,
//                         ),
//                         border: const OutlineInputBorder(),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                       ),
//                       onChanged: (value) => setDialogState(() {}),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Membership Field
//                     TextField(
//                       controller: membershipController,
//                       enabled: !hasSkillText && !hasDistinctionText,
//                       decoration: InputDecoration(
//                         labelText: 'Membership in Association/Organization',
//                         labelStyle: TextStyle(
//                           fontSize: 14,
//                           color: (!hasSkillText && !hasDistinctionText)
//                               ? Colors.black
//                               : Colors.grey,
//                         ),
//                         border: const OutlineInputBorder(),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                       ),
//                       onChanged: (value) => setDialogState(() {}),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Add to the appropriate list based on which field has text
//                     if (skillController.text.isNotEmpty) {
//                       setState(() {
//                         _specialSkillsData.add({'skill': skillController.text});
//                         _editingSpecialSkillIndex = _specialSkillsData.length - 1;
//                       });
//                     } else if (distinctionController.text.isNotEmpty) {
//                       setState(() {
//                         _nonAcademicDistinctionsData.add({
//                           'distinction': distinctionController.text
//                         });
//                         _editingNonAcademicDistinctionIndex =
//                             _nonAcademicDistinctionsData.length - 1;
//                       });
//                     } else if (membershipController.text.isNotEmpty) {
//                       setState(() {
//                         _membershipData.add({
//                           'organization': membershipController.text
//                         });
//                         _editingMembershipIndex = _membershipData.length - 1;
//                       });
//                     }
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2C5F4F),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Add'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

Widget _buildOtherInformationCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
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
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    if (!_isFetchingOtherInfo) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          size: 22,
                          color: Colors.white,
                        ),
                        tooltip: 'Add',
                        onPressed: _showAddOtherInfoDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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
                                ? _buildEditableFieldInline(
                                    '',
                                    skill['skill'],
                                    (value) =>
                                        _specialSkillsData[index]['skill'] =
                                            value,
                                  )
                                : _buildInfoFieldInline('', skill['skill']),
                          ),
                          IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              if (isEditing || _isEditingOtherInfo) {
                                // Save to backend when clicking check icon
                                await _saveOtherInfo();
                              }
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
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                final recordId = skill['_recordId']?.toString();
                                if (recordId == null) {
                                  setState(() {
                                    _specialSkillsData.removeAt(index);
                                    if (_editingSpecialSkillIndex == index) _editingSpecialSkillIndex = null;
                                  });
                                  return;
                                }
                                final response = await _userService.deleteOtherInfo(widget.token, recordId);
                                if (response['success']) {
                                  await _fetchOtherInfoData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Skill deleted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: ${response['error']}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
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
                          Expanded(
                            child: isEditing
                                ? _buildEditableFieldInline(
                                    '',
                                    distinction['distinction'],
                                    (value) =>
                                        _nonAcademicDistinctionsData[index]['distinction'] =
                                            value,
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    distinction['distinction'],
                                  ),
                          ),
                          IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              if (isEditing) {
                                // Save to backend when clicking check icon
                                await _saveOtherInfo();
                              }
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
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                final recordId = distinction['_recordId']?.toString();
                                if (recordId == null) {
                                  setState(() {
                                    _nonAcademicDistinctionsData.removeAt(index);
                                    if (_editingNonAcademicDistinctionIndex == index) _editingNonAcademicDistinctionIndex = null;
                                  });
                                  return;
                                }
                                final response = await _userService.deleteOtherInfo(widget.token, recordId);
                                if (response['success']) {
                                  await _fetchOtherInfoData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Distinction deleted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: ${response['error']}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
                          Expanded(
                            child: isEditing
                                ? _buildEditableFieldInline(
                                    '',
                                    membership['organization'],
                                    (value) =>
                                        _membershipData[index]['organization'] =
                                            value,
                                  )
                                : _buildInfoFieldInline(
                                    '',
                                    membership['organization'],
                                  ),
                          ),
                           Container(
                             margin: const EdgeInsets.only(bottom: 2),
                             child: IconButton(
                              icon: Icon(
                                isEditing ? Icons.check : Icons.edit,
                                size: 18,
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                if (isEditing) {
                                  // Save to backend when clicking check icon
                                  await _saveOtherInfo();
                                }
                                setState(() {
                                  _editingMembershipIndex = isEditing
                                      ? null
                                      : index;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                                                       ),
                           ),
                          IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                final recordId = membership['_recordId']?.toString();
                                if (recordId == null) {
                                  setState(() {
                                    _membershipData.removeAt(index);
                                    if (_editingMembershipIndex == index) _editingMembershipIndex = null;
                                  });
                                  return;
                                }
                                final response = await _userService.deleteOtherInfo(widget.token, recordId);
                                if (response['success']) {
                                  await _fetchOtherInfoData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Membership deleted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: ${response['error']}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
            // Check which fields have text
            bool hasSkillText = skillController.text.isNotEmpty;
            bool hasDistinctionText = distinctionController.text.isNotEmpty;
            bool hasMembershipText = membershipController.text.isNotEmpty;

            return AlertDialog(
              title: const Text(
                'Add Other Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F4F),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fill in only ONE field below:',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Special Skills Field
                    TextField(
                      controller: skillController,
                      enabled: !hasDistinctionText && !hasMembershipText,
                      decoration: InputDecoration(
                        labelText: 'Special Skill/Hobby',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: (!hasDistinctionText && !hasMembershipText)
                              ? Colors.black
                              : Colors.grey,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    
                    // Non-Academic Distinction Field
                    TextField(
                      controller: distinctionController,
                      enabled: !hasSkillText && !hasMembershipText,
                      decoration: InputDecoration(
                        labelText: 'Non-Academic Distinction/Recognition',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: (!hasSkillText && !hasMembershipText)
                              ? Colors.black
                              : Colors.grey,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    
                    // Membership Field
                    TextField(
                      controller: membershipController,
                      enabled: !hasSkillText && !hasDistinctionText,
                      decoration: InputDecoration(
                        labelText: 'Membership in Association/Organization',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: (!hasSkillText && !hasDistinctionText)
                              ? Colors.black
                              : Colors.grey,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) => setDialogState(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add to the appropriate list based on which field has text
                    if (skillController.text.isNotEmpty) {
                      setState(() {
                        _specialSkillsData.add({'skill': skillController.text});
                        _editingSpecialSkillIndex = null;
                      });
                    } else if (distinctionController.text.isNotEmpty) {
                      setState(() {
                        _nonAcademicDistinctionsData.add({
                          'distinction': distinctionController.text
                        });
                        _editingNonAcademicDistinctionIndex =
                            null;
                      });
                    } else if (membershipController.text.isNotEmpty) {
                      setState(() {
                        _membershipData.add({
                          'organization': membershipController.text
                        });
                        _editingMembershipIndex = null;
                      });
                    }
                    
                    Navigator.of(context).pop();
                    _saveOtherInfo();  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5F4F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPersonReferenceCard() {
    final bool hasRecord =
        _personRefData.containsKey('id') && _personRefData['id'] != null;

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──────────────────────────────────────────
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
                const Text(
                  'REFERENCES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_isFetchingPersonRef)
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Action buttons row ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ADD button — only when no record exists and not editing
                    if (!hasRecord && !_isEditingPersonRef)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _personRefData = {
                            'refName': '',
                            'refAddress': '',
                            'refTelephone': '',
                          };
                          _isEditingPersonRef = true;
                        }),
                        icon: const Icon(
                          Icons.add_circle,
                          size: 20,
                          color: Color(0xFF2C5F4F),
                        ),
                        label: const Text(
                          'Add Reference',
                          style: TextStyle(
                            color: Color(0xFF2C5F4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),

                    // CANCEL + SAVE — while editing
                    if (_isEditingPersonRef) ...[
                      TextButton(
                        onPressed: () {
                          _fetchPersonReferenceData(); // revert to last saved
                          setState(() => _isEditingPersonRef = false);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _savePersonReference,
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

                    // EDIT + DELETE — when record exists and not editing
                    if (hasRecord && !_isEditingPersonRef) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                        tooltip: 'Edit',
                        onPressed: () =>
                            setState(() => _isEditingPersonRef = true),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.black,
                        ),
                        tooltip: 'Delete',
                        onPressed: _deletePersonReference,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // ── Empty state ────────────────────────────────────
                if (!hasRecord && !_isEditingPersonRef)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No reference information added yet.\nTap "Add Reference" to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Fields (view or edit) ──────────────────────────
                if (hasRecord || _isEditingPersonRef) ...[
                  // Reference Name
                  _isEditingPersonRef
                      ? _buildEditableFieldInline(
                          'Reference Name',
                          _personRefData['refName'],
                          (v) {
                            _personRefData['refName'] = v;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Reference Name',
                          _personRefData['refName'],
                        ),

                  const SizedBox(height: 16),

                  // Address
                  _isEditingPersonRef
                      ? _buildEditableFieldInline(
                          'Address',
                          _personRefData['refAddress'],
                          (v) {
                            _personRefData['refAddress'] = v;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Address',
                          _personRefData['refAddress'],
                        ),

                  const SizedBox(height: 16),

                  // Telephone Number
                  _isEditingPersonRef
                      ? _buildPhoneFieldInline(
                          'Telephone No.',
                          _personRefData['refTelephone'],
                          (v) {
                            _personRefData['refTelephone'] = v;
                          },
                        )
                      : _buildInfoFieldInline(
                          'Telephone No.',
                          _personRefData['refTelephone'],
                        ),

                  const SizedBox(height: 8),
                ],
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
