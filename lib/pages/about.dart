import 'package:flutter/material.dart';
import 'package:mobile_application/pages/login_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  // ─── Logout ───────────────────────────────────────────────────────────────
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // ─── Reset Password Dialog ────────────────────────────────────────────────
  void _showResetPasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    bool _obscureCurrent = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                          'Reset Password',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                        // Current Password
                        const Text('Enter Current Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F4F3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
                              onPressed: () => setDialogState(() => _obscureCurrent = !_obscureCurrent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // New Password
                        const Text('Set New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F4F3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
                              onPressed: () => setDialogState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password
                        const Text('Confirm New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F4F3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF00674F), width: 1.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
                              onPressed: () => setDialogState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Buttons ──
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00674F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () {
                                  final current = _currentPasswordController.text;
                                  final newPass = _newPasswordController.text;
                                  final confirm = _confirmPasswordController.text;

                                  if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.orange),
                                    );
                                    return;
                                  }
                                  if (newPass != confirm) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }

                                  // TODO: call your password reset API here
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset successfully'), backgroundColor: Colors.green),
                                  );
                                },
                                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
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
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bar ──────────────────────────────────────────────
            Container(
              color: const Color(0xFF00674F),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 3,
                left: 25,
                right: 8,
                bottom: 3,
              ),
              child: Row(
                children: [
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
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('DOH WV CHD', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.9)),
                        Text('HRIS', textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      ],
                    ),
                  ),

                  // ── Popup menu: Reset Password + Logout ──
                  PopupMenuButton<String>(
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
                     icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2C5F4F).withOpacity(0.08),
                          border: Border.all(color: const Color(0xFF2C5F4F).withOpacity(0.25), width: 2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'DOH WV CHD HRIS',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C5F4F), letterSpacing: 0.8),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Human Resource Information System',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400),
                    ),

                    const SizedBox(height: 10),

                    _buildBadge('Version 1.0.0', const Color(0xFF2C5F4F)),

                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),

                    // ── Contact & Organization Info ──────────────────────
                    _buildInfoRow(Icons.business, 'Organization', 'Department of Health\nWestern Visayas Center for Health Development'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on_outlined, 'Address', 'Q. Abeto St., Mandurriao, Iloilo City, 5000'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.phone_outlined, 'Contact', '(033) 321-2356'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email_outlined, 'Email', 'dohro6@doh.gov.ph'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.language_outlined, 'Website', 'www.doh.gov.ph'),

                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),

                    // ── App Details ──────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'APPLICATION DETAILS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow('App Version', '1.0.0'),
                    _buildDetailRow('Platform', 'Android / iOS'),
                    _buildDetailRow('Developer', 'ICTU — DOH WV CHD'),
                    _buildDetailRow('Last Updated', 'June 2025'),
                    _buildDetailRow('Data Privacy', 'RA 10173 Compliant'),

                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Footer
                    Text(
                      '© ${DateTime.now().year} DOH WV CHD. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Developed by ICTU',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────────

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2C5F4F)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}