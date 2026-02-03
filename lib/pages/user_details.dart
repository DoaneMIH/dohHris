import 'package:flutter/material.dart';
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

  // Family background data structures
  Map<String, dynamic> _spouseData = {};
  List<Map<String, dynamic>> _childrenData = [];
  Map<String, dynamic> _fatherData = {};
  Map<String, dynamic> _motherData = {};

  // Edit mode flags
  bool _isEditingSpouse = false;
  bool _isEditingFather = false;
  bool _isEditingMother = false;
  int? _editingChildIndex;

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
    _initializeFamilyData();
  }

  void _initializeFamilyData() {
    // Initialize with sample data - replace with actual API data
    _spouseData = {
      'firstName': 'Ma. Josie',
      'middleName': 'Sallid',
      'lastName': 'Jacintos',
      'nameExtension': '',
      'occupation': 'REVENUE OFFICER 1\n(TAXPAYERS ASSISTANCE)',
      'employer': 'BUREAU OF INTERNAL REVENUE',
      'businessAddress': 'PLAZUELA DOS, MANDURRIAO, ILOILO CITY',
      'telephoneNo': '',
    };

    _childrenData = [
      {'name': 'Calleigh Ysabelle S. Jacintos', 'birthday': '02/06/2022'},
    ];

    _fatherData = {
      'firstName': 'Danny',
      'middleName': 'Largo',
      'lastName': 'Jacintos',
      'nameExtension': '',
    };

    _motherData = {
      'firstName': '',
      'middleName': '',
      'lastName': '',
      'nameExtension': '',
    };

    _educationData = [
      {
        'level': 'ELEMENTARY',
        'schoolName': 'TIGUM ANP PILOT ELEMENTARY SCHOOL',
      },
      {'level': 'SECONDARY', 'schoolName': 'PAVIA NATIONAL HIGH SCHOOL'},
      {'level': 'VOCATIONAL/TRADE COURSE', 'schoolName': 'N/A'},
      {'level': 'COLLEGE', 'schoolName': 'WESTERN INSTITUTE OF TECHNOLOGY'},
      {'level': 'GRADUATE STUDIES', 'schoolName': 'N/A'},
    ];

    // Initialize civil service data
    _civilServiceData = [
      {
        'careerService':
            'Career Service/ RA 1080 (Board/ Bar) Under Special Laws/ CES/ CSEE Barangay Eligibility / Driver\'s License',
        'rating': '',
        'dateOfExam': '',
        'placeOfExam': '',
        'licenseNumber': '',
        'validity': '',
      },
    ];

    // Initialize work experience data
    _workExperienceData = [
      {
        'dateFrom': '01/01/2024',
        'dateTo': 'PRESENT',
        'positionTitle': 'Computer PROGRAMMER II',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
      {
        'dateFrom': '07/18/2022',
        'dateTo': '12/31/2023',
        'positionTitle': 'COMPUTER PROGRAMMER I',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
      {
        'dateFrom': '11/12/2018',
        'dateTo': '07/15/2022',
        'positionTitle': 'FINANCE SUPERVISOR - PROJECT TEAM (XAVIER SYSTEM)',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
      {
        'dateFrom': '11/15/2010',
        'dateTo': '11/11/2018',
        'positionTitle': 'FINANCE SUPERVISOR',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
      {
        'dateFrom': '07/07/2007',
        'dateTo': '11/14/2010',
        'positionTitle': 'FINANCE ASSOCIATE',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
      {
        'dateFrom': '01/01/2026',
        'dateTo': '',
        'positionTitle': 'qsfqsd',
        'department': '',
        'monthlySalary': '',
        'salaryGrade': '',
        'statusOfAppointment': '',
        'governmentService': '',
      },
    ];

    // Initialize voluntary work data
    _voluntaryWorkData = [
      {
        'organization': 'CFC-SINGLES FOR CHRIST MINISTRY - ILOILO CITY',
        'dateFrom': '08/13/2014',
        'dateTo': '',
        'numberOfHours': '',
        'positionNature': '',
      },
      {
        'organization': 'test voluntary work',
        'dateFrom': '01/01/2026',
        'dateTo': '',
        'numberOfHours': '',
        'positionNature': '',
      },
      {
        'organization': 'LIGHT OF JESUS COMMUNITY- THE FEAST ILOILO',
        'dateFrom': '07/18/2017',
        'dateTo': '',
        'numberOfHours': '',
        'positionNature': '',
      },
    ];

    // Initialize learning and development data
    _learningDevelopmentData = [
      {
        'title':
            '2025 PRIVACY IMPACT ASSESSMENT WITH DPA CAPACITY ENHANCEMENT ON CYBERSECURITY FRAMEWORK',
        'dateFrom': '',
        'dateTo': '',
        'numberOfHours': '',
        'typeOfLD': '',
        'conductedBy': '',
      },
      {
        'title':
            'TRAINING ON DATA VISUALIZATION USING POWER BI AND GOVERNMENT WEB TEMPLATE (GWT) IN WORDPRESS',
        'dateFrom': '',
        'dateTo': '',
        'numberOfHours': '',
        'typeOfLD': '',
        'conductedBy': '',
      },
    ];

    // Initialize special skills data
    _specialSkillsData = [
      {'skill': 'MYSQL/MSSQL db'},
      {'skill': 'COMPUTER AND NETWORK MAINTENANCE AND TROUBLESHOOTING'},
      {'skill': 'JAVA/SPRING BOOT AND REACT JS PROGRAMMING'},
      {'skill': 'WEB DEVELOPMENT/FULL STACK'},
    ];

    // Initialize non-academic distinctions data
    _nonAcademicDistinctionsData = [
      {'distinction': 'CONSISTENT ACADEMIC SCHOLAR DURING TERTIARY education'},
      {
        'distinction':
            'BEST FINANCE SUPERVISOR DURING TSKI 31ST ANNIVERSARY LAST 2017',
      },
    ];

    // Initialize membership data
    _membershipData = [
      {'organization': 'SINGLES FOR CHRIST ministry'},
      {'organization': 'LIGHT OF JESUS COMMUNITY'},
    ];

    // Initialize other information inquiry
    _otherInformationInquiry = '';

    // Initialize references data
    _referencesData = [
      {
        'name': 'JUNE B. vargas',
        'address': '#51 MH DEL PILAR',
        'telephoneNo': '',
      },
      {
        'name': 'PATRICK PAULO AMOR HUBAG',
        'address': 'PAVIA, iloilo',
        'telephoneNo': '',
      },
      {'name': 'fsadf', 'address': 'fdasfs', 'telephoneNo': ''},
    ];

    // Initialize government ID data
    _governmentIDData = {
      'issuedID': '',
      'unifiedMultiPurposeID': 'Unified Multi-Purpose ID',
      'idNumber': 'CRN - 0111-1008314-9',
      'dateIssued': '01/07/2026',
      'placeIssued': 'tigum pavia iloilo',
    };
  }

  Future<void> _fetchUserDetails() async {
    print('⏳ [UserDetailsPage] Fetching user profile with token...');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _userService.getUserDetails(widget.token);

    print('📦 [UserDetailsPage] Result received from UserService');
    print('📦 [UserDetailsPage] Success: ${result['success']}');

    setState(() {
      if (result['success']) {
        _userDetails = result['data'];
        print('✅ [UserDetailsPage] User profile loaded successfully');
        print('👤 [UserDetailsPage] User name: ${_userDetails?['name']}');
        print(
          '📷 [UserDetailsPage] Profile photo: ${_userDetails?['photoUrl'] ?? 'No photo'}',
        );
      } else {
        _error = result['error'];
        print('❌ [UserDetailsPage] Error loading user profile: $_error');
      }
      _isLoading = false;


      
    });

    print('🏁 [UserDetailsPage] Fetch user profile completed\n');
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 230, 255, 230),
          ],
        ),
      ),
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
          // Profile Photo
          AuthenticatedProfilePhoto(
            photoUrl: _userDetails?['employee']?['photoUrl'],
            baseUrl: widget.baseUrl,
            userName: (_userDetails?['name'] ?? 'User').toString(),
            radius: 70,
            token: widget.token,
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
                      _userDetails?['employee']?['employeeId'] ?? 'N/A',
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
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                    ],
                  ),
                ),
                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoFieldInline(
                        'Date of Birth',
                        _userDetails?['employee']?['birthdate'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Place of Birth',
                        _userDetails?['employee']?['birthplace'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Civil Status',
                        _userDetails?['employee']?['civilStatus'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Citizenship',
                        _userDetails?['employee']?['citizenship'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Sex at Birth',
                        _userDetails?['employee']?['sex'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Blood Type',
                        _userDetails?['employee']?['bloodType'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Height (cm)',
                        _userDetails?['employee']?['height'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
                        'Weight (kg)',
                        _userDetails?['employee']?['weight'],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
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
                      // _buildInfoFieldInline(
                      //   'Telephone No.',
                      //   _userDetails?['employee']?['telephoneNo'],
                      // ),
                      _buildInfoFieldInline(
                        'Telephone No.',
                        ((_userDetails?['employee']?['telephoneNo'] ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty)
                            ? _userDetails?['employee']?['telephoneNo']
                            : 'N/A',
                      ),
                      const SizedBox(height: 20),
                      _buildInfoFieldInline(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Family Background Card Widget
  Widget _buildFamilyBackgroundCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isFamilyBackgroundExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Content - only show when expanded
          if (_isFamilyBackgroundExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Spouse Section
                  _buildSpouseSection(),
                  const SizedBox(height: 20),

                  // Children Section
                  _buildChildrenSection(),
                  const SizedBox(height: 20),

                  // Father Section
                  _buildFatherSection(),
                  const SizedBox(height: 20),

                  // Mother Section
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
                  onPressed: () {
                    setState(() {
                      // Clear all spouse data
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
                  },
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
                    setState(() {
                      _isEditingSpouse = !_isEditingSpouse;
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
        // Single container with all fields in grid layout
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                  ? _buildEditableFieldInline(
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
        const SizedBox(height: 8),
        ..._childrenData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> child = entry.value;
          bool isEditing = _editingChildIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                // A list of shadows to apply
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 12,
                  offset: Offset(
                    0,
                    1,
                  ), // Changes the position of the shadow (x, y)
                ),
              ],
            ),
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
                            setState(() {
                              _editingChildIndex = isEditing ? null : index;
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
                              _childrenData.removeAt(index);
                              if (_editingChildIndex == index) {
                                _editingChildIndex = null;
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
                Container(
                  // spacing around each child box
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  // inner spacing of the white box
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                          ? _buildEditableFieldInline(
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
                setState(() {
                  _isEditingFather = !_isEditingFather;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Single container with all fields in grid layout
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 1),
              ),
            ],
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
                setState(() {
                  _isEditingMother = !_isEditingMother;
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 1),
              ),
            ],
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

  // Educational Background Section
  Widget _buildEducationalBackgroundCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          // A list of shadows to apply
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 1), // Changes the position of the shadow (x, y)
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isEducationalBackgroundExpanded =
                    !_isEducationalBackgroundExpanded;
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
                  Icon(
                    _isEducationalBackgroundExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._educationData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> education = entry.value;
                    bool isEditing = _editingEducationIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level + school stacked
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  education['level'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                isEditing
                                    ? _buildEditableFieldInline(
                                        '',
                                        education['schoolName'],
                                        (value) {
                                          _educationData[index]['schoolName'] =
                                              value;
                                        },
                                      )
                                    : Text(
                                        education['schoolName'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // keep edit/delete at the same place (right)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.check : Icons.edit,
                                  size: 20,
                                  color: Color(0xFF2C5F4F),
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

  // Civil Service Eligibility Section
  Widget _buildCivilServiceCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isCivilServiceExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          // A list of shadows to apply
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: Offset(
                              0,
                              1,
                            ), // Changes the position of the shadow (x, y)
                          ),
                        ],
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
                                    ? _buildEditableFieldInline(
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
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isWorkExperienceExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isVoluntaryWorkExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          // A list of shadows to apply
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: Offset(
                              0,
                              1,
                            ), // Changes the position of the shadow (x, y)
                          ),
                        ],
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
                                    _buildEditableFieldInline(
                                      'Date From',
                                      voluntary['dateFrom'],
                                      (value) {
                                        _voluntaryWorkData[index]['dateFrom'] =
                                            value;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    _buildEditableFieldInline(
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
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isLearningDevelopmentExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          // A list of shadows to apply
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: Offset(
                              0,
                              1,
                            ), // Changes the position of the shadow (x, y)
                          ),
                        ],
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
                                  child: _buildEditableFieldInline(
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
                                  child: _buildEditableFieldInline(
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
        borderRadius: BorderRadius.circular(8),
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
                  Icon(
                    _isOtherInformationExpanded ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 20,
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
                  const SizedBox(height: 12),
                  ..._specialSkillsData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> skill = entry.value;
                    bool isEditing = _editingSpecialSkillIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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

                  const SizedBox(height: 20),

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
                  const SizedBox(height: 12),
                  ..._nonAcademicDistinctionsData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> distinction = entry.value;
                    bool isEditing =
                        _editingNonAcademicDistinctionIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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

                  const SizedBox(height: 20),

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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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

                  const SizedBox(height: 20),

                  // Other Information Inquiry Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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

                  const SizedBox(height: 20),

                  // References Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'References',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
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
                  const SizedBox(height: 12),
                  ..._referencesData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> reference = entry.value;
                    bool isEditing = _editingReferenceIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          // A list of shadows to apply
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: Offset(
                              0,
                              1,
                            ), // Changes the position of the shadow (x, y)
                          ),
                        ],
                      ),
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
                            _buildEditableFieldInline(
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

                  const SizedBox(height: 20),

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
                            color: Colors.black,
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
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
                          _buildEditableFieldInline(
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
    String displayValue = '';
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
        TextField(
          controller: TextEditingController(text: value ?? ''),
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
