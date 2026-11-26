import '../../widgets/secretary_sidebar.dart';
import '../../widgets/secretary_desktop_top_bar.dart';
import '../shell/main_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/secretary_login_page.dart';
import '../auth/secretary_two_factor_auth_page.dart';

class SecretarySettingsPage extends StatefulWidget {
  final bool isEmbedded;

  const SecretarySettingsPage({super.key, this.isEmbedded = false});

  @override
  State<SecretarySettingsPage> createState() => _SecretarySettingsPageState();
}

class _SecretarySettingsPageState extends State<SecretarySettingsPage> {
  bool _whatsappEnabled = true;
  bool _emailEnabled = true;
  bool _passcodeEnabled = true;

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Password',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Password changed successfully!',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF062AAE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _togglePasscode() {
    setState(() {
      _passcodeEnabled = !_passcodeEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Passcode protection ${_passcodeEnabled ? 'enabled' : 'disabled'}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 26),
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete Account',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: const Color(0xFF3B4058),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you certain you wish to permanently\ndelete your account?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B4058),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SecretaryLoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'DELETE',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD3455B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/trashcan.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        final bodyScroll = SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    _buildSectionHeader('NOTIFICATIONS'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.chat_rounded,
                            iconColor: const Color(0xFF059669),
                            iconBg: const Color(0xFFECFDF5),
                            title: 'Whatsapp update',
                            trailing: Switch(
                              value: _whatsappEnabled,
                              onChanged: (val) =>
                                  setState(() => _whatsappEnabled = val),
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF062AAE),
                            ),
                            onTap: () {
                              setState(
                                () => _whatsappEnabled = !_whatsappEnabled,
                              );
                            },
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          _buildListTile(
                            icon: Icons.mark_email_unread_rounded,
                            iconColor: const Color(0xFF062AAE),
                            iconBg: const Color(0xFFEFF6FF),
                            title: 'Email notifications',
                            trailing: Switch(
                              value: _emailEnabled,
                              onChanged: (val) =>
                                  setState(() => _emailEnabled = val),
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF062AAE),
                            ),
                            onTap: () {
                              setState(() => _emailEnabled = !_emailEnabled);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('SECURITY'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFF062AAE),
                            iconBg: const Color(0xFFEFF6FF),
                            title: 'Change password',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onTap: _showChangePasswordSheet,
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          _buildListTile(
                            icon: Icons.verified_user_outlined,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFEFF6FF),
                            title: 'Two-Factor Authentication',
                            subtitle: 'Send email',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SecretaryTwoFactorAuthPage(),
                                ),
                              );
                            },
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          _buildListTile(
                            icon: Icons.pin_outlined,
                            iconColor: const Color(0xFF7C3AED),
                            iconBg: const Color(0xFFF3E8FF),
                            title: 'Passcode protection',
                            subtitle: _passcodeEnabled ? 'Enabled' : 'Disabled',
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onTap: _togglePasscode,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('ACCOUNT'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: _buildListTile(
                        icon: Icons.delete_outline_rounded,
                        iconColor: const Color(0xFFDC2626),
                        iconBg: const Color(0xFFFEE2E2),
                        title: 'Delete account',
                        titleColor: const Color(0xFFDC2626),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                        onTap: _confirmDeleteAccount,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );

        if (widget.isEmbedded) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: bodyScroll,
          );
        }

        if (isDesktop) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Row(
              children: [
                SecretarySidebar(
                  currentIndex: 4,
                  onSelectTab: (idx) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainNavigationShell(initialIndex: idx),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      SecretaryDesktopTopBar(
                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Color(0xFF0F172A),
                          ),
                          tooltip: 'Back to Workspace',
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: 'Firm Settings & Security',
                        badgeText: 'SSM LICENSED',
                      ),
                      Expanded(child: bodyScroll),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Firm Settings & Security',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: bodyScroll,
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    Color iconColor = const Color(0xFF062AAE),
    Color iconBg = const Color(0xFFEFF6FF),
    required String title,
    Color titleColor = const Color(0xFF0F172A),
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
