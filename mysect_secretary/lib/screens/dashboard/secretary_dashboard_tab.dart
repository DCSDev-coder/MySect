import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/secretary_compliance_service.dart';
import '../../services/secretary_document_service.dart';
import '../companies/company_documents_folder_page.dart';

class SecretaryDashboardTab extends StatelessWidget {
  final VoidCallback onNavigateToQueue;
  final VoidCallback? onNavigateToCompanies;
  final VoidCallback? onNavigateToSubscription;

  const SecretaryDashboardTab({
    super.key,
    required this.onNavigateToQueue,
    this.onNavigateToCompanies,
    this.onNavigateToSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([
        service,
        SecretaryComplianceService.instance,
      ]),
      builder: (context, _) {
        final companies = service.clientCompanies;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: () => service.syncFromBackend(),
            color: const Color(0xFF062AAE),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${service.profile.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.profile.firmName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (onNavigateToSubscription != null)
                          InkWell(
                            onTap: onNavigateToSubscription,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF062AAE),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF062AAE)
                                        .withValues(alpha: 0.20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'RM 50 / SSM Co.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // SSM Portfolio Billing Hero Strip
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF062AAE), Color(0xFF031666)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF062AAE).withValues(alpha: 0.16),
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
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 15,
                                    color: Color(0xFF93C5FD),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'SSM Portfolio Billing (Flat RM 50 / Co)',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${companies.length} Active SSM Entities',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'RM ${(companies.length * 50).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/ month',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF93C5FD),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Full access included: Unlimited TM Cloud Vault & Statutory MBRS Engine.',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                            if (onNavigateToSubscription != null)
                              InkWell(
                                onTap: onNavigateToSubscription,
                                child: Text(
                                  'Company Billing →',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF93C5FD),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // TOP 4 KPI STAT CARDS (Matching user screenshot)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final card1 = _buildKpiCard(
                        icon: Icons.apartment_rounded,
                        value: '4',
                        label: 'Companies',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: onNavigateToCompanies ?? () {},
                      );
                      final card2 = _buildKpiCard(
                        icon: Icons.checklist_rounded,
                        value: '5',
                        label: 'Pending Tasks',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: onNavigateToQueue,
                      );
                      final card3 = _buildKpiCard(
                        icon: Icons.warning_amber_rounded,
                        value: '4',
                        label: 'Overdue Items',
                        trendIcon: Icons.warning_amber_rounded,
                        trendColor: const Color(0xFFDC2626),
                        valueColor: const Color(0xFFDC2626), // Highlight in Red
                        onTap: onNavigateToQueue,
                      );
                      final card4 = _buildKpiCard(
                        icon: Icons.calendar_today_rounded,
                        value: '0',
                        label: 'Upcoming Deadlines',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: onNavigateToCompanies ?? () {},
                      );

                      if (constraints.maxWidth < 620) {
                        return Column(
                          children: [
                            Row(children: [card1, const SizedBox(width: 12), card2]),
                            const SizedBox(height: 12),
                            Row(children: [card3, const SizedBox(width: 12), card4]),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          card1,
                          const SizedBox(width: 14),
                          card2,
                          const SizedBox(width: 14),
                          card3,
                          const SizedBox(width: 14),
                          card4,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // MIDDLE SECTION: Company Health & Recent Activity (Side-by-side on desktop)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 850;

                      final companyHealthCard = _buildSectionCard(
                        title: 'Company Health',
                        actionText: 'View all ↗',
                        onAction: onNavigateToCompanies,
                        content: Column(
                          children: [
                            _buildCompanyHealthItem(
                              context: context,
                              companyName: 'Data Center Specialists Sdn Bhd (M)',
                              ssmNo: '202101039281 (1429581-X)',
                              statusBadge: '2 Pending Review',
                              statusBadgeColor: const Color(0xFFD97706),
                              statusBadgeBg: const Color(0xFFFEF3C7),
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                            ),
                            const SizedBox(height: 10),
                            _buildCompanyHealthItem(
                              context: context,
                              companyName: 'C2 Coffee + Candle',
                              ssmNo: '202001019482 (1382941-T)',
                              statusBadge: 'Good (Compliant)',
                              statusBadgeColor: const Color(0xFF059669),
                              statusBadgeBg: const Color(0xFFECFDF5),
                              iconColor: const Color(0xFF059669),
                              iconBg: const Color(0xFFECFDF5),
                            ),
                            const SizedBox(height: 10),
                            _buildCompanyHealthItem(
                              context: context,
                              companyName: '5Luxe Scents Co.',
                              ssmNo: '202201082918 (1482910-P)',
                              overdueCount: 1,
                              statusBadge: 'Action Needed',
                              statusBadgeColor: const Color(0xFFDC2626),
                              statusBadgeBg: const Color(0xFFFEE2E2),
                              iconColor: const Color(0xFFE11D48),
                              iconBg: const Color(0xFFFEE2E2),
                            ),
                            const SizedBox(height: 10),
                            _buildCompanyHealthItem(
                              context: context,
                              companyName: 'Test Enterprise',
                              ssmNo: '202401999999 (999999-T)',
                              overdueCount: 1,
                              statusBadge: 'Retainer Due',
                              statusBadgeColor: const Color(0xFFDC2626),
                              statusBadgeBg: const Color(0xFFFEE2E2),
                              iconColor: const Color(0xFFE11D48),
                              iconBg: const Color(0xFFFEE2E2),
                            ),
                          ],
                        ),
                      );

                      final recentActivityCard = _buildSectionCard(
                        title: 'Recent Activity',
                        content: Column(
                          children: [
                            _buildActivityItem(
                              icon: Icons.error_outline_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'Share Transfer marked as completed',
                              subtitle: 'Sarah Ahmad • 25 Apr 2026, 5:30 PM',
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              icon: Icons.person_add_alt_1_rounded,
                              iconColor: const Color(0xFF2563EB),
                              iconBg: const Color(0xFFEFF6FF),
                              title: 'New director added for Data Center Specialists',
                              subtitle: 'Lim Mei Ling • 24 Apr 2026, 10:15 PM',
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              icon: Icons.show_chart_rounded,
                              iconColor: const Color(0xFF64748B),
                              iconBg: const Color(0xFFF1F5F9),
                              title: 'Board Resolution uploaded — C2 Coffee + Candle',
                              subtitle: 'Azman bin Ibrahim • 23 Apr 2026, 7:00 PM',
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              icon: Icons.error_outline_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'AGM Preparation started for 5Luxe Scents Co.',
                              subtitle: 'David Wong • 23 Apr 2026, 12:45 AM',
                            ),
                            const SizedBox(height: 12),
                            _buildActivityItem(
                              icon: Icons.error_outline_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'Statutory compliance lock audit — Test Enterprise',
                              subtitle: 'Lim Mei Ling • 21 Apr 2026, 6:20 PM',
                            ),
                          ],
                        ),
                      );

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: companyHealthCard),
                            const SizedBox(width: 16),
                            Expanded(child: recentActivityCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          companyHealthCard,
                          const SizedBox(height: 16),
                          recentActivityCard,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // BOTTOM SECTION: Upcoming Deadlines & My Tasks (Side-by-side on desktop)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 850;

                      final upcomingDeadlinesCard = _buildSectionCard(
                        title: 'Upcoming Deadlines',
                        actionText: 'View all ↗',
                        onAction: onNavigateToCompanies,
                        content: Column(
                          children: [
                            _buildDeadlineItem(
                              icon: Icons.error_outline_rounded,
                              iconColor: const Color(0xFFDC2626),
                              iconBg: const Color(0xFFFEE2E2),
                              title: 'Section 68 Annual Return — Data Center Specialists',
                              subtitle: 'Data Center Specialists Sdn Bhd (M) • Due 14 May',
                              urgencyBadge: 'high',
                              urgencyColor: const Color(0xFFD97706),
                              urgencyBg: const Color(0xFFFEF3C7),
                            ),
                            const SizedBox(height: 12),
                            _buildDeadlineItem(
                              icon: Icons.calendar_today_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'Section 46 Notice of Office Address — C2 Coffee',
                              subtitle: 'C2 Coffee + Candle • Due 10 Jun',
                              urgencyBadge: 'medium',
                              urgencyColor: const Color(0xFF2563EB),
                              urgencyBg: const Color(0xFFEFF6FF),
                            ),
                            const SizedBox(height: 12),
                            _buildDeadlineItem(
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: const Color(0xFF059669),
                              iconBg: const Color(0xFFECFDF5),
                              title: 'Tax Return (CP204) Revision — Data Center Specialists',
                              subtitle: 'Data Center Specialists Sdn Bhd (M) • Due 30 Jun',
                              urgencyBadge: 'normal',
                              urgencyColor: const Color(0xFF059669),
                              urgencyBg: const Color(0xFFECFDF5),
                            ),
                            const SizedBox(height: 12),
                            _buildDeadlineItem(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'Financial Statements Submission — 5Luxe Scents',
                              subtitle: '5Luxe Scents Co. • Due 20 Jul',
                              urgencyBadge: 'medium',
                              urgencyColor: const Color(0xFF2563EB),
                              urgencyBg: const Color(0xFFEFF6FF),
                            ),
                          ],
                        ),
                      );

                      final myTasksCard = _buildSectionCard(
                        title: 'My Tasks',
                        actionText: 'View all ↗',
                        onAction: onNavigateToQueue,
                        content: Column(
                          children: [
                            _buildTaskItem(
                              icon: Icons.access_time_rounded,
                              iconColor: const Color(0xFF2563EB),
                              iconBg: const Color(0xFFEFF6FF),
                              title: 'Section 68 Annual Return Lodgement — Data Center Specialists',
                              subtitle: 'Data Center Specialists Sdn Bhd (M) • Due 14 May',
                              statusPill: 'In Progress',
                              statusColor: const Color(0xFF1D4ED8),
                              statusBg: const Color(0xFFDBEAFE),
                            ),
                            const SizedBox(height: 12),
                            _buildTaskItem(
                              icon: Icons.hourglass_empty_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                              title: 'Notice of Registered Office Lodgement — C2 Coffee',
                              subtitle: 'C2 Coffee + Candle • Lodged to SSM MBRS',
                              statusPill: 'Completed',
                              statusColor: const Color(0xFF059669),
                              statusBg: const Color(0xFFECFDF5),
                            ),
                            const SizedBox(height: 12),
                            _buildTaskItem(
                              icon: Icons.description_outlined,
                              iconColor: const Color(0xFF062AAE),
                              iconBg: const Color(0xFFEFF6FF),
                              title: 'Review Section 68 CTCs — Data Center Specialists',
                              subtitle: 'Data Center Specialists • 2 documents pending review',
                              statusPill: 'Review',
                              statusColor: const Color(0xFF062AAE),
                              statusBg: const Color(0xFFEFF6FF),
                            ),
                            const SizedBox(height: 12),
                            _buildTaskItem(
                              icon: Icons.done_all_rounded,
                              iconColor: const Color(0xFFDC2626),
                              iconBg: const Color(0xFFFEE2E2),
                              title: 'Statutory Compliance Audit — Test Enterprise',
                              subtitle: 'Test Enterprise • May 2026 Retainer Due (RM 50)',
                              statusPill: 'Action',
                              statusColor: const Color(0xFFDC2626),
                              statusBg: const Color(0xFFFEE2E2),
                            ),
                          ],
                        ),
                      );

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: upcomingDeadlinesCard),
                            const SizedBox(width: 16),
                            Expanded(child: myTasksCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          upcomingDeadlinesCard,
                          const SizedBox(height: 16),
                          myTasksCard,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Top KPI Card Widget (matches screenshot exactly)
  Widget _buildKpiCard({
    required IconData icon,
    required String value,
    required String label,
    required IconData trendIcon,
    required Color trendColor,
    required Color valueColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white, size: 18),
                        ),
                      ),
                      Icon(trendIcon, color: trendColor, size: 16),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section Card Container Wrapper
  Widget _buildSectionCard({
    required String title,
    String? actionText,
    VoidCallback? onAction,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      actionText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  // Company Health Item
  Widget _buildCompanyHealthItem({
    required BuildContext context,
    required String companyName,
    required String ssmNo,
    int overdueCount = 0,
    required String statusBadge,
    required Color statusBadgeColor,
    required Color statusBadgeBg,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDocumentsFolderPage(companyName: companyName),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.apartment_rounded, color: iconColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (overdueCount > 0)
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(text: '$ssmNo • '),
                            TextSpan(
                              text: '$overdueCount overdue',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        ssmNo,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusBadge,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: statusBadgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Recent Activity Item
  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 16),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Upcoming Deadline Item
  Widget _buildDeadlineItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String urgencyBadge,
    required Color urgencyColor,
    required Color urgencyBg,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 16),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: urgencyBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            urgencyBadge,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: urgencyColor,
            ),
          ),
        ),
      ],
    );
  }

  // My Tasks Item
  Widget _buildTaskItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String statusPill,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 16),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusPill,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
