import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ssm_filing_model.dart';
import '../services/ssm_filing_service.dart';
import 'ssm_filing_detail_page.dart';
import 'submit_ssm_filing_page.dart';
import '../widgets/app_top_header.dart';

class TransactionsPage extends StatefulWidget {
  final bool initialDocumentsNeededFilter;
  final bool initialReplyNeededFilter;

  const TransactionsPage({
    super.key,
    this.initialDocumentsNeededFilter = false,
    this.initialReplyNeededFilter = false,
  });

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  SsmFilingStatus? _selectedStatusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _applyInitialFilters();
  }

  void _applyInitialFilters() {
    if (widget.initialReplyNeededFilter) {
      _selectedStatusFilter = SsmFilingStatus.secretaryReplied;
    } else if (widget.initialDocumentsNeededFilter) {
      _selectedStatusFilter = SsmFilingStatus.waitingSecretaryReview;
    }
  }

  @override
  void didUpdateWidget(TransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDocumentsNeededFilter != oldWidget.initialDocumentsNeededFilter ||
        widget.initialReplyNeededFilter != oldWidget.initialReplyNeededFilter) {
      _applyInitialFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SsmFilingService.instance,
      builder: (context, _) {
        final allFilings = SsmFilingService.instance.filings;

        final filteredFilings = allFilings.where((f) {
          if (_selectedStatusFilter != null && f.status != _selectedStatusFilter) {
            return false;
          }
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matches = f.title.toLowerCase().contains(query) ||
                f.referenceNo.toLowerCase().contains(query) ||
                f.filingType.toLowerCase().contains(query) ||
                f.companyName.toLowerCase().contains(query);
            if (!matches) return false;
          }
          return true;
        }).toList();

        final waitingSecCount = SsmFilingService.instance.waitingSecretaryCount;
        final secRepliesNeededCount = SsmFilingService.instance.secretaryRepliesNeededCount;
        final lodgedCount = allFilings.where((f) => f.status == SsmFilingStatus.lodgedToSsm).length;
        final completedCount = allFilings.where((f) => f.status == SsmFilingStatus.completed).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const AppTopHeader(),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 600));
                      setState(() {});
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      children: [
                        // Page Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submissions',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Track submitted files & secretary replies',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search submissions, ref number, or files...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF062AAE)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'All Submissions (${allFilings.length})',
                                isSelected: _selectedStatusFilter == null,
                                onTap: () => setState(() => _selectedStatusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Waiting Secretary ($waitingSecCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.waitingSecretaryReview,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.waitingSecretaryReview),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Action Needed ($secRepliesNeededCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.secretaryReplied,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.secretaryReplied),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Submitted to SSM ($lodgedCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.lodgedToSsm,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.lodgedToSsm),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Completed ($completedCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.completed,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.completed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filings List
                        if (filteredFilings.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No submissions match this filter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Submit a new SSM file to initiate statutory review.',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF062AAE),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SubmitSsmFilingPage(),
                                        ),
                                      );
                                    },
                                    child: Text('Submit New SSM File', style: GoogleFonts.poppins(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filteredFilings.map((filing) => _buildFilingCard(filing)),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = const Color(0xFF062AAE),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildFilingCard(SsmFiling filing) {
    final hasSecretaryQuery = filing.status == SsmFilingStatus.secretaryReplied;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasSecretaryQuery ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: hasSecretaryQuery ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SsmFilingDetailPage(filingId: filing.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Reference & Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 14, color: Color(0xFF062AAE)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      filing.referenceNo,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF062AAE),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: filing.status.bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: filing.status.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(filing.status.icon, size: 11, color: filing.status.color),
                        const SizedBox(width: 4),
                        Text(
                          filing.status.shortLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: filing.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                filing.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Company & Secretary
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filing.companyName} • Sec: ${filing.assignedSecretary}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Action Needed Alert Banner
              if (hasSecretaryQuery)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Action required: Secretary requested clarification or document update.',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // Footer: Attached Files and Deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${filing.attachedFiles.length} file(s)',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Deadline: ${filing.deadline}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF062AAE)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
