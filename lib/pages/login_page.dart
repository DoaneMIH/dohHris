import 'package:flutter/material.dart';
import 'package:mobile_application/pages/navigation.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('\n🚀 [LoginPage] Login button pressed');

    if (!_formKey.currentState!.validate()) {
      print('❌ [LoginPage] Form validation failed');
      return;
    }

    print('✅ [LoginPage] Form validation passed');
    print('📧 [LoginPage] Email: ${_emailController.text.trim()}');

    setState(() {
      _isLoading = true;
    });

    try {
      print('⏳ [LoginPage] Calling AuthService.login()...');
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('📦 [LoginPage] Result received from AuthService');
      print('📦 [LoginPage] Success: ${result['success']}');

      if (mounted) {
        if (result['success']) {
          final data = result['data'];
          final token = data['token'];

          print(
            '✅ [LoginPage] Login successful, navigating to UserDetailsPage...',
          );
          print('🎫 [LoginPage] Token will be used to fetch profile');

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => UserDetailsPageContent(
          //       token: token,
          //       baseUrl: ApiConfig.baseUrl,
          //     ),
          //   ),
          // );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                token: token,
                baseUrl: ApiConfig.baseUrl,
                initialIndex: 1, // 0 = Home, 1 = Profile
              ),
            ),
          );
        } else {
          print('❌ [LoginPage] Login failed, showing error message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🏁 [LoginPage] Login process completed\n');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF046307);

    InputDecoration _fieldDecoration({
      required String hint,
      required IconData icon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, color: green),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFEFEFEF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: green, width: 1.2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', height: 200),
                    const SizedBox(height: 14),
                    Text(
                      'Login to your account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(
                        hint: 'Email',
                        icon: Icons.person,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _fieldDecoration(
                        hint: 'Password', 
                        icon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: green,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // // FORGOT / RESET
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Wrap(
                    //     crossAxisAlignment: WrapCrossAlignment.center,
                    //     children: [
                    //       Text(
                    //         'Forgot Password? ',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.grey.shade700,
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           // UI only — put your reset navigation here later if needed
                    //           // Navigator.pushNamed(context, MyRoutes.resetPage);
                    //         },
                    //         child: const Text(
                    //           'Reset',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             color: green,
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(height: 16),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          disabledBackgroundColor: green.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // DIVIDER: "or continue with"
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Divider(
                    //         color: Colors.grey.shade300,
                    //         height: 1,
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text(
                    //         'or continue with',
                    //         style: TextStyle(
                    //           fontSize: 11,
                    //           color: Colors.grey.shade700,
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Divider(
                    //         color: Colors.grey.shade300,
                    //         height: 1,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 18),

                    // SIGN UP
                    // Wrap(
                    //   crossAxisAlignment: WrapCrossAlignment.center,
                    //   children: [
                    //     Text(
                    //       "Don't have an account? ",
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.grey.shade700,
                    //       ),
                    //     ),
                    //     GestureDetector(
                    //       onTap: () {
                    //         // UI only — connect to your signup route if you have it
                    //         // Navigator.pushNamed(context, MyRoutes.signupPage);
                    //       },
                    //       child: const Text(
                    //         'Sign up',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: green,
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
