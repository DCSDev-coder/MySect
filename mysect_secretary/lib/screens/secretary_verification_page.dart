import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_top_header.dart';
import 'main_navigation_shell.dart';
import 'secretary_login_page.dart';

class SecretaryVerificationPage extends StatefulWidget {
  final String email;
  final bool isLoginVerification;

  const SecretaryVerificationPage({
    super.key,
    this.email = 'meiling.lim@sectpro.com.my',
    this.isLoginVerification = true,
  });

  @override
  State<SecretaryVerificationPage> createState() => _SecretaryVerificationPageState();
}

class _SecretaryVerificationPageState extends State<SecretaryVerificationPage> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // If user pasted a 6-digit code into one box
    if (value.length >= 6) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = digits[i];
        }
        _focusNodes[5].requestFocus();
        return;
      }
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Widget _buildOtpBox(int index) {
    return Expanded(
      child: Container(
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _controllers[index].text.isEmpty &&
                index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) => _onChanged(value, index),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF062AAE), width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the full 6-digit verification code.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (widget.isLoginVerification) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationShell(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
          (route) => false,
        );
      } else {
        _showResetPasswordSheet();
      }
    });
  }

  void _showResetPasswordSheet() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock_reset_rounded,
                                    color: Color(0xFF062AAE),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Reset Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(sheetContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code verified! Please create a new secure password for your secretary account.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setSheetState(() => obscureNew = !obscureNew);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF062AAE), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setSheetState(() => obscureConfirm = !obscureConfirm);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF062AAE), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (newPasswordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please fill in both password fields.',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  backgroundColor: const Color(0xFFDC2626),
                                ),
                              );
                              return;
                            }
                            if (newPasswordController.text != confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Passwords do not match.',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  backgroundColor: const Color(0xFFDC2626),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(sheetContext);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SecretaryLoginPage(),
                              ),
                              (route) => false,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password reset successful! Please log in with your new credentials.',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF062AAE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save & Return to Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FD),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 650;
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Container(
                  margin: isDesktop ? const EdgeInsets.all(24) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isDesktop ? 24 : 0),
                    boxShadow: isDesktop
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppTopHeader(showNotificationBell: false),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(flex: 1),
                              Center(
                                child: Image.asset(
                                  'assets/verify_code.png',
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Enter verification code',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.isLoginVerification
                                    ? 'Enter the 6-digit code we sent to\nyour email to verify your account.\n${widget.email}'
                                    : 'Enter the 6-digit code we sent to\nyour email to reset your password.\n${widget.email}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  6,
                                  (index) => _buildOtpBox(index),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: GestureDetector(
                                  onTap: _secondsRemaining == 0
                                      ? () {
                                          _startTimer();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'A new 6-digit verification code has been sent to ${widget.email}.',
                                                style: GoogleFonts.poppins(fontSize: 12),
                                              ),
                                              backgroundColor: const Color(0xFF062AAE),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Didn't receive the code? ",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _secondsRemaining > 0
                                              ? 'Resend code in ${_secondsRemaining}s'
                                              : 'Resend code',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _secondsRemaining > 0
                                                ? Colors.grey[500]
                                                : const Color(0xFF062AAE),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isVerifying ? null : _handleVerify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF062AAE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isVerifying
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Verify and continue',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const Spacer(flex: 3),
                            ],
                          ),
                        ),
                      ),
                    ],
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
