import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_top_header.dart';
import 'calendar_page.dart';
import 'referral_page.dart';
import 'company_page.dart';
import 'settings_page.dart';
import '../authentication/login_page.dart';
import 'profile_page.dart';
import '../services/company_service.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 16),
                    _buildSectionHeader('TOOLS & SERVICES'),
                    _buildSectionContainer(
                      children: [
                        _buildMoreItem(
                          context: context,
                          title: 'Calendar',
                          iconData: Icons.calendar_today_outlined,
                          iconColor: Colors.black,
                          iconBgColor: Colors.grey.shade200,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CalendarPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Referrals',
                          iconData: Icons.card_giftcard_outlined,
                          iconColor: Colors.black,
                          iconBgColor: Colors.grey.shade200,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'EARN RM200',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferralPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('APP PREFERENCES'),
                    _buildSectionContainer(
                      children: [
                        ListenableBuilder(
                          listenable: CompanyService.instance,
                          builder: (context, _) {
                            final comp = CompanyService.instance.selectedCompany;
                            return _buildMoreItem(
                              context: context,
                              title: 'Company',
                              iconData: Icons.business_center_outlined,
                              iconColor: Colors.black,
                              iconBgColor: Colors.grey.shade200,
                              trailing: comp != null
                                  ? Container(
                                      constraints: const BoxConstraints(maxWidth: 130),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        comp.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF062AAE),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : null,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CompanyPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Settings',
                          iconData: Icons.settings_outlined,
                          iconColor: Colors.black,
                          iconBgColor: Colors.grey.shade200,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Log out',
                          iconData: Icons.logout_outlined,
                          iconColor: Colors.black,
                          iconBgColor: Colors.grey.shade200,
                          isDestructive: true,
                          onTap: () => _showLogoutBottomSheet(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF062AAE),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out? You will need to enter your credentials again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF062AAE),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Yes, Log out',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigo.shade50,
              child: Text(
                'EM',
                style: GoogleFonts.poppins(
                  color: Colors.indigo.shade700,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elly Melissa',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Personal Account • Active',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72.0, right: 16.0),
      child: Divider(color: Colors.grey.shade100, height: 1, thickness: 1),
    );
  }

  Widget _buildMoreItem({
    required BuildContext context,
    required String title,
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
    Widget? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(iconData, color: iconColor, size: 22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(child: trailing),
              const SizedBox(width: 6),
            ] else ...[
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.chevron_right,
              color: isDestructive ? Colors.red : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
