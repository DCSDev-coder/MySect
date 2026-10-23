import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_top_header.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
                        SizedBox(height: isKeyboardOpen ? 4 : 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          clipBehavior: Clip.hardEdge,
                          height: isKeyboardOpen ? 0 : 200,
                          child: OverflowBox(
                            minHeight: 0,
                            maxHeight: 200,
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/forgot_password.png',
                              height: 200,
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
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address to receive a password reset link.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      decoration: InputDecoration(
                        hintText: 'name@company.com',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
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
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'A password reset link has been sent to your email address.',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF1E50FF),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(24),
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
                          'Send Reset Link',
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
                          Navigator.of(context).pop();
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Remembered your password? ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            children: [
                              TextSpan(
                                text: 'Back to Login',
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
