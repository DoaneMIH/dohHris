import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/services/auth_service.dart';
import 'package:mobile_application/services/user_profile_cache.dart';
import 'package:mobile_application/services/token_manager.dart';
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
    Key? key,
    required this.photoUrl,
    required this.baseUrl,
    required this.token,
    required this.userName,
    required this.radius,
  }) : super(key: key);

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
    setState(() { _isLoading = true; _hasError = false; });

    try {
      String fullPhotoUrl;
      if (widget.photoUrl!.startsWith('http')) {
        fullPhotoUrl = widget.photoUrl!;
      } else if (widget.photoUrl!.startsWith('/employee/image/')) {
        fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
      } else {
        fullPhotoUrl = '${widget.baseUrl ?? ''}/employee/image/${widget.photoUrl}';
      }

      final token = TokenManager().token ?? widget.token;

      final response = await http.get(
        Uri.parse(fullPhotoUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() { _imageBytes = response.bodyBytes; _isLoading = false; });
        }
      } else {
        if (mounted) setState(() { _hasError = true; _isLoading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
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
          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
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
        ? widget.userName.trim().split(' ')
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


// ════════════════════════════════════════════════════════════════════════════
// Homepage
// ════════════════════════════════════════════════════════════════════════════
class Homepage extends StatefulWidget {
  final String token;
  final String baseUrl;

  const Homepage({
    super.key,
    required this.token,
    required this.baseUrl,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _userService = UserService();

  Map<String, dynamic>? _userDetails;
  bool _isFetchingPhoto = false;

  // ── Real-time clock ──────────────────────────────────────────────────────
  DateTime _currentDateTime = DateTime.now();
  late Timer _timer;

  String? get _photoUrl => _userDetails?['employee']?['photoUrl']?.toString();
  String  get _userName => (_userDetails?['name'] ?? 'User').toString();

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    // Start real-time clock — updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentDateTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ── Date/Time helpers ────────────────────────────────────────────────────

  String _monthName(int m) =>
      ['January','February','March','April','May','June',
       'July','August','September','October','November','December'][m - 1];

  // ────────────────────────────────────────────────────────────────────────
  Future<void> _fetchUserData() async {
    if (_isFetchingPhoto) return;
    if (mounted) setState(() => _isFetchingPhoto = true);

    try {
      final token = TokenManager().token ?? widget.token;
      final result = await _userService.getUserDetails(token);

      if (result['success']) {
        final data = result['data'];
        if (data != null && mounted) {
          setState(() => _userDetails = data);
          UserProfileCache.instance.setFromUserDetails(data);
        }
      }
    } catch (_) {
      // Silently ignore
    } finally {
      if (mounted) setState(() => _isFetchingPhoto = false);
    }
  }

  // ─── Reset / Change Password Dialog ──────────────────────────────────────
  void _showResetPasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController     = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew     = true;
    bool obscureConfirm = true;
    bool isLoading      = false;

    String? newPasswordError;
    String? confirmPasswordError;

    bool hasMinLength(String p)   => p.length >= 8;
    bool hasSpecialChar(String p) =>
        RegExp(r'[!@#\$%^&*(),.?\":{}|<>_\-+=\[\]\\;/~`]').hasMatch(p);

    String? validateNew(String v) {
      if (v.isEmpty) return 'Please enter a new password.';
      if (!hasMinLength(v)) return 'Must be at least 8 characters.';
      if (!hasSpecialChar(v)) return 'Must contain at least 1 special character.';
      return null;
    }

    String? validateConfirm(String newP, String confirm) {
      if (confirm.isEmpty) return 'Please confirm your new password.';
      if (newP != confirm) return 'Passwords do not match.';
      return null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDs) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            Widget buildField({
              required TextEditingController controller,
              required bool obscure,
              required VoidCallback onToggle,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: errorText != null
                          ? (isDark ? const Color(0xFF3C2020) : const Color(0xFFFFF0F0))
                          : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F4F3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: errorText != null
                            ? const BorderSide(color: Colors.red, width: 1)
                            : BorderSide(
                                color: isDark ? const Color(0xFF424242) : Colors.transparent,
                              ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: errorText != null ? Colors.red : Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                        onPressed: onToggle,
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.error_outline, size: 13, color: Colors.red),
                      const SizedBox(width: 4),
                      Flexible(child: Text(errorText, style: const TextStyle(fontSize: 11, color: Colors.red))),
                    ]),
                  ],
                ],
              );
            }

            Widget buildStrength(String password) {
              if (password.isEmpty) return const SizedBox.shrink();
              Widget rule(bool met, String label) => Row(children: [
                Icon(
                  met ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 13,
                  color: met ? Theme.of(context).primaryColor : Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(
                  fontSize: 11,
                  color: met ? Theme.of(context).primaryColor : Colors.grey[600],
                )),
              ]);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  rule(hasMinLength(password), 'At least 8 characters'),
                  const SizedBox(height: 2),
                  rule(hasSpecialChar(password), 'At least 1 special character (e.g. @, #, !)'),
                ]),
              );
            }

            Future<void> onSave() async {
              final current = currentPasswordController.text.trim();
              final newPass = newPasswordController.text;
              final confirm = confirmPasswordController.text;

              if (current.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter your current password.'),
                  backgroundColor: Colors.orange,
                ));
                return;
              }
              final nErr = validateNew(newPass);
              final cErr = validateConfirm(newPass, confirm);
              setDs(() { newPasswordError = nErr; confirmPasswordError = cErr; });
              if (nErr != null || cErr != null) return;

              setDs(() => isLoading = true);
              final result = await _userService.changePassword(
                widget.token,
                currentPassword: current,
                newPassword: newPass,
              );
              setDs(() => isLoading = false);
              if (!mounted) return;

              if (result['success']) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Password changed successfully.'),
                  backgroundColor: Theme.of(context).primaryColor,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['error'] ?? 'Failed to change password.'),
                  backgroundColor: Colors.red,
                ));
              }
            }

            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.pop(dialogContext),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  // Body
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
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildField(
                          controller: currentPasswordController,
                          obscure: obscureCurrent,
                          hint: 'Current password',
                          onToggle: () => setDs(() => obscureCurrent = !obscureCurrent),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Set New Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildField(
                          controller: newPasswordController,
                          obscure: obscureNew,
                          hint: 'New password',
                          errorText: newPasswordError,
                          onToggle: () => setDs(() => obscureNew = !obscureNew),
                          onChanged: (v) => setDs(() {
                            if (newPasswordError != null) newPasswordError = validateNew(v);
                          }),
                        ),
                        buildStrength(newPasswordController.text),
                        const SizedBox(height: 14),
                        Text(
                          'Confirm New Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildField(
                          controller: confirmPasswordController,
                          obscure: obscureConfirm,
                          hint: 'Confirm new password',
                          errorText: confirmPasswordError,
                          onToggle: () => setDs(() => obscureConfirm = !obscureConfirm),
                          onChanged: (v) => setDs(() {
                            if (confirmPasswordError != null) {
                              confirmPasswordError = validateConfirm(newPasswordController.text, v);
                            }
                          }),
                        ),
                        const SizedBox(height: 22),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: isLoading ? null : onSave,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF3A3A3A) : Colors.grey[300],
                                foregroundColor: isDark ? Colors.white : Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ]),
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

  // ─── Header Avatar ────────────────────────────────────────────────────────
  Widget _buildHeaderAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<String>(
        color: Theme.of(context).scaffoldBackgroundColor,
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) {
          if (value == 'reset_password') _showResetPasswordDialog();
          else if (value == 'logout') AuthService.logout(context);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'reset_password',
            child: Row(children: [
              Icon(
                Icons.lock_reset,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF587CA5)
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ]),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(children: const [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(fontSize: 14, color: Colors.red)),
            ]),
          ),
        ],
        child: ValueListenableBuilder<int>(
          valueListenable: UserProfileCache.instance.photoVersion,
          builder: (context, version, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: UserProfileCache.instance.photoUrl,
              builder: (context, photoUrl, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: UserProfileCache.instance.userName,
                  builder: (context, name, __) {
                    return _DisplayOnlyPhoto(
                      key: ValueKey('avatar_$version'),
                      photoUrl: photoUrl ?? _photoUrl,
                      baseUrl: widget.baseUrl,
                      token: widget.token,
                      userName: name.isNotEmpty ? name : _userName,
                      radius: 17,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ─── Calendar Card ────────────────────────────────────────────────────────
  Widget _buildDateTimeCard(bool isDark) {
    final now        = _currentDateTime;
    final firstDay   = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // weekday: Mon=1 … Sun=7 → we want Sun=0 offset
    final startOffset = (firstDay.weekday % 7); // Sun=0,Mon=1,...,Sat=6

    final prevMonthDays = DateTime(now.year, now.month, 0).day;

    final headerColor = const Color(0xFF1F2A45);
    final todayColor  = Theme.of(context).primaryColor;
    const dayHeaders  = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    // Build flat list of cells (leading ghost days + current month days)
    final totalCells = startOffset + daysInMonth;
    final rows       = (totalCells / 7).ceil();

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // ── Month / Year header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_monthName(now.month)} ${now.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              children: [
                // ── Day-of-week headers ──────────────────────────────
                Row(
                  children: dayHeaders.map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 6),
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300], height: 1),
                const SizedBox(height: 8),

                // ── Day grid ─────────────────────────────────────────
                for (int r = 0; r < rows; r++) ...[
                  Row(
                    children: List.generate(7, (c) {
                      final cellIndex = r * 7 + c;
                      final day       = cellIndex - startOffset + 1;

                      // Ghost days from previous/next month
                      if (day < 1 || day > daysInMonth) {
                        int ghostDay;
                        if (day < 1) {
                          ghostDay = prevMonthDays + day;
                        } else {
                          ghostDay = day - daysInMonth;
                        }
                        return Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                '$ghostDay',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final isToday = day == now.day;

                      return Expanded(
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            width: 34,
                            height: 34,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: todayColor,
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
                                  color: isToday
                                      ? Colors.white
                                      : (isDark ? Colors.grey[300] : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF1F2A45),
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
                      Text('DOH WV CHD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.9)),
                      Text('HRIS', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ],
                  ),
                ],
              ),
              actions: [
                // Theme toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                    );
                  },
                ),
                _buildHeaderAvatar(),
              ],
            ),



            // ── Body ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Human Resources Information System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildDateTimeCard(isDark),
                 
                ],
              ),

              
            ),
          ],
        ),
      ),
    );
  }
}