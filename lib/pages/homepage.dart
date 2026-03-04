import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/pages/login_page.dart';
import 'package:mobile_application/services/user_profile_cache.dart';
import 'package:mobile_application/services/token_manager.dart';
import 'package:mobile_application/services/user_service.dart';


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
      // ── Exact same URL-building logic as user_details.dart ──
      String fullPhotoUrl;
      if (widget.photoUrl!.startsWith('http')) {
        fullPhotoUrl = widget.photoUrl!;
      } else if (widget.photoUrl!.startsWith('/employee/image/')) {
        fullPhotoUrl = '${widget.baseUrl ?? ''}${widget.photoUrl}';
      } else {
        fullPhotoUrl = '${widget.baseUrl ?? ''}/employee/image/${widget.photoUrl}';
      }

      // ── TokenManager is primary source, widget.token is fallback ──
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

    // Fallback: initials
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

  // ── Exact same data fields + field paths as user_details.dart ──
  Map<String, dynamic>? _userDetails; // stores full result['data']
  bool _isFetchingPhoto = false;

  // Convenience getters — mirrors user_details.dart's own access pattern
  String? get _photoUrl  => _userDetails?['employee']?['photoUrl']?.toString();
  String  get _userName  => (_userDetails?['name'] ?? 'User').toString();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ─── Fetch user data and push into UserProfileCache ──────────────────────
  // Runs once on init as a seed — after this, user_details.dart keeps
  // UserProfileCache updated automatically via setFromUserDetails().
  Future<void> _fetchUserData() async {
    if (_isFetchingPhoto) return;
    if (mounted) setState(() => _isFetchingPhoto = true);

    try {
      final token = TokenManager().token ?? widget.token;
      final result = await _userService.getUserDetails(token);

      // ── Truthy check — same as user_details.dart: if (result['success']) ──
      if (result['success']) {
        final data = result['data'];
        if (data != null && mounted) {
          setState(() => _userDetails = data);
          // ── Push into cache so ValueListenableBuilder rebuilds avatar ──
          UserProfileCache.instance.setFromUserDetails(data);
        }
      }
    } catch (_) {
      // Silently ignore — avatar falls back to initials
    } finally {
      if (mounted) setState(() => _isFetchingPhoto = false);
    }
  }


  // ─── Logout ───────────────────────────────────────────────────────────────
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: errorText != null ? const Color(0xFFFFF0F0) : const Color(0xFFF0F4F3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: errorText != null ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: errorText != null ? Colors.red : const Color(0xFF00674F),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
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
                Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 13, color: met ? const Color(0xFF00674F) : Colors.grey),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(fontSize: 11, color: met ? const Color(0xFF00674F) : Colors.grey[600])),
              ]);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  rule(hasMinLength(password),   'At least 8 characters'),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Password changed successfully.'),
                  backgroundColor: Colors.green,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['error'] ?? 'Failed to change password.'),
                  backgroundColor: Colors.red,
                ));
              }
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00674F),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.pop(dialogContext),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter Current Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        buildField(controller: currentPasswordController, obscure: obscureCurrent, hint: 'Current password', onToggle: () => setDs(() => obscureCurrent = !obscureCurrent)),
                        const SizedBox(height: 14),
                        const Text('Set New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        buildField(
                          controller: newPasswordController,
                          obscure: obscureNew,
                          hint: 'New password',
                          errorText: newPasswordError,
                          onToggle: () => setDs(() => obscureNew = !obscureNew),
                          onChanged: (v) => setDs(() { if (newPasswordError != null) newPasswordError = validateNew(v); }),
                        ),
                        buildStrength(newPasswordController.text),
                        const SizedBox(height: 14),
                        const Text('Confirm New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        buildField(
                          controller: confirmPasswordController,
                          obscure: obscureConfirm,
                          hint: 'Confirm new password',
                          errorText: confirmPasswordError,
                          onToggle: () => setDs(() => obscureConfirm = !obscureConfirm),
                          onChanged: (v) => setDs(() { if (confirmPasswordError != null) confirmPasswordError = validateConfirm(newPasswordController.text, v); }),
                        ),
                        const SizedBox(height: 22),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00674F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: isLoading ? null : onSave,
                              child: isLoading
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[400],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

Widget _buildHeaderAvatar() {
  return Padding(
    padding: const EdgeInsets.only(right: 12),
    child: PopupMenuButton<String>(
      color: Colors.white,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'reset_password') _showResetPasswordDialog();
        else if (value == 'logout') _logout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'reset_password',
          child: Row(children: const [
            Icon(Icons.lock_reset, color: Color(0xFF00674F), size: 20),
            SizedBox(width: 10),
            Text('Reset Password', style: TextStyle(fontSize: 14)),
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

      // ✅ listen for photo updates
        child: ValueListenableBuilder<int>(
        valueListenable: UserProfileCache.instance.photoVersion, // ✅ NEW
        builder: (context, version, _) {
          return ValueListenableBuilder<String?>(
            valueListenable: UserProfileCache.instance.photoUrl,
            builder: (context, photoUrl, _) {
              return ValueListenableBuilder<String>(
                valueListenable: UserProfileCache.instance.userName,
                builder: (context, name, __) {
                  return _DisplayOnlyPhoto(
                    key: ValueKey('avatar_$version'), // ✅ NEW — forces full rebuild + re-fetch
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

  @override
  Widget build(BuildContext context) {
  
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bar — pixel-identical to UserDetailsPage AppBar ──
            AppBar(
  iconTheme: const IconThemeData(color: Colors.white),
  automaticallyImplyLeading: false,
  backgroundColor: const Color(0xFF2C5F4F),
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
                    actions: [
                  _buildHeaderAvatar(),
                    ],
              
            ),
      
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 100,
                  color: const Color(0xFF2C5F4F),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Home Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'This is a placeholder for your home page content.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.blue),
                          title: const Text('Coming Soon'),
                          subtitle: const Text('Home page features will be added here'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.dashboard, color: Colors.orange),
                          title: const Text('Dashboard'),
                          subtitle: const Text('View your statistics and insights'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.notifications, color: Colors.red),
                          title: const Text('Notifications'),
                          subtitle: const Text('Stay updated with latest alerts'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Extra padding for bottom nav
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}