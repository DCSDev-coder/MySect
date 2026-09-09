import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notifications/notifications_page.dart';
import '../home/home_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import '../transactions/transaction_data.dart';
import '../files/document_viewer_page.dart';

class DocumentNeededPage extends StatelessWidget {
  const DocumentNeededPage({super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/mysect_logo.png',
                    width: 110,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 24,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Document Needed',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...allTransactions.where((t) => t.documentsNeeded).map((transaction) {
                    return _DocumentCard(
                      badgeText: 'Action Required',
                      badgeBgColor: Colors.red[100]!,
                      badgeTextColor: Colors.red[800]!,
                      timeText: 'Due: ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                      progressText: '',
                      progressColor: Colors.transparent,
                      title: transaction.title,
                      subtitle: 'Please upload the requested document.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentViewerPage(
                              fileName: transaction.title,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String timeText;
  final String progressText;
  final Color progressColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.timeText,
    required this.progressText,
    required this.progressColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.poppins(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  timeText,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/pdf.png', width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progressText.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  progressText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: progressColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
