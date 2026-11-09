import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/secretary_compliance_service.dart';
import '../../services/secretary_document_service.dart';
import '../companies/company_documents_folder_page.dart';

class SecretaryDashboardTab extends StatefulWidget {
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
  State<SecretaryDashboardTab> createState() => _SecretaryDashboardTabState();
}

class _SecretaryDashboardTabState extends State<SecretaryDashboardTab> {
  int _selectedMilestoneTab = 0; // 0: Upcoming Deadlines, 1: My Tasks

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final isDesktop = screenWidth >= 850;

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
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 12 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Greeting
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
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
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                service.profile.firmName,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.onNavigateToSubscription != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onNavigateToSubscription,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 12,
                                vertical: isMobile ? 6 : 7,
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
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'RM 50 / SSM Co.',
                                    style: GoogleFonts.poppins(
                                      fontSize: isMobile ? 10.5 : 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // SSM Portfolio Billing Hero Strip
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                                      'SSM Portfolio Billing',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
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
                                '${companies.length} Active Entities',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                fontSize: 11.5,
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
                                'Unlimited Cloud Vault & MBRS Filing',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                            if (widget.onNavigateToSubscription != null) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: widget.onNavigateToSubscription,
                                child: Text(
                                  'Billing →',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF93C5FD),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // TOP 4 KPI STAT CARDS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final card1 = _buildKpiCard(
                        icon: Icons.apartment_rounded,
                        value: '4',
                        label: 'Companies',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: widget.onNavigateToCompanies ?? () {},
                      );
                      final card2 = _buildKpiCard(
                        icon: Icons.checklist_rounded,
                        value: '5',
                        label: 'Pending Tasks',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: widget.onNavigateToQueue,
                      );
                      final card3 = _buildKpiCard(
                        icon: Icons.warning_amber_rounded,
                        value: '4',
                        label: 'Overdue Items',
                        trendIcon: Icons.warning_amber_rounded,
                        trendColor: const Color(0xFFDC2626),
                        valueColor: const Color(0xFFDC2626),
                        onTap: widget.onNavigateToQueue,
                      );
                      final card4 = _buildKpiCard(
                        icon: Icons.calendar_today_rounded,
                        value: '0',
                        label: 'Upcoming Deadlines',
                        trendIcon: Icons.trending_up_rounded,
                        trendColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF0F172A),
                        onTap: widget.onNavigateToCompanies ?? () {},
                      );

                      if (constraints.maxWidth < 620) {
                        return Column(
                          children: [
                            Row(children: [card1, const SizedBox(width: 10), card2]),
                            const SizedBox(height: 10),
                            Row(children: [card3, const SizedBox(width: 10), card4]),
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

                  const SizedBox(height: 16),

                  // SECTIONS (Desktop: 2x2 grid, Mobile: Clean, prioritized list with distinct card formats)
                  if (isDesktop) ...[
                    // Row 1 on Desktop: Company Health & Recent Activity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCompanyHealthCard(context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRecentActivityCard(showAll: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2 on Desktop: Upcoming Deadlines & My Tasks
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildUpcomingDeadlinesCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMyTasksCard()),
                      ],
                    ),
                  ] else ...[
                    // Distinct Mobile Flow:
                    // 1. Company Health (Portfolio Status with navigation chevrons)
                    _buildCompanyHealthCard(context),
                    const SizedBox(height: 14),

                    // 2. Tabbed Statutory Milestones & Tasks (Distinct: Calendar Date Tiles vs Action Checklist)
                    _buildMilestonesAndTasksCard(),
                    const SizedBox(height: 14),

                    // 3. Recent Activity (Distinct: Chronological Timeline Feed)
                    _buildRecentActivityCard(showAll: false),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Top KPI Card Widget
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
          borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white, size: 16),
                        ),
                      ),
                      Icon(trendIcon, color: trendColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      letterSpacing: -0.2,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                    fontSize: 14.5,
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionText,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  // Company Health Card (Distinct Portfolio style with navigation arrows)
  Widget _buildCompanyHealthCard(BuildContext context) {
    return _buildSectionCard(
      title: 'Company Health',
      actionText: 'View all',
      onAction: widget.onNavigateToCompanies,
      content: Column(
        children: [
          _buildCompanyHealthItem(
            context: context,
            companyName: 'Data Center Specialists Sdn Bhd (M)',
            ssmNo: '202101039281 (1429581-X)',
            statusBadge: '2 Pending',
            statusBadgeColor: const Color(0xFFD97706),
            statusBadgeBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            iconBg: const Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          _buildCompanyHealthItem(
            context: context,
            companyName: 'Test Enterprise',
            ssmNo: '202401999999 (999999-T)',
            overdueCount: 1,
            statusBadge: 'Payment Due',
            statusBadgeColor: const Color(0xFFDC2626),
            statusBadgeBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFE11D48),
            iconBg: const Color(0xFFFEE2E2),
          ),
        ],
      ),
    );
  }

  // Combined Tabbed Card for Mobile (Deadlines & Tasks)
  Widget _buildMilestonesAndTasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // Segmented selector header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentButton(
                      title: 'Deadlines',
                      count: '4',
                      icon: Icons.calendar_month_rounded,
                      isSelected: _selectedMilestoneTab == 0,
                      onTap: () => setState(() => _selectedMilestoneTab = 0),
                    ),
                    const SizedBox(width: 4),
                    _buildSegmentButton(
                      title: 'My Tasks',
                      count: '4',
                      icon: Icons.check_circle_outline_rounded,
                      isSelected: _selectedMilestoneTab == 1,
                      onTap: () => setState(() => _selectedMilestoneTab = 1),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _selectedMilestoneTab == 0
                    ? widget.onNavigateToCompanies
                    : widget.onNavigateToQueue,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content based on selected tab: Calendar blocks vs Action checklist
          if (_selectedMilestoneTab == 0)
            _buildDeadlineItemsList()
          else
            _buildTaskItemsList(),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required String count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF062AAE) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF062AAE).withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. DEADLINES: Distinct Calendar Date Tile format
  Widget _buildDeadlineItemsList() {
    return Column(
      children: [
        _buildCalendarDeadlineItem(
          day: '14',
          month: 'MAY',
          title: 'Section 68 Annual Return Lodgement',
          company: 'Data Center Specialists Sdn Bhd',
          urgency: 'High',
          urgencyColor: const Color(0xFFDC2626),
          urgencyBg: const Color(0xFFFEE2E2),
        ),
        const SizedBox(height: 8),
        _buildCalendarDeadlineItem(
          day: '10',
          month: 'JUN',
          title: 'Section 46 Notice of Office Address',
          company: 'C2 Coffee + Candle',
          urgency: 'Medium',
          urgencyColor: const Color(0xFFD97706),
          urgencyBg: const Color(0xFFFEF3C7),
        ),
        const SizedBox(height: 8),
        _buildCalendarDeadlineItem(
          day: '30',
          month: 'JUN',
          title: 'Tax Return (CP204) Revision',
          company: 'Data Center Specialists Sdn Bhd',
          urgency: 'Normal',
          urgencyColor: const Color(0xFF059669),
          urgencyBg: const Color(0xFFECFDF5),
        ),
        const SizedBox(height: 8),
        _buildCalendarDeadlineItem(
          day: '20',
          month: 'JUL',
          title: 'Financial Statements Submission',
          company: '5Luxe Scents Co.',
          urgency: 'Medium',
          urgencyColor: const Color(0xFF2563EB),
          urgencyBg: const Color(0xFFEFF6FF),
        ),
      ],
    );
  }

  Widget _buildCalendarDeadlineItem({
    required String day,
    required String month,
    required String title,
    required String company,
    required String urgency,
    required Color urgencyColor,
    required Color urgencyBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Calendar Date Block
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF062AAE),
                    height: 1.0,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  company,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
            decoration: BoxDecoration(
              color: urgencyBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              urgency,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: urgencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. MY TASKS: Distinct Actionable Task Tiles with Action Buttons
  Widget _buildTaskItemsList() {
    return Column(
      children: [
        _buildActionTaskItem(
          icon: Icons.rate_review_rounded,
          iconColor: const Color(0xFF062AAE),
          iconBg: const Color(0xFFEFF6FF),
          title: 'Review Section 68 CTCs',
          company: 'Data Center Specialists • 2 Pending',
          actionLabel: 'Review →',
          actionColor: const Color(0xFF062AAE),
          onAction: widget.onNavigateToQueue,
        ),
        const SizedBox(height: 8),
        _buildActionTaskItem(
          icon: Icons.upload_file_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBg: const Color(0xFFEFF6FF),
          title: 'Section 68 Lodgement',
          company: 'Data Center Specialists • Due 14 May',
          actionLabel: 'Lodge →',
          actionColor: const Color(0xFF2563EB),
          onAction: widget.onNavigateToQueue,
        ),
        const SizedBox(height: 8),
        _buildActionTaskItem(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFEE2E2),
          title: 'Statutory Compliance Audit',
          company: 'Test Enterprise • May 2026 Plan Due',
          actionLabel: 'Audit →',
          actionColor: const Color(0xFFDC2626),
          onAction: widget.onNavigateToQueue,
        ),
        const SizedBox(height: 8),
        _buildActionTaskItem(
          icon: Icons.edit_note_rounded,
          iconColor: const Color(0xFF059669),
          iconBg: const Color(0xFFECFDF5),
          title: 'Notice of Registered Office',
          company: 'C2 Coffee + Candle • Form 46',
          actionLabel: 'File →',
          actionColor: const Color(0xFF059669),
          onAction: widget.onNavigateToQueue,
        ),
      ],
    );
  }

  Widget _buildActionTaskItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String company,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  company,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              actionLabel,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Upcoming Deadlines Card (for Desktop)
  Widget _buildUpcomingDeadlinesCard() {
    return _buildSectionCard(
      title: 'Upcoming Deadlines',
      actionText: 'View all',
      onAction: widget.onNavigateToCompanies,
      content: _buildDeadlineItemsList(),
    );
  }

  // My Tasks Card (for Desktop)
  Widget _buildMyTasksCard() {
    return _buildSectionCard(
      title: 'My Tasks',
      actionText: 'View all',
      onAction: widget.onNavigateToQueue,
      content: _buildTaskItemsList(),
    );
  }

  // 3. RECENT ACTIVITY: Distinct Chronological Timeline Trail
  Widget _buildRecentActivityCard({bool showAll = true}) {
    final activities = [
      (
        'Share Transfer marked as completed',
        'Sarah Ahmad',
        '25 Apr, 5:30 PM',
      ),
      (
        'New director added for Data Center Specialists',
        'Lim Mei Ling',
        '24 Apr, 10:15 PM',
      ),
      (
        'Board Resolution uploaded — C2 Coffee + Candle',
        'Azman bin Ibrahim',
        '23 Apr, 7:00 PM',
      ),
      if (showAll) ...[
        (
          'AGM Preparation started for 5Luxe Scents Co.',
          'David Wong',
          '23 Apr, 12:45 AM',
        ),
        (
          'Statutory compliance lock audit — Test Enterprise',
          'Lim Mei Ling',
          '21 Apr, 6:20 PM',
        ),
      ],
    ];

    return _buildSectionCard(
      title: 'Recent Activity',
      content: Column(
        children: [
          for (int i = 0; i < activities.length; i++)
            _buildTimelineItem(
              title: activities[i].$1,
              author: activities[i].$2,
              time: activities[i].$3,
              isLast: i == activities.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String author,
    required String time,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFF062AAE),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$author • $time',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Company Health Item (Portfolio Card with Navigation Chevron)
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
        borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.apartment_rounded, color: iconColor, size: 17),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    if (overdueCount > 0)
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
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
                          fontSize: 10.5,
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
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusBadge,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusBadgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
