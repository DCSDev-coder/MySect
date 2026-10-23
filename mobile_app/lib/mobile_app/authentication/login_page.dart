import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import 'slide_transition_route.dart';

import 'verification_page.dart';
import '../widgets/app_top_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const AppTopHeader(showNotificationBell: false),
                        SizedBox(height: isKeyboardOpen ? 4 : 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          clipBehavior: Clip.hardEdge,
                          height: isKeyboardOpen ? 0 : 180,
                          child: OverflowBox(
                            minHeight: 0,
                            maxHeight: 180,
                            alignment: Alignment.center,
                            child: Image.asset('assets/login.png', height: 180),
                          ),
                        ),
                        SizedBox(height: isKeyboardOpen ? 8 : 16),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24.0,
                                24.0,
                                24.0,
                                24.0 + (isKeyboardOpen ? 0 : bottomInset),
                              ),
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMAIL ADDRESS',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'name@company.com',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E50FF),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'PASSWORD',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Enter your secure password',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[600],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E50FF),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      SlideTransitionRoute(
                                        page: const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E50FF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text;

                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please enter email address',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (password.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please enter password',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (email != 'test@gmail.com') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Account not found with this email',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (password != 'Dtct+1234') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Incorrect password',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(context).push(
                                      SlideTransitionRoute(
                                        page: const VerificationPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E50FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      SlideTransitionRoute(
                                        page: const SignupPage(),
                                      ),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'New to MySect? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Create Account',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E50FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
}
