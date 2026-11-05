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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isEmbedded && !isDesktop) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Firm Settings & Security',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
                    const SizedBox(height: 12),
                    Text(
                      'NOTIFICATIONS',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.chat_outlined,
                            title: 'Whatsapp update',
                            trailing: Switch(
                              value: _whatsappEnabled,
                              onChanged: (val) =>
                                  setState(() => _whatsappEnabled = val),
                              activeThumbColor: Colors.black,
                            ),
                            onTap: () {
                              setState(
                                () => _whatsappEnabled = !_whatsappEnabled,
                              );
                            },
                          ),
                          Divider(color: Colors.grey.shade200, height: 1),
                          _buildListTile(
                            icon: Icons.mark_email_unread_outlined,
                            title: 'Email notifications',
                            trailing: Switch(
                              value: _emailEnabled,
                              onChanged: (val) =>
                                  setState(() => _emailEnabled = val),
                              activeThumbColor: Colors.black,
                            ),
                            onTap: () {
                              setState(() => _emailEnabled = !_emailEnabled);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SECURITY',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.lock_outline,
                            title: 'Change password',
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.black,
                            ),
                            onTap: _showChangePasswordSheet,
                          ),
                          Divider(color: Colors.grey.shade200, height: 1),
                          _buildListTile(
                            icon: Icons.security_outlined,
                            title: 'Two-Factor Authentication',
                            subtitle: 'Send email',
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.black,
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
                          Divider(color: Colors.grey.shade200, height: 1),
                          _buildListTile(
                            icon: Icons.pin_outlined,
                            title: 'Passcode protection',
                            subtitle: _passcodeEnabled ? 'Enabled' : 'Disabled',
                            onTap: _togglePasscode,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ACCOUNT',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: _buildListTile(
                        icon: Icons.delete_outline,
                        title: 'Delete account',
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                        onTap: _confirmDeleteAccount,
                      ),
                    ),
                    const SizedBox(height: 40),
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
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(
            top: true,
            bottom: false,
            child: bodyScroll,
          ),
        );
      },
    );
  }

  Widget _buildListTile({
    IconData? icon,
    String? imagePath,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(imagePath, width: 28, height: 28)
            else if (icon != null)
              Icon(icon, color: Colors.black, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 12,
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
