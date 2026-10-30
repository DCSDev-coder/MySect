import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_top_header.dart';
import 'secretary_verification_page.dart';

class SecretaryForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const SecretaryForgotPasswordPage({super.key, this.initialEmail});

  @override
  State<SecretaryForgotPasswordPage> createState() => _SecretaryForgotPasswordPageState();
}

class _SecretaryForgotPasswordPageState extends State<SecretaryForgotPasswordPage> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email address.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecretaryVerificationPage(
          email: email,
          isLoginVerification: false,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'name@sectpro.com.my',
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined,
          size: 18,
          color: Color(0xFF062AAE),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF062AAE),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _handleSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF062AAE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Send 6-Digit Code',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: RichText(
          text: TextSpan(
            text: 'Remembered your password? ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            children: [
              TextSpan(
                text: 'Back to Login',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF062AAE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Desktop Side-by-Side Layout
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Brand & Illustration Panel
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/mysect_logo.png',
                              width: 130,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/forgot_password.png',
                              height: 145,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Account Recovery',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Verify your registered email to reset your secretarial console access password.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Divider
                    Container(
                      width: 1,
                      color: Colors.grey.shade100,
                    ),

                    // Right Form Panel
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter your registered email address to receive a 6-digit verification code.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Email Field
                                Text(
                                  'EMAIL ADDRESS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildEmailField(),

                                const SizedBox(height: 20),

                                // Submit Button
                                _buildSubmitButton(),

                                const SizedBox(height: 18),

                                // Back to Login
                                _buildBackToLoginLink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Stacked Layout (Preserved original phone design)
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
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
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const AppTopHeader(
                      showNotificationBell: false,
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(height: isKeyboardOpen ? 4 : 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: const BoxDecoration(),
                      clipBehavior: Clip.hardEdge,
                      height: isKeyboardOpen ? 0 : 170,
                      child: OverflowBox(
                        minHeight: 0,
                        maxHeight: 170,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/forgot_password.png',
                          height: 170,
                        ),
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
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter your email address to receive a 6-digit verification code.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'EMAIL ADDRESS',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildEmailField(),

                              const SizedBox(height: 32),

                              _buildSubmitButton(),

                              const SizedBox(height: 24),

                              _buildBackToLoginLink(),

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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _buildDesktopLayout(context, constraints);
        } else {
          return _buildMobileLayout(context, constraints);
        }
      },
    );
  }
}
