import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notifications/notifications_page.dart';
import '../models/ssm_filing_model.dart';
import '../services/ssm_filing_service.dart';
import 'ssm_filing_detail_page.dart';
import 'submit_ssm_filing_page.dart';

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
            child: Column(
              children: [
                // Top App Bar
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.black87,
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
                    ],
                  ),
                ),

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
                        // Page Title & Submit Action Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SSM Filings',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Submit files & track secretary replies',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF062AAE),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SubmitSsmFilingPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(
                                'Submit SSM',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Summary Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Review',
                                count: '$waitingSecCount',
                                color: const Color(0xFFD97706),
                                bgColor: const Color(0xFFFEF3C7),
                                icon: Icons.hourglass_top_rounded,
                                isSelected: _selectedStatusFilter == SsmFilingStatus.waitingSecretaryReview,
                                onTap: () {
                                  setState(() {
                                    _selectedStatusFilter = _selectedStatusFilter == SsmFilingStatus.waitingSecretaryReview
                                        ? null
                                        : SsmFilingStatus.waitingSecretaryReview;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Action',
                                count: '$secRepliesNeededCount',
                                color: const Color(0xFFDC2626),
                                bgColor: const Color(0xFFFEE2E2),
                                icon: Icons.mark_chat_unread_rounded,
                                isSelected: _selectedStatusFilter == SsmFilingStatus.secretaryReplied,
                                onTap: () {
                                  setState(() {
                                    _selectedStatusFilter = _selectedStatusFilter == SsmFilingStatus.secretaryReplied
                                        ? null
                                        : SsmFilingStatus.secretaryReplied;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Lodged',
                                count: '$lodgedCount',
                                color: const Color(0xFF7C3AED),
                                bgColor: const Color(0xFFF5F3FF),
                                icon: Icons.account_balance_rounded,
                                isSelected: _selectedStatusFilter == SsmFilingStatus.lodgedToSsm,
                                onTap: () {
                                  setState(() {
                                    _selectedStatusFilter = _selectedStatusFilter == SsmFilingStatus.lodgedToSsm
                                        ? null
                                        : SsmFilingStatus.lodgedToSsm;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Done',
                                count: '$completedCount',
                                color: const Color(0xFF059669),
                                bgColor: const Color(0xFFECFDF5),
                                icon: Icons.check_circle_rounded,
                                isSelected: _selectedStatusFilter == SsmFilingStatus.completed,
                                onTap: () {
                                  setState(() {
                                    _selectedStatusFilter = _selectedStatusFilter == SsmFilingStatus.completed
                                        ? null
                                        : SsmFilingStatus.completed;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                              hintText: 'Search filings, ref number, or section...',
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
                                label: 'All Filings (${allFilings.length})',
                                isSelected: _selectedStatusFilter == null,
                                onTap: () => setState(() => _selectedStatusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Waiting Secretary ($waitingSecCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.waitingSecretaryReview,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.waitingSecretaryReview),
                                activeColor: const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Action Needed ($secRepliesNeededCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.secretaryReplied,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.secretaryReplied),
                                activeColor: const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Lodged to SSM ($lodgedCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.lodgedToSsm,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.lodgedToSsm),
                                activeColor: const Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Completed ($completedCount)',
                                isSelected: _selectedStatusFilter == SsmFilingStatus.completed,
                                onTap: () => setState(() => _selectedStatusFilter = SsmFilingStatus.completed),
                                activeColor: const Color(0xFF059669),
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
                                    'No filings match this filter',
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

  Widget _buildMetricCard({
    required String title,
    required String count,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
    final lastMessage = filing.messages.isNotEmpty ? filing.messages.last : null;

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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Latest Message Banner if available
              if (lastMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lastMessage.isFromSecretary
                        ? (hasSecretaryQuery ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4))
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: lastMessage.isFromSecretary
                          ? (hasSecretaryQuery ? const Color(0xFFFECACA) : const Color(0xFFDCFCE7))
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        lastMessage.isFromSecretary ? Icons.mark_chat_unread : Icons.chat_bubble_outline,
                        size: 14,
                        color: lastMessage.isFromSecretary
                            ? (hasSecretaryQuery ? const Color(0xFFDC2626) : const Color(0xFF16A34A))
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${lastMessage.senderName}: "${lastMessage.text}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
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
                    children: [
                      const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${filing.attachedFiles.length} file(s)',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Deadline: ${filing.deadline}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF062AAE)),
                    ],
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
