import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../models/ssm_filing_model.dart';
import '../models/company_model.dart';
import '../services/ssm_filing_service.dart';
import '../services/company_service.dart';
import '../transactions/ssm_filing_detail_page.dart';
import '../transactions/submit_ssm_filing_page.dart';
import '../widgets/app_top_header.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final int _selectedIndex = 4;
  String _selectedTab = 'Current';

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  DateTime _parseDate(String dateStr, [DateTime? fallback]) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  String _getMonthAbbr(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendar',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: CompanyService.instance,
                          builder: (context, _) {
                            final compName =
                                CompanyService.instance.selectedCompany?.name ??
                                'Data Center Specialists Sdn Bhd (M)';
                            return Text(
                              compName,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Segmented Filter Tabs (Current / Past / Upcoming)
                    Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: _selectedTab == 'Current'
                                ? Alignment.centerLeft
                                : _selectedTab == 'Past'
                                ? Alignment.center
                                : Alignment.centerRight,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: FractionallySizedBox(
                              widthFactor: 1 / 3,
                              heightFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(21),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildSegment('Current')),
                              Expanded(child: _buildSegment('Past')),
                              Expanded(child: _buildSegment('Upcoming')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dynamic Compliance Calendar Items
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        SsmFilingService.instance,
                        CompanyService.instance,
                      ]),
                      builder: (context, _) {
                        final filings = SsmFilingService.instance.filings;
                        final company = CompanyService.instance.selectedCompany;

                        if (_selectedTab == 'Current') {
                          return _buildCurrentTab(filings, company);
                        } else if (_selectedTab == 'Past') {
                          return _buildPastTab(filings, company);
                        } else {
                          return _buildUpcomingTab(filings, company);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Quick Action: Upload SSM Filing
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubmitSsmFilingPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 18,
                          color: Color(0xFF062AAE),
                        ),
                        label: Text(
                          'Upload New SSM Filing',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF062AAE),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF062AAE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSegment(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF062AAE) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(List<SsmFiling> filings, Company? company) {
    final activeFilings =
        filings
            .where((f) => f.status != SsmFilingStatus.completed)
            .toList();

    return Column(
      children: [
        // 1. Live SSM Filings from SsmFilingService
        ...activeFilings.map((filing) {
          final date = _parseDate(filing.deadline, filing.submittedDate);
          final month = _getMonthAbbr(date);
          final day = '${date.day}';

          String timeRemaining;
          Color pillBgColor;
          Color pillTextColor;
          String actionText;
          Color actionColor;

          switch (filing.status) {
            case SsmFilingStatus.secretaryReplied:
              timeRemaining = 'Action Required';
              pillBgColor = const Color(0xFFFEE2E2);
              pillTextColor = const Color(0xFFDC2626);
              actionText = 'Update Now';
              actionColor = const Color(0xFFDC2626);
              break;
            case SsmFilingStatus.waitingSecretaryReview:
              timeRemaining = 'Waiting for Secretary';
              pillBgColor = const Color(0xFFFEF3C7);
              pillTextColor = const Color(0xFFD97706);
              actionText = 'Track Filing';
              actionColor = const Color(0xFF062AAE);
              break;
            case SsmFilingStatus.waitingClientApproval:
              timeRemaining = 'Approval Needed';
              pillBgColor = const Color(0xFFEFF6FF);
              pillTextColor = const Color(0xFF2563EB);
              actionText = 'Review & Sign';
              actionColor = const Color(0xFF2563EB);
              break;
            case SsmFilingStatus.lodgedToSsm:
              timeRemaining = 'Lodged to SSM';
              pillBgColor = const Color(0xFFF5F3FF);
              pillTextColor = const Color(0xFF7C3AED);
              actionText = 'Track SSM';
              actionColor = const Color(0xFF7C3AED);
              break;
            case SsmFilingStatus.completed:
              timeRemaining = 'Completed';
              pillBgColor = const Color(0xFFECFDF5);
              pillTextColor = const Color(0xFF059669);
              actionText = 'View Receipt';
              actionColor = const Color(0xFF059669);
              break;
          }

          // If secretary replied with clarification, show the snippet
          String? clarificationSnippet;
          if (filing.status == SsmFilingStatus.secretaryReplied) {
            final secMsg = filing.messages.lastWhere(
              (m) => m.isFromSecretary,
              orElse: () => filing.messages.last,
            );
            clarificationSnippet = secMsg.text;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildDeadlineCard(
              month: month,
              day: day,
              title: filing.title,
              subtitle:
                  clarificationSnippet != null
                      ? 'Secretary Query: $clarificationSnippet'
                      : 'Statutory filing for ${filing.companyName} (${filing.referenceNo})',
              timeRemaining: timeRemaining,
              pillBgColor: pillBgColor,
              pillTextColor: pillTextColor,
              actionText: actionText,
              actionColor: actionColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SsmFilingDetailPage(filingId: filing.id),
                  ),
                );
              },
            ),
          );
        }),

        // 2. Upcoming Statutory Deadline: Annual Corporate Tax Return (Form C)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'NOV',
            day: '30',
            title: 'Complete Corporate Tax Return (Form C)',
            subtitle:
                'Statutory filing to LHDN Malaysia for Assessment Year 2026',
            timeRemaining: 'In 34 days',
            pillBgColor: const Color(0xFFFFF7A3),
            pillTextColor: const Color(0xFFFF8A00),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 68 Annual Return',
                        initialTitle: 'Annual Corporate Tax Return (Form C)',
                        initialDescription:
                            'Submission of Form C tax computation and audited accounts to LHDN Malaysia.',
                      ),
                ),
              );
            },
          ),
        ),

        // 3. Upcoming Statutory Deadline: Financial Statements Lodgement (Section 259)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'DEC',
            day: '31',
            title: 'Financial Statements & Reports Lodgement',
            subtitle:
                'Annual submission of audited accounts to SSM under Section 259',
            timeRemaining: 'In 65 days',
            pillBgColor: const Color(0xFFE8F5E9),
            pillTextColor: const Color(0xFF2E7D32),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 68 Annual Return',
                        initialTitle: 'Audited Financial Statements Lodgement',
                        initialDescription:
                            'Audited financial statements and directors statutory report for SSM lodgement.',
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPastTab(List<SsmFiling> filings, Company? company) {
    final completedFilings =
        filings
            .where((f) => f.status == SsmFilingStatus.completed)
            .toList();

    return Column(
      children: [
        // Completed SSM filings from service
        ...completedFilings.map((filing) {
          final date = _parseDate(filing.deadline, filing.submittedDate);
          final month = _getMonthAbbr(date);
          final day = '${date.day}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildDeadlineCard(
              month: month,
              day: day,
              title: filing.title,
              subtitle:
                  'Official SSM Receipt generated (${filing.referenceNo})',
              timeRemaining: 'Completed & Lodged',
              pillBgColor: const Color(0xFFECFDF5),
              pillTextColor: const Color(0xFF059669),
              actionText: 'View Receipt',
              actionColor: const Color(0xFF059669),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SsmFilingDetailPage(filingId: filing.id),
                  ),
                );
              },
            ),
          );
        }),

        // Historical records
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'AUG',
            day: '31',
            title: 'Q2 SST-02 Service Tax Return',
            subtitle:
                'Lodged to Royal Malaysian Customs Department & SSM registers',
            timeRemaining: 'Completed',
            pillBgColor: Colors.grey.shade200,
            pillTextColor: Colors.grey.shade700,
            actionText: 'View Filing',
            actionColor: Colors.grey.shade700,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Q2 SST-02 Return is archived in Files > Accounting.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF062AAE),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'JUN',
            day: '14',
            title: 'Section 14 Incorporation Notice & Initial Resolutions',
            subtitle:
                'SSM Certificate of Incorporation & Company Registration issued',
            timeRemaining: 'Completed',
            pillBgColor: Colors.grey.shade200,
            pillTextColor: Colors.grey.shade700,
            actionText: 'View Filing',
            actionColor: Colors.grey.shade700,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Incorporation certificate is accessible under Files > Corporate.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF062AAE),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTab(List<SsmFiling> filings, Company? company) {
    return Column(
      children: [
        // 1. Next Year Annual Return (Section 68)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'JUN',
            day: '14',
            title: 'Section 68 Annual Return Lodgement 2027',
            subtitle:
                'Statutory annual return filing under Companies Act 2016',
            timeRemaining: 'In 230 days',
            pillBgColor: const Color(0xFFE3F2FD),
            pillTextColor: const Color(0xFF1565C0),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 68 Annual Return',
                        initialTitle: 'Section 68 Annual Return Lodgement 2027',
                        initialDescription:
                            'Early preparation of Annual Return 2027 and director declarations.',
                      ),
                ),
              );
            },
          ),
        ),

        // 2. Form E Employer Remittance Return
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'MAR',
            day: '31',
            title: 'Form E Employer Remittance Return',
            subtitle:
                'Annual employer remuneration return to LHDN Malaysia',
            timeRemaining: 'In 155 days',
            pillBgColor: const Color(0xFFFFF7A3),
            pillTextColor: const Color(0xFFFF8A00),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 68 Annual Return',
                        initialTitle: 'Form E Employer Remittance Return',
                        initialDescription:
                            'Employer annual remuneration submission for Inland Revenue Board.',
                      ),
                ),
              );
            },
          ),
        ),

        // 3. Annual Director Written Resolution
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'DEC',
            day: '31',
            title: 'Annual Director Written Resolution',
            subtitle:
                'Statutory adoption of financial statements under Section 340',
            timeRemaining: 'In 246 days',
            pillBgColor: const Color(0xFFE3F2FD),
            pillTextColor: const Color(0xFF1565C0),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 58 Notice of Director Change',
                        initialTitle: 'Annual Director Written Resolution',
                        initialDescription:
                            'Circulation and execution of annual directors written resolution.',
                      ),
                ),
              );
            },
          ),
        ),

        // 4. Annual Licence & Permit Statutory Renewal
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildDeadlineCard(
            month: 'MAY',
            day: '15',
            title: 'Annual Licence & Permit Statutory Renewal',
            subtitle:
                'Renewal of municipal & commercial business operating licences',
            timeRemaining: 'In 200 days',
            pillBgColor: const Color(0xFFE8F5E9),
            pillTextColor: const Color(0xFF2E7D32),
            actionText: 'File Now',
            actionColor: const Color(0xFF062AAE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const SubmitSsmFilingPage(
                        initialFilingType: 'Section 46 Change of Registered Address',
                        initialTitle: 'Annual Licence & Permit Statutory Renewal',
                        initialDescription:
                            'Premises operating licence renewal and local council filing.',
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineCard({
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String timeRemaining,
    Color pillBgColor = const Color(0xFFFFF7A3),
    Color pillTextColor = const Color(0xFFFF8A00),
    String actionText = 'File Now',
    Color actionColor = const Color(0xFF062AAE),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Box
                Container(
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD71920),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          month,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),

            // Bottom Status Pill & Action Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: pillTextColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeRemaining,
                        style: GoogleFonts.poppins(
                          color: pillTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText,
                      style: GoogleFonts.poppins(
                        color: actionColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: actionColor,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
