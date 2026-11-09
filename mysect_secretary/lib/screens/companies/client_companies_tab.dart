import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/secretary_document_service.dart';
import '../../models/secretary_subscription_model.dart';
import '../../services/secretary_compliance_service.dart';
import '../../models/client_document_model.dart';
import 'company_documents_folder_page.dart';

class ClientCompaniesTab extends StatefulWidget {
  const ClientCompaniesTab({super.key});

  @override
  State<ClientCompaniesTab> createState() => _ClientCompaniesTabState();
}

class _ClientCompaniesTabState extends State<ClientCompaniesTab> {
  final SecretaryDocumentService _docService = SecretaryDocumentService.instance;
  final SecretaryComplianceService _compService = SecretaryComplianceService.instance;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  void _showSetDatelineBottomSheet(BuildContext context, String companyName) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final instructionsController = TextEditingController();

    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 14));
    String selectedCategory = 'General Statutory';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final existingTasks = _compService.getTasksForCompany(companyName);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF062AAE).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF062AAE),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set Calendar Dateline',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                companyName,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF062AAE),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Existing Tasks list for this company
                    if (existingTasks.isNotEmpty) ...[
                      Text(
                        'Scheduled Datelines (${existingTasks.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...existingTasks.map((t) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: t.pillBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(t.dueDate),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: t.pillTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      t.timeRemainingText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF059669)),
                                tooltip: 'Send Reminder to Director',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Statutory reminder for ${t.title} sent to $companyName directors.',
                                              style: GoogleFonts.poppins(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF062AAE),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                onPressed: () {
                                  _compService.deleteTask(t.id);
                                  setModalState(() {});
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 8),
                    ],



                    // Task Title Field
                    Text(
                      'Task / Lodgement Title',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'e.g., Section 68 Annual Return',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Due Date Picker Field
                    Text(
                      'Statutory Deadline (Due Date)',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF062AAE),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDueDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF062AAE), width: 1.2),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF062AAE).withValues(alpha: 0.04),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF062AAE)),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, dd MMMM yyyy').format(selectedDueDate),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF062AAE),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Change',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF062AAE)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Instructions / Subtitle
                    Text(
                      'Client Filing Instructions',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: instructionsController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 11),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter filing instructions for client...',
                        hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF062AAE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;

                          await _compService.addOrUpdateTask(
                            companyName: companyName,
                            title: titleController.text.trim(),
                            subtitle: subtitleController.text.trim(),
                            dueDate: selectedDueDate,
                            category: selectedCategory,
                            instructions: instructionsController.text.trim(),
                          );

                          if (modalCtx.mounted) {
                            Navigator.pop(modalCtx);
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF059669),
                                content: Text(
                                  'Dateline set for $companyName on ${DateFormat('dd MMM yyyy').format(selectedDueDate)}! Pushed to client mobile calendar.',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text(
                          'Push Dateline to Client Calendar',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_docService, _compService]),
      builder: (context, _) {
        final allCompanies = _docService.clientCompanies;

        final filteredCompanies = allCompanies.where((comp) {
          final compDocs = _docService.documents.where((d) => d.companyName == comp).toList();
          final ssmNo = compDocs.isNotEmpty ? compDocs.first.companySsmNo : '';
          final pendingCount = compDocs.where((d) => d.status == DocumentReviewStatus.pendingReview).length;
          final moreDetailsCount = compDocs.where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded).length;
          final rejectedCount = compDocs.where((d) => d.status == DocumentReviewStatus.rejected).length;
          final billingCo = _docService.billingCompanies.firstWhere(
            (c) => c.name.toLowerCase().trim() == comp.toLowerCase().trim(),
            orElse: () => SsmBillingCompany(
              id: '',
              name: comp,
              registrationNo: ssmNo,
              entityType: 'Sdn. Bhd.',
              onboardedDate: '15 Jan 2024',
              nextFilingDate: '30 Jun 2026',
              isPaidForMonth: true,
            ),
          );

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final matchesName = comp.toLowerCase().contains(q);
            final matchesSsm = ssmNo.toLowerCase().contains(q);
            if (!matchesName && !matchesSsm) return false;
          }

          if (_selectedFilter == 'Action Needed') {
            return moreDetailsCount > 0 || rejectedCount > 0 || !billingCo.isPaidForMonth;
          } else if (_selectedFilter == 'Pending') {
            return pendingCount > 0;
          } else if (_selectedFilter == 'Up to Date') {
            return pendingCount == 0 && moreDetailsCount == 0 && rejectedCount == 0 && billingCo.isPaidForMonth;
          }
          return true;
        }).toList();

        final actionNeededCount = allCompanies.where((comp) {
          final compDocs = _docService.documents.where((d) => d.companyName == comp).toList();
          final billingCo = _docService.billingCompanies.firstWhere(
            (c) => c.name.toLowerCase().trim() == comp.toLowerCase().trim(),
            orElse: () => SsmBillingCompany(
              id: '',
              name: comp,
              registrationNo: '',
              entityType: 'Sdn. Bhd.',
              onboardedDate: '15 Jan 2024',
              nextFilingDate: '30 Jun 2026',
              isPaidForMonth: true,
            ),
          );
          final hasIssues = compDocs.any((d) =>
              d.status == DocumentReviewStatus.moreDetailsNeeded ||
              d.status == DocumentReviewStatus.rejected);
          return hasIssues || !billingCo.isPaidForMonth;
        }).length;

        final pendingCompaniesCount = allCompanies.where((comp) {
          final compDocs = _docService.documents.where((d) => d.companyName == comp).toList();
          return compDocs.any((d) => d.status == DocumentReviewStatus.pendingReview);
        }).length;

        final upToDateCount = allCompanies.where((comp) {
          final compDocs = _docService.documents.where((d) => d.companyName == comp).toList();
          final billingCo = _docService.billingCompanies.firstWhere(
            (c) => c.name.toLowerCase().trim() == comp.toLowerCase().trim(),
            orElse: () => SsmBillingCompany(
              id: '',
              name: comp,
              registrationNo: '',
              entityType: 'Sdn. Bhd.',
              onboardedDate: '15 Jan 2024',
              nextFilingDate: '30 Jun 2026',
              isPaidForMonth: true,
            ),
          );
          final hasPending = compDocs.any((d) => d.status == DocumentReviewStatus.pendingReview);
          final hasIssues = compDocs.any((d) =>
              d.status == DocumentReviewStatus.moreDetailsNeeded ||
              d.status == DocumentReviewStatus.rejected);
          return !hasPending && !hasIssues && billingCo.isPaidForMonth;
        }).length;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scalable Search Bar for 20+ companies
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          style: GoogleFonts.poppins(fontSize: 12.5),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Search companies (e.g. Data Center, C2 Coffee, 1429581)...',
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 42),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 42),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter chips: All, Action Needed, Pending, Up to Date
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', '${allCompanies.length}'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Action Needed',
                            '$actionNeededCount',
                            isWarning: actionNeededCount > 0,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Pending',
                            '$pendingCompaniesCount',
                            isPending: pendingCompaniesCount > 0,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('Up to Date', '$upToDateCount'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 768;

                    if (filteredCompanies.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.search_off_rounded, color: Color(0xFF94A3B8), size: 26),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No companies found',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No client companies match "$_searchQuery"',
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () => setState(() {
                                  _searchQuery = '';
                                  _selectedFilter = 'All';
                                }),
                                child: Text(
                                  'Clear Search & Filter',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF062AAE)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (isDesktop) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 460,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 232,
                        ),
                        itemCount: filteredCompanies.length,
                        itemBuilder: (context, index) {
                          final compName = filteredCompanies[index];
                          return _buildCompanyCard(context, compName, isGrid: true);
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                        itemCount: filteredCompanies.length,
                        itemBuilder: (context, index) {
                          final compName = filteredCompanies[index];
                          return _buildCompanyCard(context, compName, isGrid: false);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildFilterChip(
    String label,
    String count, {
    bool isWarning = false,
    bool isPending = false,
  }) {
    final isSelected = _selectedFilter == label;
    Color borderColor;
    if (isSelected) {
      borderColor = const Color(0xFF062AAE);
    } else if (isWarning) {
      borderColor = const Color(0xFFFECACA);
    } else if (isPending) {
      borderColor = const Color(0xFFFDE68A);
    } else {
      borderColor = const Color(0xFFE2E8F0);
    }

    Color badgeBg;
    if (isSelected) {
      badgeBg = Colors.white.withValues(alpha: 0.25);
    } else if (isWarning) {
      badgeBg = const Color(0xFFFEF2F2);
    } else if (isPending) {
      badgeBg = const Color(0xFFFEF3C7);
    } else {
      badgeBg = Colors.white;
    }

    Color badgeTextColor;
    if (isSelected) {
      badgeTextColor = Colors.white;
    } else if (isWarning) {
      badgeTextColor = const Color(0xFFDC2626);
    } else if (isPending) {
      badgeTextColor = const Color(0xFFD97706);
    } else {
      badgeTextColor = const Color(0xFF64748B);
    }

    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF062AAE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, String compName, {bool isGrid = false}) {
    final compDocs = _docService.documents.where((d) => d.companyName == compName).toList();
    final pendingCount = compDocs.where((d) => d.status == DocumentReviewStatus.pendingReview).length;
    final moreDetailsCount = compDocs.where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded).length;
    final rejectedCount = compDocs.where((d) => d.status == DocumentReviewStatus.rejected).length;
    final ssmNo = compDocs.isNotEmpty ? compDocs.first.companySsmNo : 'Sdn Bhd';
    final companyTasks = _compService.getTasksForCompany(compName);
    final billingCo = _docService.billingCompanies.firstWhere(
      (c) => c.name.toLowerCase().trim() == compName.toLowerCase().trim(),
      orElse: () => SsmBillingCompany(
        id: '',
        name: compName,
        registrationNo: ssmNo,
        entityType: 'Sdn. Bhd.',
        onboardedDate: '15 Jan 2024',
        nextFilingDate: '30 Jun 2026',
        isPaidForMonth: true,
      ),
    );

    final hasActionNeeded = moreDetailsCount > 0 || rejectedCount > 0 || !billingCo.isPaidForMonth;

    String tabText;
    Color tabBg;
    Color tabBorderColor;
    Color tabTextColor;
    IconData tabIcon;

    if (hasActionNeeded) {
      tabText = 'ACTION NEEDED';
      tabIcon = Icons.error_outline_rounded;
      tabBg = const Color(0xFFFEF2F2);
      tabBorderColor = const Color(0xFFFECACA);
      tabTextColor = const Color(0xFFDC2626);
    } else if (pendingCount > 0) {
      tabText = pendingCount == 1 ? '1 PENDING' : '$pendingCount PENDING';
      tabIcon = Icons.schedule_rounded;
      tabBg = const Color(0xFFFEF3C7);
      tabBorderColor = const Color(0xFFFDE68A);
      tabTextColor = const Color(0xFFD97706);
    } else {
      tabText = 'UP TO DATE';
      tabIcon = Icons.check_circle_outline_rounded;
      tabBg = const Color(0xFFECFDF5);
      tabBorderColor = const Color(0xFFA7F3D0);
      tabTextColor = const Color(0xFF059669);
    }

    Widget folderCard = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyDocumentsFolderPage(companyName: compName),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isGrid ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
              children: [
                // Header Row: Folder Emblem, Name & SSM
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF062AAE).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF062AAE).withValues(alpha: 0.15)),
                      ),
                      child: const Icon(
                        Icons.folder_shared_rounded,
                        color: Color(0xFF062AAE),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compName,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            ssmNo,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: billingCo.isPaidForMonth
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(5),
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
                                ? 'May 2026 Plan: Paid (RM 50)'
                                : 'May 2026 Plan: RM 50 Due',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: billingCo.isPaidForMonth
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (billingCo.paymentDate != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Paid on ${billingCo.paymentDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Next Upcoming Statutory Milestone or Empty Placeholder in Grid
                if (companyTasks.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 13, color: Color(0xFF062AAE)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Next: ${companyTasks.first.title}',
                            style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            DateFormat('dd MMM').format(companyTasks.first.dueDate),
                            style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isGrid) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'No upcoming statutory deadline',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showSetDatelineBottomSheet(context, compName),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF062AAE)),
                        label: Text(
                          companyTasks.isNotEmpty ? '${companyTasks.length} Deadlines' : 'Set Deadline',
                          style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyDocumentsFolderPage(companyName: compName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF062AAE),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.folder_open_rounded, size: 13),
                        label: Text(
                          compDocs.isNotEmpty ? '${compDocs.length} Documents' : 'Open Folder',
                          style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 24,
                child: Row(
                  children: [
                    const SizedBox(width: 140),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 4, right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(8),
                          ),
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300, width: 1),
                            right: BorderSide(color: Colors.grey.shade300, width: 1),
                            left: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.article_outlined, size: 11, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              compDocs.isNotEmpty ? '${compDocs.length} Documents' : 'Empty Folder',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isGrid ? Expanded(child: folderCard) : folderCard,
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 25.5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tabBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(13),
                ),
                border: Border(
                  top: BorderSide(color: tabBorderColor, width: 1.2),
                  left: BorderSide(color: tabBorderColor, width: 1.2),
                  right: BorderSide(color: tabBorderColor, width: 1.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabIcon,
                    size: 13,
                    color: tabTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tabText,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: tabTextColor,
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
}