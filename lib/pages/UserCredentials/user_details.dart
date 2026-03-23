import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/services/auth_service.dart';
import 'package:mobile_application/services/user_profile_cache.dart';
import 'package:mobile_application/services/token_manager.dart';
import 'package:mobile_application/pages/dtr_page.dart';
import 'package:mobile_application/pages/payroll_page.dart';
import 'package:mobile_application/pages/loan_page.dart';
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
import 'package:provider/provider.dart';
import 'package:mobile_application/providers/theme_provider.dart';

// ════════════════════════════════════════════════════════════════════════════
// _DisplayOnlyPhoto
// ════════════════════════════════════════════════════════════════════════════
class _DisplayOnlyPhoto extends StatefulWidget {
  final String? photoUrl;
  final String? baseUrl;
  final String? token;
  final String userName;
  final double radius;

  const _DisplayOnlyPhoto({
    required this.photoUrl,
    required this.baseUrl,
    required this.token,
    required this.userName,
    required this.radius,
  });

  @override
  State<_DisplayOnlyPhoto> createState() => _DisplayOnlyPhotoState();
}

class _DisplayOnlyPhotoState extends State<_DisplayOnlyPhoto> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.photoUrl != null &&
        widget.photoUrl!.isNotEmpty &&
        widget.photoUrl != 'N/A') {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(_DisplayOnlyPhoto old) {
    super.didUpdateWidget(old);
    if (old.photoUrl != widget.photoUrl) {
      _imageBytes = null;
      _hasError = false;
      if (widget.photoUrl != null &&
          widget.photoUrl!.isNotEmpty &&
          widget.photoUrl != 'N/A') {
        _loadImage();
      }
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String fullPhotoUrl;
      if (widget.photoUrl!.startsWith('http')) {
        fullPhotoUrl = widget.photoUrl!;
      } else if (widget.photoUrl!.startsWith('/employee/image/')) {
        fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
      } else {
        fullPhotoUrl =
            '${widget.baseUrl ?? ''}/employee/image/${widget.photoUrl}';
      }

      final token = TokenManager().token ?? widget.token;

      final response = await http.get(
        Uri.parse(fullPhotoUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _imageBytes = response.bodyBytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted)
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white24,
        child: SizedBox(
          width: widget.radius * 0.8,
          height: widget.radius * 0.8,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (!_hasError && _imageBytes != null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white24,
        child: ClipOval(
          child: Image.memory(
            _imageBytes!,
            width: widget.radius * 2,
            height: widget.radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final initials = widget.userName.isNotEmpty
        ? widget.userName
              .trim()
              .split(' ')
              .where((w) => w.isNotEmpty)
              .take(2)
              .map((w) => w[0])
              .join()
              .toUpperCase()
        : '?';

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.white24,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// UserDetailsPageContent
class UserDetailsPageContent extends StatefulWidget {
  final String token;
  final String baseUrl;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const UserDetailsPageContent({
    super.key,
    required this.token,
    required this.baseUrl,
    this.scaffoldKey,
  });

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

  Map<String, dynamic> _personalInfoData = {};

  String _selectedMenu = 'Personal Information';

  bool _isInformationExpanded = false;
  bool _isServicesExpanded = false;

  // ─── Option lists for popup selectors ────────────────────────────────────
  static const List<String> _civilStatusOptions = [
    'Single',
    'Married',
    'Widowed',
    'Separated',
    'Annulled',
  ];

  static const List<String> _sexOptions = ['Male', 'Female'];

  static const List<String> _bloodTypeOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

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
        if (_userDetails != null) {
          UserProfileCache.instance.setFromUserDetails(_userDetails!);
        }
        if (_userDetails?['employee'] != null) {
          _personalInfoData = Map<String, dynamic>.from(
            _userDetails!['employee'],
          );
          final photoFields = [
            'photo',
            'photoUrl',
            'profilePhoto',
            'image',
            'profileImage',
            'photo_url',
          ];
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
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal information updated successfully'),
              backgroundColor: Color(0xFF344A51),
            ),
          );
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to update');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPTION BOTTOM SHEET HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Shows a scrollable modal bottom sheet for selecting one option from a list.
  Future<void> _showOptionBottomSheet({
    required BuildContext ctx,
    required String title,
    required String currentValue,
    required List<String> options,
    required void Function(String) onSelected,
  }) async {
    await showModalBottomSheet(
      context: ctx,
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Sheet title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx).primaryColor,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Scrollable Options
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...options.map((option) {
                        final isSelected =
                            option.toLowerCase() == currentValue.toLowerCase();
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                            Navigator.of(sheetCtx).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            color: isSelected
                                ? Theme.of(ctx).primaryColor.withOpacity(0.08)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Theme.of(ctx).primaryColor
                                          : Theme.of(
                                              ctx,
                                            ).textTheme.bodyMedium?.color,
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
                                    color: Theme.of(ctx).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a tappable field styled identically to buildField (TextFormField/fieldDeco),
  /// but opens a bottom sheet instead of a keyboard.
  Widget _buildOptionSelector({
    required String label,
    required String selectedValue,
    required List<String> options,
    required BuildContext ctx,
    required void Function(String) onChanged,
  }) {
    final hasValue = selectedValue.isNotEmpty;
    return GestureDetector(
      onTap: () => _showOptionBottomSheet(
        ctx: ctx,
        title: 'Select $label',
        currentValue: selectedValue,
        options: options,
        onSelected: onChanged,
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Theme.of(ctx).brightness == Brightness.dark
                ? Theme.of(ctx)
                      .colorScheme
                      .secondary // ← light grey-green in dark
                : Theme.of(ctx).primaryColor, // ← dark green in light
          ),
          filled: true,
          fillColor: Theme.of(ctx).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(ctx).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            size: 22,
            color: Theme.of(ctx).dividerColor,
          ),
        ),
        child: Text(
          hasValue ? selectedValue : '',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(ctx).textTheme.bodyMedium?.color ?? Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

    String? newPasswordError;
    String? confirmPasswordError;

    bool hasMinLength(String p) => p.length >= 8;
    bool hasSpecialChar(String p) =>
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]').hasMatch(p);

    String? validateNewPassword(String value) {
      if (value.isEmpty) return 'Please enter a new password.';
      if (!hasMinLength(value)) return 'Must be at least 8 characters.';
      if (!hasSpecialChar(value))
        return 'Must contain at least 1 special character.';
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
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: errorText != null
                          ? Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF3C2C2C)
                                : const Color(0xFFFFF0F0)
                          : Theme.of(context).inputDecorationTheme.fillColor,
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
                              : Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                        const Icon(
                          Icons.error_outline,
                          size: 13,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            errorText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }

            Widget buildStrengthIndicator(String password) {
              if (password.isEmpty) return const SizedBox.shrink();
              final lengthOk = hasMinLength(password);
              final specialOk = hasSpecialChar(password);
              Widget rule(bool met, String label) => Row(
                children: [
                  Icon(
                    met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 13,
                    color: met ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: met
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
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
                    rule(
                      specialOk,
                      'At least 1 special character (e.g. @, #, !)',
                    ),
                  ],
                ),
              );
            }

            Future<void> onSave() async {
              final current = currentPasswordController.text.trim();
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

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
                   SnackBar(
                    content: Text('Password changed successfully.'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] ?? 'Failed to change password.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
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
                          onTap: isLoading
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Current Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildPasswordField(
                          controller: currentPasswordController,
                          obscure: obscureCurrent,
                          hint: 'Current password',
                          onToggleObscure: () => setDialogState(
                            () => obscureCurrent = !obscureCurrent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Set New Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black87,
                          ),
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
                            if (newPasswordError != null)
                              newPasswordError = validateNewPassword(value);
                          }),
                        ),
                        buildStrengthIndicator(newPasswordController.text),
                        const SizedBox(height: 14),
                        Text(
                          'Confirm New Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildPasswordField(
                          controller: confirmPasswordController,
                          obscure: obscureConfirm,
                          hint: 'Confirm new password',
                          errorText: confirmPasswordError,
                          onToggleObscure: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm,
                          ),
                          onChanged: (value) => setDialogState(() {
                            if (confirmPasswordError != null)
                              confirmPasswordError = validateConfirmPassword(
                                newPasswordController.text,
                                value,
                              );
                          }),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
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
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
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

  // ─── Edit Personal Information Dialog ────────────────────────────────────
  void _showEditPersonalInfoDialog() {
    Map<String, dynamic> localData = Map<String, dynamic>.from(
      _personalInfoData,
    );

    bool sameAddress =
        (localData['resBarangay']?.toString() ?? '') ==
            (localData['barangay']?.toString() ?? '') &&
        (localData['resMunicipality']?.toString() ?? '') ==
            (localData['municipality']?.toString() ?? '') &&
        (localData['resProvince']?.toString() ?? '') ==
            (localData['province']?.toString() ?? '') &&
        (localData['resZipCode']?.toString() ?? '') ==
            (localData['zipCode']?.toString() ?? '');

    void copyPermToRes(void Function(void Function()) setDs) {
      setDs(() {
        localData['resHouseNo'] = localData['houseNo'];
        localData['resStreet'] = localData['street'];
        localData['resVillage'] = localData['village'];
        localData['resBarangay'] = localData['barangay'];
        localData['resMunicipality'] = localData['municipality'];
        localData['resProvince'] = localData['province'];
        localData['resZipCode'] = localData['zipCode'];
      });
    }

    InputDecoration fieldDeco(String label, {bool readOnly = false}) =>
        InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
        fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
            : Theme.of(context).primaryColor,           // ← dark green in light
      ),
          filled: true,
          fillColor: readOnly
              ? Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey[100]
              : Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
        );

    Widget buildField(
      String label,
      String key,
      void Function(void Function()) setDs,
    ) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: localData[key]?.toString() ?? '',
        onChanged: (v) => setDs(() => localData[key] = v),
        style: TextStyle(
          fontSize: 13,
          color:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: fieldDeco(label),
      ),
    );

    Widget buildDateField(
      String label,
      String key,
      void Function(void Function()) setDs,
      BuildContext ctx,
    ) {
      final ctrl = TextEditingController(
        text: localData[key]?.toString() ?? '',
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () async {
            DateTime? init;
            final v = localData[key]?.toString() ?? '';
            if (v.isNotEmpty) {
              try {
                init = DateTime.tryParse(v);
              } catch (_) {}
            }
            final picked = await showDatePicker(
              context: ctx,
              initialDate: init ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              final f =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              ctrl.text = f;
              setDs(() => localData[key] = f);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: ctrl,
              readOnly: true,
              style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
  fontWeight: FontWeight.w600,
),
              decoration: fieldDeco(label).copyWith(
                suffixIcon: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildSelectorField({
      required String label,
      required String key,
      required List<String> options,
      required void Function(void Function()) setDs,
      required BuildContext ctx,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOptionSelector(
          label: label,
          selectedValue: localData[key]?.toString() ?? '',
          options: options,
          ctx: ctx,
          onChanged: (v) => setDs(() => localData[key] = v),
        ),
      );
    }

    Widget sectionHeader(String title, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 15,  
         color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF587CA5)                         // ←  in dark
                    : Theme.of(context).primaryColor),         // ←  in light ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
               color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF587CA5)                         // ←  in dark
                    : Theme.of(context).primaryColor,           // ←  in light 
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
        ],
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDs) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Edit Personal Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionHeader(
                            'Basic Information',
                            Icons.person_outline,
                          ),
                          buildDateField(
                            'Date of Birth',
                            'birthdate',
                            setDs,
                            dialogContext,
                          ),
                          buildField('Place of Birth', 'birthplace', setDs),

                          // ── Civil Status — popup bottom sheet selector ──
                          buildSelectorField(
                            label: 'Civil Status',
                            key: 'civilStatus',
                            options: _civilStatusOptions,
                            setDs: setDs,
                            ctx: dialogContext,
                          ),

                          buildField('Citizenship', 'citizenship', setDs),

                          // ── Sex at Birth — popup bottom sheet selector ──
                          buildSelectorField(
                            label: 'Sex at Birth',
                            key: 'sex',
                            options: _sexOptions,
                            setDs: setDs,
                            ctx: dialogContext,
                          ),

                          // ── Blood Type — popup bottom sheet selector ──
                          buildSelectorField(
                            label: 'Blood Type',
                            key: 'bloodType',
                            options: _bloodTypeOptions,
                            setDs: setDs,
                            ctx: dialogContext,
                          ),

                          buildField('Height (cm)', 'height', setDs),
                          buildField('Weight (kg)', 'weight', setDs),
                          sectionHeader(
                            'Contact Information',
                            Icons.contact_phone_outlined,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              initialValue:
                                  localData['telephoneNo']?.toString() ?? '',
                              onChanged: (v) =>
                                  setDs(() => localData['telephoneNo'] = v),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color ??
                                    Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: fieldDeco('Telephone No.'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              initialValue:
                                  localData['mobileNo']?.toString() ?? '',
                              onChanged: (v) =>
                                  setDs(() => localData['mobileNo'] = v),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              style: TextStyle(
  fontSize: 13,
  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
  fontWeight: FontWeight.w600,
),
                              decoration: fieldDeco('Mobile No.'),
                            ),
                          ),
                          sectionHeader(
                            'Permanent Address',
                            Icons.home_outlined,
                          ),
                          buildField('House No.', 'houseNo', setDs),
                          buildField('Street', 'street', setDs),
                          buildField('Village / Subdivision', 'village', setDs),
                          buildField('Barangay', 'barangay', setDs),
                          buildField(
                            'Municipality / City',
                            'municipality',
                            setDs,
                          ),
                          buildField('Province', 'province', setDs),
                          buildField('Zip Code', 'zipCode', setDs),
                          sectionHeader(
                            'Residential Address',
                            Icons.location_on_outlined,
                          ),
                          GestureDetector(
                            onTap: () {
                              setDs(() => sameAddress = !sameAddress);
                              if (!sameAddress) copyPermToRes(setDs);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: sameAddress
                                    ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color.fromARGB(255, 0, 0, 0) // ← dark muted green in dark mode
                                          : Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(
                                              0.1,
                                            ) // ← light green in light
                                    : Theme.of(context).brightness ==
                                          Brightness.dark
                                    ? const Color.fromARGB(255, 0, 0, 0) // ← dark muted orange in dark mode
                                    : const Color.fromARGB(255, 245, 245, 245), // ← light orange in light
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sameAddress
                                      ? Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(context).primaryColor // ← muted green border in dark
                                            : Theme.of(context).primaryColor
                                      : Theme.of(context).brightness ==
                                            Brightness.dark
                                      ? Theme.of(context).colorScheme.secondary // ← muted orange border in dark
                                      : Theme.of(context).colorScheme.secondary
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: sameAddress,
                                    activeColor: Theme.of(context).primaryColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (val) {
                                      setDs(() => sameAddress = val ?? false);
                                      if (sameAddress) copyPermToRes(setDs);
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sameAddress
                                              ? 'Same as Permanent Address'
                                              : 'Different from Permanent Address',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: sameAddress
                                                ? Theme.of(context).colorScheme.secondary
                                                : Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                        Text(
                                          sameAddress
                                              ? 'Residential will be copied from permanent'
                                              : 'Fill in residential address below',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!sameAddress) ...[
                            buildField('House No.', 'resHouseNo', setDs),
                            buildField('Street', 'resStreet', setDs),
                            buildField(
                              'Village / Subdivision',
                              'resVillage',
                              setDs,
                            ),
                            buildField('Barangay', 'resBarangay', setDs),
                            buildField(
                              'Municipality / City',
                              'resMunicipality',
                              setDs,
                            ),
                            buildField('Province', 'resProvince', setDs),
                            buildField('Zip Code', 'resZipCode', setDs),
                          ],
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  Container(
  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
  child: Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save, size: 16),
          label: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (sameAddress) {
              localData['resHouseNo'] = localData['houseNo'];
              localData['resStreet'] = localData['street'];
              localData['resVillage'] = localData['village'];
              localData['resBarangay'] = localData['barangay'];
              localData['resMunicipality'] = localData['municipality'];
              localData['resProvince'] = localData['province'];
              localData['resZipCode'] = localData['zipCode'];
            }
            setState(() => _personalInfoData = localData);
            Navigator.pop(dialogContext);
            _savePersonalInformation();
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200],
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
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

  // ─── Helper to get employeeId string safely ───────────────────────────────
  String get _employeeId => _userDetails?['employee']?['id']?.toString() ?? '';

  // ─── AppBar profile avatar ────────────────────────────────────────────────
  Widget _buildAppBarAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<String>(
        color: Theme.of(context).scaffoldBackgroundColor,
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) {
          if (value == 'reset_password') {
            _showResetPasswordDialog();
          } else if (value == 'logout') {
            AuthService.logout(context);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'reset_password',
            child: Row(
              children: [
                 Icon(Icons.lock_reset, 
                 color: Theme.of(context).brightness == Brightness.dark
                   ? Color(0xFF587CA5)                         // ←  in dark
                   : Theme.of(context).primaryColor,           // ←  in light
                 size: 20),
                const SizedBox(width: 10),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
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
                Text(
                  'Logout',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
        child: _DisplayOnlyPhoto(
          photoUrl: _userDetails?['employee']?['photoUrl'],
          baseUrl: widget.baseUrl,
          token: widget.token,
          userName: (_userDetails?['name'] ?? 'User').toString(),
          radius: 17,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = widget.scaffoldKey ?? _scaffoldKey;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme:  IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Row(
            children: [
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 7),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/bp_logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
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
          actions: [
            // Theme Toggle Button
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            _buildAppBarAvatar(),
          ],
        ),
        endDrawer: Drawer(
          width: 300,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 20),
              ExpansionTile(
                leading: Icon(
                  Icons.room_service,
                  color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.secondary  // ←  in dark
        : Theme.of(context).primaryColor,           // ←  in light
                ),
                title: Text(
                  'Services',
                  style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.secondary  // ←  in dark
          : Theme.of(context).primaryColor,           // ← in light
    ),
  ),
                iconColor: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary       // ← white arrow in dark
      : Colors.black,       // ← black arrow in light
  collapsedIconColor: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary        // ← white arrow in dark
      : Colors.black,       // ← black arrow in light
                initiallyExpanded: _isServicesExpanded,
                onExpansionChanged: (expanded) =>
                    setState(() => _isServicesExpanded = expanded),
                children: [
                  _buildDrawerItem(
                    'Daily Time Record',
                    Icons.access_time,
                    _selectedMenu == 'Daily Time Record',
                  ),
                  _buildDrawerItem(
                    'Payroll',
                    Icons.payments_outlined,
                    _selectedMenu == 'Payroll',
                  ),
                  _buildDrawerItem(
                    'Loan',
                    Icons.account_balance_outlined,
                    _selectedMenu == 'Loan',
                  ),
                ],
              ),
            
ExpansionTile(
  leading: Icon(
    Icons.info_outline,
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
        : Theme.of(context).primaryColor,           // ← dark green in light
  ),
                title: Text(
                  'Information',
                   style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
          : Theme.of(context).primaryColor,           // ← dark green in light
    ),
  ),
                iconColor: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary       // ← white arrow in dark
      : Colors.black,       // ← black arrow in light
  collapsedIconColor: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.secondary       // ← white arrow in dark
      : Colors.black,       // ← black arrow in light
                initiallyExpanded: _isInformationExpanded,
                onExpansionChanged: (expanded) =>
                    setState(() => _isInformationExpanded = expanded),
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
                    Icons.person,
                    _selectedMenu == 'Person References',
                  ),
                  _buildDrawerItem(
                    'Other Information',
                    Icons.perm_device_information,
                    _selectedMenu == 'Other Information',
                  ),
                ],
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Employee ID:",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _userDetails?['employee']?['employeeId']?.toString() ??
                          'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.badge, size: 18, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 6),
                    Text(
                      _userDetails?['employee']?['designation']?['desigCode'] ??
                          'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.apartment, size: 18, color: Theme.of(context).iconTheme.color),
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
        return FamilyBackgroundWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Educational Background':
        return EducationalBackgroundWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Civil Service Eligibility':
        return CivilServiceWidget(token: widget.token, employeeId: _employeeId);
      case 'Work Experience':
        return WorkExperienceWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Voluntary Work':
        return VoluntaryWorkWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Learning and Development':
        return LearningDevelopmentWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Person References':
        return PersonReferenceWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Other Information':
        return OtherInformationWidget(
          token: widget.token,
          employeeId: _employeeId,
        );
      case 'Daily Time Record':
        return _buildDailyTimeRecordCard();
      case 'Payroll':
        return PayrollWidget(
          token: widget.token,
          baseUrl: widget.baseUrl,
          userId: _userDetails?['employee']?['id'] ?? 'N/A',
        );
      case 'Loan':
        return LoanWidget(
          token: widget.token,
          baseUrl: widget.baseUrl,
          userId: _userDetails?['employee']?['employeeId'] ?? 'N/A',
        );
      default:
        return _buildPersonalInformationCard();
    }
  }

  // ─── Personal Information Card ────────────────────────────────────────────
  Widget _buildPersonalInformationCard() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
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
                  'PERSONAL INFORMATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final employee = _userDetails?['employee'];
                    if (employee != null) {
                      setState(() {
                        _personalInfoData = {
                          'lastName': employee['lastName'] ?? '',
                          'firstName': employee['firstName'] ?? '',
                          'middleName': employee['middleName'] ?? '',
                          'suffix': employee['suffix'] ?? '',
                          'sex': employee['sex'] ?? '',
                          'photoUrl': employee['photoUrl'] ?? '',
                          'civilStatus': employee['civilStatus'] ?? '',
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
                          'employmentStatus':
                              employee['employmentStatus'] ?? 'true',
                        };
                      });
                      _showEditPersonalInfoDialog();
                    }
                  },
                  child: const Icon(Icons.edit, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Information ──
                  _buildViewSectionHeader(
                    'Basic Information',
                    Icons.person_outline,
                  ),
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
                  // ── Contact Information ──
                  _buildViewSectionHeader(
                    'Contact Information',
                    Icons.contact_phone_outlined,
                  ),
                  _buildInfoFieldInline(
                    'Telephone No.',
                    _userDetails?['employee']?['telephoneNo'],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoFieldInline(
                    'Mobile No.',
                    _userDetails?['employee']?['mobileNo'],
                  ),
                  const SizedBox(height: 20),

                  // ── Permanent Address ──
                  _buildViewSectionHeader(
                    'Permanent Address',
                    Icons.home_outlined,
                  ),
                  _buildInfoFieldInline(
                    'Permanent Address',
                    [
                          _userDetails?['employee']?['houseNo'],
                          _userDetails?['employee']?['street'],
                          _userDetails?['employee']?['village'],
                          _userDetails?['employee']?['barangay'],
                          _userDetails?['employee']?['municipality'],
                          _userDetails?['employee']?['province'],
                          _userDetails?['employee']?['zipCode'],
                        ]
                        .where((v) => v != null && v.toString().isNotEmpty)
                        .join(', '),
                  ),
                  const SizedBox(height: 20),
                  // ── Residential Address ──
                  _buildViewSectionHeader(
                    'Residential Address',
                    Icons.location_on_outlined,
                  ),
                  _buildInfoFieldInline(
                    'Residential Address',
                    [
                          _userDetails?['employee']?['resHouseNo'],
                          _userDetails?['employee']?['resStreet'],
                          _userDetails?['employee']?['resVillage'],
                          _userDetails?['employee']?['resBarangay'],
                          _userDetails?['employee']?['resMunicipality'],
                          _userDetails?['employee']?['resProvince'],
                          _userDetails?['employee']?['resZipCode'],
                        ]
                        .where((v) => v != null && v.toString().isNotEmpty)
                        .join(', '),
                  ),
                  const SizedBox(height: 20),
                  //email address
                  _buildViewSectionHeader(
                    'Email Address',
                    Icons.email_outlined,
                  ),
                  _buildInfoFieldInline(
                    'Email Address',
                    _userDetails?['email'],
                  ),
                  const SizedBox(height: 20),
                  // ── Government IDs ──
                  _buildViewSectionHeader(
                    'Government IDs',
                    Icons.badge_outlined,
                  ),
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
  return Builder(
    builder: (context) => ListTile(
      leading: Icon(
       icon,
  color: isSelected
      ? Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
          : Theme.of(context).primaryColor            // ← dark green in light
      : Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]
          : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
         color: isSelected
        ? Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.secondary  // ← light grey-green in dark
            : Theme.of(context).primaryColor            // ← dark green in light
        : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300]
            : Colors.black87,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.4),
      onTap: () {
        setState(() => _selectedMenu = title);
        Navigator.pop(context);
      },
    ),
  );
}

  // ─── Shared Field Helpers ─────────────────────────────────────────────────

  Widget _buildViewSectionHeader(String title, IconData icon) => Builder(
    builder: (context) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, 
          color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF587CA5)                         // ←  in dark
                    : Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF587CA5)                         // ←  in dark
                    : Theme.of(context).primaryColor,  
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    ),
  );

  Widget _buildInfoFieldInline(String label, dynamic value) {
    String displayValue = 'N/A';
    if (value != null &&
        value.toString().isNotEmpty &&
        value.toString() != 'null') {
      displayValue = value.toString();
    }
    return Builder(
      builder: (context) => Column(
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
            style: TextStyle(
              fontSize: 15,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}