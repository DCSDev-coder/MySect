import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/client_document_model.dart';
import '../services/secretary_compliance_service.dart';
import '../services/secretary_document_service.dart';
import 'document_review_detail_page.dart';
import 'company_documents_folder_page.dart';

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
        final companyLimit = service.companyLimit;
        final availableSlots = (companyLimit - companies.length).clamp(0, 9999);
        final usageRatio = (companies.length / companyLimit).clamp(0.0, 1.0);

        final pendingDocs = service.documents
            .where((d) => d.status == DocumentReviewStatus.pendingReview)
            .toList();
        final clarificationDocs = service.documents
            .where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: () => service.syncFromBackend(),
            color: const Color(0xFF062AAE),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title & Subtitle Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secretary Dashboard',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${service.profile.name} • ${service.profile.firmName}',
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF059669),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Active License',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // HERO FOCUS: Total Assigned Companies & Quota Capacity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF062AAE), Color(0xFF031666)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF062AAE).withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'MANAGED CLIENT PORTFOLIO',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF93C5FD),
                                            letterSpacing: 0.5,
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
                                        '${companies.length}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Companies Under Management',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.92),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Active corporate secretarial clients formally appointed to your practice.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: Colors.white.withValues(alpha: 0.78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (onNavigateToCompanies != null)
                              ElevatedButton.icon(
                                onPressed: onNavigateToCompanies,
                                icon: const Icon(
                                  Icons.business_rounded,
                                  size: 15,
                                  color: Color(0xFF062AAE),
                                ),
                                label: Text(
                                  'View Companies',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF062AAE),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quota Progress Bar
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pie_chart_outline_rounded,
                                        size: 14,
                                        color: Color(0xFF93C5FD),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Company Slot Quota (${service.currentPlan.name})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${companies.length} of $companyLimit slots used',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF34D399),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: usageRatio,
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.20),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF34D399),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$availableSlots slots available to onboard new client companies.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  if (onNavigateToSubscription != null)
                                    InkWell(
                                      onTap: onNavigateToSubscription,
                                      child: Text(
                                        'Expand Quota →',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 4 Summary Metrics (Company & Filings Focus)
                  Row(
                    children: [
                      _buildMetricTile(
                        title: 'Companies',
                        value: '${companies.length}',
                        subtitle: 'Portfolios',
                        icon: Icons.apartment_rounded,
                        color: const Color(0xFF062AAE),
                        bgColor: const Color(0xFFEFF6FF),
                        onTap: onNavigateToCompanies ?? () {},
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        title: 'Pending Review',
                        value: '${service.pendingCount}',
                        subtitle: 'Filings in Queue',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        onTap: onNavigateToQueue,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        title: 'Clarifications',
                        value: '${service.moreDetailsCount}',
                        subtitle: 'Client Queries',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFDBEAFE),
                        onTap: onNavigateToQueue,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        title: 'Deadlines',
                        value:
                            '${SecretaryComplianceService.instance.tasks.length}',
                        subtitle: 'Statutory Dates',
                        icon: Icons.event_available_rounded,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                        onTap: onNavigateToCompanies ?? () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // SECTION: Assigned Company Portfolios List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Client Companies',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF062AAE).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${companies.length} ACTIVE',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF062AAE),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (onNavigateToCompanies != null)
                        TextButton(
                          onPressed: onNavigateToCompanies,
                          child: Text(
                            'Manage Portfolios →',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF062AAE),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Company Cards
                  ...companies.map((compName) {
                    final compDocs = service.documents
                        .where((d) => d.companyName == compName)
                        .toList();
                    final compPending = compDocs
                        .where((d) =>
                            d.status == DocumentReviewStatus.pendingReview)
                        .length;
                    final compSsmNo = compDocs.isNotEmpty
                        ? compDocs.first.companySsmNo
                        : 'Sdn Bhd • SSM Registered';
                    final tasks = SecretaryComplianceService.instance
                        .getTasksForCompany(compName);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyDocumentsFolderPage(companyName: compName),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.business_rounded,
                                    color: Color(0xFF062AAE),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            compName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Good Standing',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF047857),
                                            ),
                                          ),
                                        ),
                                        if (compPending > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF2F2),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFFECACA)),
                                            ),
                                            child: Text(
                                              '$compPending to Review',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFDC2626),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      compSsmNo,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (tasks.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 11,
                                            color: tasks.first.pillTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Next: ${tasks.first.title} (${tasks.first.timeRemainingText})',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: tasks.first.pillTextColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompanyDocumentsFolderPage(companyName: compName),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  foregroundColor: const Color(0xFF062AAE),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                                  ),
                                ),
                                icon: const Icon(Icons.folder_open_rounded, size: 14),
                                label: Text(
                                  compDocs.isNotEmpty ? '${compDocs.length} Files' : 'Open Vault',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // SECTION: Action Needed / Urgent Client Documents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Urgent Filings to Review (${pendingDocs.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToQueue,
                        child: Text(
                          'View Full Queue →',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF062AAE),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (pendingDocs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Text(
                          'All client files checked! No pending documents in queue.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    )
                  else
                    ...pendingDocs
                        .take(3)
                        .map((doc) => _buildUrgentItemCard(context, doc)),

                  const SizedBox(height: 20),

                  // SECTION: Active Clarification Threads
                  if (clarificationDocs.isNotEmpty) ...[
                    Text(
                      'Active Queries with Clients (${clarificationDocs.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...clarificationDocs
                        .map((doc) => _buildClarificationItemCard(context, doc)),
                    const SizedBox(height: 20),
                  ],

                  // SECTION: Upcoming Statutory Deadlines
                  Text(
                    'Upcoming Statutory Returns (${SecretaryComplianceService.instance.tasks.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...SecretaryComplianceService.instance.tasks.take(3).map((task) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: task.pillBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              DateFormat('dd MMM').format(task.dueDate),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: task.pillTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${task.companyName} • ${task.timeRemainingText}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
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
              blurRadius: 6,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: const Color(0xFF94A3B8),
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

  Widget _buildUrgentItemCard(BuildContext context, ClientDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF0F172A),
            size: 20,
          ),
        ),
        title: Text(
          doc.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${doc.companyName} • ${doc.uploadedBy}',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF062AAE),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentReviewDetailPage(document: doc),
              ),
            );
          },
          child: Text(
            'Check',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClarificationItemCard(BuildContext context, ClientDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.mark_chat_unread_outlined,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Query sent: ${doc.reviewDetails?.requestedDetails ?? "Clarifications needed"}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF1D4ED8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
