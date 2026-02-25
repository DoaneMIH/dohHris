import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/pages/dtr_page.dart';
import 'package:mobile_application/pages/login_page.dart';
import 'package:mobile_application/pages/UserCredentials/civil_service.dart';
import 'package:mobile_application/pages/UserCredentials/education_background.dart';
import 'package:mobile_application/pages/UserCredentials/family_background.dart';
import 'package:mobile_application/pages/UserCredentials/learning_development.dart';
import 'package:mobile_application/pages/UserCredentials/other_information.dart';
import 'package:mobile_application/pages/UserCredentials/person_reference.dart';
import 'package:mobile_application/pages/UserCredentials/voluntary_work.dart';
import 'package:mobile_application/pages/UserCredentials/work_experience.dart';
import 'package:mobile_application/services/authenticated_photo.dart';
import 'package:mobile_application/services/user_service.dart';


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

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  final _userService = UserService();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _error;

  // Personal info editing
  bool _isEditingPersonalInfo = false;
  Map<String, dynamic> _personalInfoData = {};

  // Selected menu state
  String _selectedMenu = 'Personal Information';

  // Drawer expansion states
  bool _isInformationExpanded = false;
  bool _isServicesExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _userService.getUserDetails(widget.token);

    setState(() {
      if (result['success']) {
        _userDetails = result['data'];
        if (_userDetails?['employee'] != null) {
          _personalInfoData = Map<String, dynamic>.from(_userDetails!['employee']);
          final photoFields = ['photo', 'photoUrl', 'profilePhoto', 'image', 'profileImage', 'photo_url'];
          for (var field in photoFields) {
            _personalInfoData.remove(field);
          }
          final protectedFields = ['employmentStatus', 'employment_status'];
          for (var field in protectedFields) {
            _personalInfoData.remove(field);
          }
        }
      } else {
        _error = result['error'];
      }
      _isLoading = false;
    });
  }

  Future<void> _savePersonalInformation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator(
        color: Colors.white,
      )),
    );

    try {
      final employeeId = _userDetails?['employee']?['id'];
      if (employeeId == null) throw Exception('Employee ID not found');

      final response = await _userService.updatePersonalInformation(
        widget.token,
        employeeId.toString(),
        _personalInfoData,
      );

      if (mounted) Navigator.pop(context);

      if (response['success']) {
        await _fetchUserDetails();
        if (mounted) {
          setState(() => _isEditingPersonalInfo = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personal information updated successfully'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to update');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

// ─── Reset Password Dialog ────────────────────────────────────────────────
  void _showResetPasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    // Validation error strings (null = no error)
    String? newPasswordError;
    String? confirmPasswordError;

    // ── Password strength rules ──
    bool hasMinLength(String p) => p.length >= 8;
    bool hasSpecialChar(String p) =>
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]').hasMatch(p);

    String? validateNewPassword(String value) {
      if (value.isEmpty) return 'Please enter a new password.';
      if (!hasMinLength(value)) return 'Must be at least 8 characters.';
      if (!hasSpecialChar(value)) return 'Must contain at least 1 special character.';
      return null;
    }

    String? validateConfirmPassword(String newPass, String confirm) {
      if (confirm.isEmpty) return 'Please confirm your new password.';
      if (newPass != confirm) return 'Passwords do not match.';
      return null;
    }

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {

            // ── Reusable password field builder ──
            Widget buildPasswordField({
              required TextEditingController controller,
              required bool obscure,
              required VoidCallback onToggleObscure,
              required String hint,
              String? errorText,
              ValueChanged<String>? onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: errorText != null
                          ? const Color(0xFFFFF0F0)
                          : const Color(0xFFF0F4F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: errorText != null
                            ? const BorderSide(color: Colors.red, width: 1)
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: errorText != null
                              ? Colors.red
                              : const Color(0xFF00674F),
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: onToggleObscure,
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 13, color: Colors.red),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            errorText,
                            style: const TextStyle(fontSize: 11, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }

            // ── Password strength indicator ──
            Widget buildStrengthIndicator(String password) {
              if (password.isEmpty) return const SizedBox.shrink();
              final lengthOk = hasMinLength(password);
              final specialOk = hasSpecialChar(password);

              Widget rule(bool met, String label) => Row(
                children: [
                  Icon(
                    met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 13,
                    color: met ? const Color(0xFF00674F) : Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: met ? const Color(0xFF00674F) : Colors.grey[600],
                    ),
                  ),
                ],
              );

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rule(lengthOk, 'At least 8 characters'),
                    const SizedBox(height: 2),
                    rule(specialOk, 'At least 1 special character (e.g. @, #, !)'),
                  ],
                ),
              );
            }

            // ── Save handler ──
            Future<void> onSave() async {
              final current = currentPasswordController.text.trim();
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              // Validate all fields
              if (current.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your current password.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final newErr = validateNewPassword(newPass);
              final confirmErr = validateConfirmPassword(newPass, confirm);

              setDialogState(() {
                newPasswordError = newErr;
                confirmPasswordError = confirmErr;
              });

              if (newErr != null || confirmErr != null) return;

              // Call API
              setDialogState(() => isLoading = true);

              final result = await _userService.changePassword(
                widget.token,
                currentPassword: current,
                newPassword: newPass,
              );

              setDialogState(() => isLoading = false);

              if (!mounted) return;

              if (result['success']) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Failed to change password.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Dialog Header ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00674F),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.pop(dialogContext),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // ── Dialog Body ──
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Current Password ──
                        const Text(
                          'Enter Current Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        buildPasswordField(
                          controller: currentPasswordController,
                          obscure: obscureCurrent,
                          hint: 'Current password',
                          onToggleObscure: () =>
                              setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                        const SizedBox(height: 14),

                        // ── New Password ──
                        const Text(
                          'Set New Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        buildPasswordField(
                          controller: newPasswordController,
                          obscure: obscureNew,
                          hint: 'New password',
                          errorText: newPasswordError,
                          onToggleObscure: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                          onChanged: (value) => setDialogState(() {
                            // Live-clear error once valid
                            if (newPasswordError != null) {
                              newPasswordError = validateNewPassword(value);
                            }
                          }),
                        ),
                        // Strength indicator shown while typing
                        buildStrengthIndicator(newPasswordController.text),
                        const SizedBox(height: 14),

                        // ── Confirm Password ──
                        const Text(
                          'Confirm New Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        buildPasswordField(
                          controller: confirmPasswordController,
                          obscure: obscureConfirm,
                          hint: 'Confirm new password',
                          errorText: confirmPasswordError,
                          onToggleObscure: () =>
                              setDialogState(() => obscureConfirm = !obscureConfirm),
                          onChanged: (value) => setDialogState(() {
                            if (confirmPasswordError != null) {
                              confirmPasswordError = validateConfirmPassword(
                                  newPasswordController.text, value);
                            }
                          }),
                        ),
                        const SizedBox(height: 22),

                        // ── Buttons ──
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00674F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: isLoading ? null : onSave,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Save',
                                        style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed:
                                    isLoading ? null : () => Navigator.pop(dialogContext),
                                child: const Text('Cancel',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  //Helper to get employeeId string safely 
  String get _employeeId => _userDetails?['employee']?['id']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = widget.scaffoldKey ?? _scaffoldKey;
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/logo.png', width: 200, height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(width: 7),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/bp_logo.png', width: 100, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('DOH WV CHD', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.9)),
                  Text('HRIS', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ],
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00674F),
          actions: [
            // ── Clickable profile avatar with popup menu ──
            Padding(
              
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (value) {
                  if (value == 'reset_password') {
                    _showResetPasswordDialog();
                  } else if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'reset_password',
                    child: Row(
                      children: const [
                        Icon(Icons.lock_reset, color: Color(0xFF00674F), size: 20),
                        SizedBox(width: 10),
                        Text('Reset Password', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Logout', style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                // ── The trigger: profile photo (edit icon blocked) ──
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
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
                 const SizedBox(height: 20),
              ExpansionTile(
                leading: const Icon(Icons.room_service, color: Color(0xFF00674F)),
                title: const Text('Services', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00674F))),
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                initiallyExpanded: _isServicesExpanded,
                onExpansionChanged: (expanded) => setState(() => _isServicesExpanded = expanded),
                children: [
                  _buildDrawerItem('Daily Time Record', Icons.access_time, _selectedMenu == 'Daily Time Record'),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF00674F)),
                title: const Text('Information', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00674F))),
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                initiallyExpanded: _isInformationExpanded,
                onExpansionChanged: (expanded) => setState(() => _isInformationExpanded = expanded),
                children: [
                  _buildDrawerItem('Personal Information', Icons.person, _selectedMenu == 'Personal Information'),
                  _buildDrawerItem('Family Background', Icons.family_restroom, _selectedMenu == 'Family Background'),
                  _buildDrawerItem('Educational Background', Icons.school, _selectedMenu == 'Educational Background'),
                  _buildDrawerItem('Civil Service Eligibility', Icons.verified, _selectedMenu == 'Civil Service Eligibility'),
                  _buildDrawerItem('Work Experience', Icons.work, _selectedMenu == 'Work Experience'),
                  _buildDrawerItem('Voluntary Work', Icons.volunteer_activism, _selectedMenu == 'Voluntary Work'),
                  _buildDrawerItem('Learning and Development', Icons.psychology, _selectedMenu == 'Learning and Development'),
                  _buildDrawerItem('Person References', Icons.info, _selectedMenu == 'Person References'),
                  _buildDrawerItem('Other Information', Icons.info, _selectedMenu == 'Other Information'),
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
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchUserDetails, child: const Text('Retry')),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileHeader(),
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

  // ─── Profile Header ───────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      height: 295,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
            child: AuthenticatedProfilePhoto(
              photoUrl: _userDetails?['employee']?['photoUrl'],
              baseUrl: widget.baseUrl,
              userName: (_userDetails?['name'] ?? 'User').toString(),
              radius: 70,
              token: widget.token,
              employeeId: _userDetails?['employee']?['id']?.toString(),
              onPhotoUpdated: _fetchUserDetails,
            ),
          ),
          const SizedBox(width: 25, height: 10),
          Flexible(
            child: Column(
              children: [
                Text(
                  "${_userDetails?['employee']?['firstName'] ?? 'N/A'} "
                  "${_userDetails?['employee']?['middleName'] != null && (_userDetails?['employee']?['middleName'] as String).isNotEmpty ? '${(_userDetails?['employee']?['middleName'] as String)[0]}. ' : ''}"
                  "${_userDetails?['employee']?['lastName'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Employee ID:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(_userDetails?['employee']?['employeeId']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.badge, size: 18),
                    const SizedBox(width: 6),
                    Text(_userDetails?['employee']?['designation']?['desigCode'] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.apartment, size: 18),
                    const SizedBox(width: 6),
                    const Text('ICTU', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Content Router ───────────────────────────────────────────────────────
  Widget _buildSelectedContent() {
    switch (_selectedMenu) {
      case 'Personal Information':
        return _buildPersonalInformationCard();
      case 'Family Background':
        return FamilyBackgroundWidget(token: widget.token, employeeId: _employeeId);
      case 'Educational Background':
        return EducationalBackgroundWidget(token: widget.token, employeeId: _employeeId);
      case 'Civil Service Eligibility':
        return CivilServiceWidget(token: widget.token, employeeId: _employeeId);
      case 'Work Experience':
        return WorkExperienceWidget(token: widget.token, employeeId: _employeeId);
      case 'Voluntary Work':
        return VoluntaryWorkWidget(token: widget.token, employeeId: _employeeId);
      case 'Learning and Development':
        return LearningDevelopmentWidget(token: widget.token, employeeId: _employeeId);
      case 'Person References':
        return PersonReferenceWidget(token: widget.token, employeeId: _employeeId);
      case 'Other Information':
        return OtherInformationWidget(token: widget.token, employeeId: _employeeId);
      case 'Daily Time Record':
        return _buildDailyTimeRecordCard();
      default:
        return _buildPersonalInformationCard();
    }
  }

  // ─── Personal Information Card (kept here — uses _userDetails directly) ──
  Widget _buildPersonalInformationCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C5F4F),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        const Text('PERSONAL INFORMATION', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        Row(
                        children: [
                          // if (!_isEditingPersonalInfo)
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 15,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              if (_isEditingPersonalInfo) {
                                await _savePersonalInformation();
                              } else {
                                final employee = _userDetails?['employee'];
                                if (employee != null) {
                                  _personalInfoData = {
                                    'lastName': employee['lastName'] ?? '',
                                    'firstName': employee['firstName'] ?? '',
                                    'middleName': employee['middleName'] ?? '',
                                    'suffix': employee['suffix'] ?? '',
                                    'sex': employee['sex'] ?? '',
                                    'photoUrl': employee['photoUrl'] ?? '',
                                    'civilStatus':
                                        employee['civilStatus'] ?? '',
                                      'citizenship': employee['citizenship'] ?? '',
                                      'birthdate': employee['birthdate'] ?? '',
                                      'birthplace': employee['birthplace'] ?? '',
                                      'employeeId': employee['employeeId'] ?? '',
                                      'height': employee['height'] ?? 0,
                                      'weight': employee['weight'] ?? 0,
                                      'bloodType': employee['bloodType'] ?? '',
                                      'houseNo': employee['houseNo'] ?? '',
                                      'street': employee['street'] ?? '',
                                      'village': employee['village'] ?? '',
                                      'barangay': employee['barangay'] ?? '',
                                      'municipality': employee['municipality'] ?? '',
                                      'province': employee['province'] ?? '',
                                      'zipCode': employee['zipCode'] ?? '',
                                      'resHouseNo': employee['resHouseNo'] ?? '',
                                      'resStreet': employee['resStreet'] ?? '',
                                      'resVillage': employee['resVillage'] ?? '',
                                      'resBarangay': employee['resBarangay'] ?? '',
                                      'resMunicipality': employee['resMunicipality'] ?? '',
                                      'resProvince': employee['resProvince'] ?? '',
                                      'resZipCode': employee['resZipCode'] ?? '',
                                      'telephoneNo': employee['telephoneNo'] ?? '',
                                      'mobileNo': employee['mobileNo'] ?? '',
                                      'email': employee['email'] ?? '',
                                      'tin': employee['tin'] ?? '',
                                      'phic': employee['phic'] ?? '',
                                      'sss': employee['sss'] ?? '',
                                      'pagibig': employee['pagibig'] ?? '',
                                      'gsis': employee['gsis'] ?? '',
                                      'umid': employee['umid'] ?? '',
                                      'philsys': employee['philsys'] ?? '',
                                      'employmentStatus': employee['employmentStatus'] ?? 'true',
                                    };
                                  }
                                  setState(() => _isEditingPersonalInfo = true);
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
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
                                "${_userDetails?['employee']?['province'] ?? ''}",
                          ),
                          const SizedBox(height: 20),
                          _isEditingPersonalInfo
                              ? _buildPhoneFieldInline('Telephone No.', _personalInfoData['telephoneNo'], (v) => setState(() => _personalInfoData['telephoneNo'] = v))
                              : _buildInfoFieldInline('Telephone No.', _userDetails?['employee']?['telephoneNo']),
                          const SizedBox(height: 20),
                          _isEditingPersonalInfo
                              ? _buildPhoneFieldInline('Mobile No.', _personalInfoData['mobileNo'], (v) => setState(() => _personalInfoData['mobileNo'] = v))
                              : _buildInfoFieldInline('Mobile No.', _userDetails?['employee']?['mobileNo']),
                          const SizedBox(height: 20),
                          _buildInfoFieldInline('Email Address', _userDetails?['email']),
                          const SizedBox(height: 20),
                          _buildInfoFieldInline('Agency Employee No.', _userDetails?['employee']?['employeeId']),
                          const SizedBox(height: 20),
                          _buildInfoFieldInline('UMID ID No.', _userDetails?['employee']?['umid']),
                          const SizedBox(height: 20),
                          _buildInfoFieldInline('Pag-ibig No.', _userDetails?['employee']?['pagibig']),
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
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() {
                                  _isEditingPersonalInfo = false;
                                }),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _savePersonalInformation(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Daily Time Record Card ───────────────────────────────────────────────
  Widget _buildDailyTimeRecordCard() {
    return DtrWidget(
      token: widget.token,
      baseUrl: widget.baseUrl,
      userId: _userDetails?['employee']?['employeeId'] ?? 'N/A',
    );
  }

  // ─── Drawer Item ─────────────────────────────────────────────────────────
  Widget _buildDrawerItem(String title, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF00674F) : Colors.grey[600]),
      title: Text(title, style: TextStyle(color: isSelected ? const Color(0xFF00674F) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      // ignore: deprecated_member_use
      selectedTileColor: const Color(0xFF00674F).withOpacity(0.1),
      onTap: () {
        setState(() => _selectedMenu = title);
        Navigator.pop(context);
      },
    );
  }

  // ─── Shared Field Helpers ────────────────────────────────────────────────
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
              // ignore: empty_catches
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
              final formattedDate = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              controller.text = formattedDate;
              onChanged(formattedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today, size: 20, color: Color(0xFF2C5F4F)),
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}