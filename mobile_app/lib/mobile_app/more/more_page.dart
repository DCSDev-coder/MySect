import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../notifications/notifications_page.dart';
import 'invoices_page.dart';
import 'report_page.dart';
import 'calendar_page.dart';
import 'bank_accounts_page.dart';
import 'referral_page.dart';
import 'company_page.dart';
import 'settings_page.dart';
import 'logout_page.dart';
import 'profile_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/YourSectComp.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildProfileHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionHeader('FINANCIAL TOOLS'),
                    _buildSectionContainer(
                      children: [
                        _buildMoreItem(
                          context: context,
                          title: 'Invoices',
                          iconData: Icons.description_outlined,
                          iconColor: Colors.blue,
                          iconBgColor: Colors.blue.shade50,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoicesPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Reports',
                          iconData: Icons.bar_chart,
                          iconColor: Colors.green,
                          iconBgColor: Colors.green.shade50,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Bank accounts',
                          iconData: Icons.credit_card_outlined,
                          iconColor: Colors.orange,
                          iconBgColor: Colors.orange.shade50,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BankAccountsPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'E-commerce integrations',
                          iconData: Icons.shopping_bag_outlined,
                          iconColor: Colors.purple,
                          iconBgColor: Colors.purple.shade50,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('CONNECT & INBOX'),
                    _buildSectionContainer(
                      children: [
                        _buildMoreItem(
                          context: context,
                          title: 'Mailbox',
                          iconData: Icons.mail_outline,
                          iconColor: Colors.teal,
                          iconBgColor: Colors.teal.shade50,
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Calendar',
                          iconData: Icons.calendar_today_outlined,
                          iconColor: Colors.purple,
                          iconBgColor: Colors.purple.shade50,
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
                          title: 'Advisory calls',
                          iconData: Icons.call_outlined,
                          iconColor: Colors.blue,
                          iconBgColor: Colors.blue.shade50,
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Referrals',
                          iconData: Icons.card_giftcard_outlined,
                          iconColor: Colors.pink,
                          iconBgColor: Colors.pink.shade50,
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
                              'EARN \$200',
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
                        _buildMoreItem(
                          context: context,
                          title: 'Company',
                          iconData: Icons.business_center_outlined,
                          iconColor: Colors.indigo,
                          iconBgColor: Colors.indigo.shade50,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CompanyPage(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildMoreItem(
                          context: context,
                          title: 'Settings',
                          iconData: Icons.settings_outlined,
                          iconColor: Colors.grey.shade700,
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
                          iconColor: Colors.red,
                          iconBgColor: Colors.red.shade50,
                          isDestructive: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LogoutPage(),
                            ),
                          ),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.black87,
                size: 24,
              ),
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
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing,
                  ],
                ],
              ),
            ),
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
