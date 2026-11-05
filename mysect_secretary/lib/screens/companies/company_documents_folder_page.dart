import '../../widgets/secretary_sidebar.dart';
import '../shell/main_navigation_shell.dart';
import '../../widgets/secretary_desktop_top_bar.dart';
import '../../widgets/app_top_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/client_document_model.dart';
import '../../services/secretary_compliance_service.dart';
import '../../services/secretary_document_service.dart';
import '../../models/secretary_subscription_model.dart';
import '../review_queue/document_review_detail_page.dart';

class CompanyDocumentsFolderPage extends StatefulWidget {
  final String companyName;

  const CompanyDocumentsFolderPage({
    super.key,
    required this.companyName,
  });

  @override
  State<CompanyDocumentsFolderPage> createState() =>
      _CompanyDocumentsFolderPageState();
}

class _CompanyDocumentsFolderPageState
    extends State<CompanyDocumentsFolderPage> {
  final SecretaryDocumentService _docService =
      SecretaryDocumentService.instance;
  final SecretaryComplianceService _compService =
      SecretaryComplianceService.instance;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  Color _getStatusColor(DocumentReviewStatus status) {
    switch (status) {
      case DocumentReviewStatus.pendingReview:
        return const Color(0xFFD97706);
      case DocumentReviewStatus.approved:
        return const Color(0xFF059669);
      case DocumentReviewStatus.rejected:
        return const Color(0xFFDC2626);
      case DocumentReviewStatus.moreDetailsNeeded:
        return const Color(0xFF2563EB);
    }
  }

  Color _getStatusBg(DocumentReviewStatus status) {
    switch (status) {
      case DocumentReviewStatus.pendingReview:
        return const Color(0xFFFEF3C7);
      case DocumentReviewStatus.approved:
        return const Color(0xFFECFDF5);
      case DocumentReviewStatus.rejected:
        return const Color(0xFFFEE2E2);
      case DocumentReviewStatus.moreDetailsNeeded:
        return const Color(0xFFEFF6FF);
    }
  }

  String _getStatusText(DocumentReviewStatus status) {
    switch (status) {
      case DocumentReviewStatus.pendingReview:
        return 'Pending Review';
      case DocumentReviewStatus.approved:
        return 'Approved';
      case DocumentReviewStatus.rejected:
        return 'Rejected';
      case DocumentReviewStatus.moreDetailsNeeded:
        return 'Queries Sent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_docService, _compService]),
      builder: (context, _) {
        final allCompanyDocs = _docService.documents
            .where((d) => d.companyName == widget.companyName)
            .toList();
        final billingCo = _docService.billingCompanies.firstWhere(
          (c) => c.name.toLowerCase().trim() == widget.companyName.toLowerCase().trim(),
          orElse: () => SsmBillingCompany(
            id: '',
            name: widget.companyName,
            registrationNo: '',
            entityType: 'Sdn. Bhd.',
            onboardedDate: '15 Jan 2024',
            nextFilingDate: '30 Jun 2026',
            isPaidForMonth: true,
          ),
        );

        final ssmNo = allCompanyDocs.isNotEmpty
            ? allCompanyDocs.first.companySsmNo
            : 'SSM Registered Sdn Bhd';

        final companyTasks =
            _compService.getTasksForCompany(widget.companyName);

        final pendingCount = allCompanyDocs
            .where((d) => d.status == DocumentReviewStatus.pendingReview)
            .length;
        final approvedCount = allCompanyDocs
            .where((d) => d.status == DocumentReviewStatus.approved)
            .length;
        final queryCount = allCompanyDocs
            .where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded)
            .length;

        // Categories from documents
        final categories = <String>{
          'All',
          ...allCompanyDocs.map((d) => d.category),
        }.toList();

        // Filtered docs
        final filteredDocs = allCompanyDocs.where((doc) {
          final matchesCategory =
              _selectedCategory == 'All' || doc.category == _selectedCategory;
          final matchesSearch = _searchQuery.isEmpty ||
              doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.uploadedBy.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            final mainContent = Column(
              children: [
                if (isDesktop)
                  SecretaryDesktopTopBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      tooltip: 'Back to Companies',
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: 'Company Document Vault',
                    badgeText: 'SSM LICENSED',
                    isSyncing: _docService.isSyncing,
                    onSync: () => _docService.syncFromBackend(),
                  )
                else ...[
                      const AppTopHeader(backgroundColor: Colors.white),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Back to Companies',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.sync_rounded,
                                size: 20,
                                color: Color(0xFF062AAE),
                              ),
                              tooltip: 'Sync Company Vault',
                              onPressed: () async {
                                await _docService.syncFromBackend();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Synced files for ${widget.companyName}',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFF062AAE),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                // Scrollable Document Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Corporate Company Dossier Header Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.025),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.account_balance_rounded,
                                      color: Color(0xFF062AAE),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.companyName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Co. Reg: $ssmNo',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF059669)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SSM ACTIVE REGISTRY',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF047857),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'TM Cloud Encrypted Repository',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: billingCo.isPaidForMonth
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: billingCo.isPaidForMonth
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFDE68A),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        billingCo.isPaidForMonth
                                            ? Icons.check_circle_rounded
                                            : Icons.warning_amber_rounded,
                                        size: 11,
                                        color: billingCo.isPaidForMonth
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        billingCo.isPaidForMonth
                                            ? 'May Retainer: Paid (RM 50)'
                                            : 'May Retainer: RM 50 Due',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: billingCo.isPaidForMonth
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFF92400E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildCorporateMetric(
                              label: 'Total Files',
                              value: '${allCompanyDocs.length}',
                              valueColor: const Color(0xFF0F172A),
                            ),
                            Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                            _buildCorporateMetric(
                              label: 'Pending',
                              value: '$pendingCount',
                              valueColor: pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF64748B),
                            ),
                            Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                            _buildCorporateMetric(
                              label: 'Approved',
                              value: '$approvedCount',
                              valueColor: const Color(0xFF059669),
                            ),
                            Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                            _buildCorporateMetric(
                              label: 'Queries',
                              value: '$queryCount',
                              valueColor: queryCount > 0 ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Upcoming Statutory Return for this company
                if (companyTasks.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF062AAE),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Statutory Lodgement',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                companyTasks.first.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: companyTasks.first.pillBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Due: ${DateFormat('dd MMM yyyy').format(companyTasks.first.dueDate)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: companyTasks.first.pillTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Search & Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            style: GoogleFonts.poppins(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Search documents in this folder...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 42),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Category Filter Pills
                if (categories.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                              }
                            },
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                            selectedColor: const Color(0xFF062AAE),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF062AAE)
                                  : const Color(0xFFE2E8F0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 16),

                // Documents List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Folder Documents (${filteredDocs.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'TM Cloud Secure Vault',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Document Cards or Empty State
                if (filteredDocs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.folder_open_rounded,
                              color: Color(0xFF94A3B8),
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No documents in this company folder yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'When the client uploads Section 68 returns, director appointments, or statutory filings via the MySect app, they will automatically be filed in this company vault.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredDocs.map((doc) => _buildDocumentCard(context, doc)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            SecretarySidebar(
              currentIndex: 2,
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
            Expanded(child: mainContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: false,
        child: mainContent,
      ),
    );
  },
);
      },
    );
  }

  Widget _buildCorporateMetric({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, ClientDocument doc) {
    final statusColor = _getStatusColor(doc.status);
    final statusBg = _getStatusBg(doc.status);
    final statusText = _getStatusText(doc.status);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentReviewDetailPage(document: doc),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PDF Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  doc.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  doc.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              if (doc.linkedFilingRef.isNotEmpty)
                                Text(
                                  doc.linkedFilingRef,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${doc.uploadedBy} • ${doc.fileSize}',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Review →',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF062AAE),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
