import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../models/ssm_filing_model.dart';
import '../models/client_document_model.dart';
import '../services/ssm_filing_service.dart';
import '../services/secretary_document_service.dart';
import '../transactions/ssm_filing_detail_page.dart';
import '../files/add_file_menu.dart';
import '../widgets/app_top_header.dart';

class RepliesNeededPage extends StatelessWidget {
  const RepliesNeededPage({super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SsmFilingService.instance,
        SecretaryDocumentService.instance,
      ]),
      builder: (context, _) {
        final filingsNeedingReply = SsmFilingService.instance.filings
            .where((f) => f.status == SsmFilingStatus.secretaryReplied)
            .toList();

        final docsNeedingAction = SecretaryDocumentService.instance.documents
            .where((d) =>
                d.status == DocumentReviewStatus.moreDetailsNeeded ||
                d.status == DocumentReviewStatus.rejected)
            .toList();

        final hasNoItems = filingsNeedingReply.isEmpty && docsNeedingAction.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const AppTopHeader(),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 16.0,
                          bottom: 12.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black87,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secretary Replies & Actions Needed',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Clarifications, replacement files & responses requested by your secretary',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: hasNoItems
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFECFDF5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 48),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'All Caught Up!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No queries or clarifications currently requested by your licensed secretary.',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                children: [
                                  // SECTION 1: Client Documents Checked by Secretary Needing Clarification/Replacement
                                  if (docsNeedingAction.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.folder_shared_outlined, size: 16, color: Color(0xFF062AAE)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'FILES REVIEWED BY SECRETARY (${docsNeedingAction.length})',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...docsNeedingAction.map((doc) => _buildDocActionCard(context, doc)),
                                    const SizedBox(height: 16),
                                  ],

                                  // SECTION 2: SSM Filing Threads Needing Client Reply
                                  if (filingsNeedingReply.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.forum_outlined, size: 16, color: Color(0xFFDC2626)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'STATUTORY FILING QUERIES (${filingsNeedingReply.length})',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...filingsNeedingReply.map((filing) => _buildFilingActionCard(context, filing)),
                                  ],
                                ],
                              ),
                      ),
                    ],
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
      },
    );
  }

  Widget _buildDocActionCard(BuildContext context, ClientDocument doc) {
    final isRejected = doc.status == DocumentReviewStatus.rejected;
    final reviewer = doc.reviewDetails?.reviewedBy ?? 'Licensed Secretary';
    final explanation = isRejected
        ? (doc.reviewDetails?.rejectionReason ?? 'Document rejected by secretary.')
        : (doc.reviewDetails?.requestedDetails ?? 'Secretary requested additional details.');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRejected ? const Color(0xFFFECACA) : const Color(0xFFBFDBFE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: doc.status.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(doc.status.icon, size: 12, color: doc.status.color),
                      const SizedBox(width: 4),
                      Text(
                        isRejected ? 'File Rejected - Action Required' : 'More Details Requested',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: doc.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  doc.fileSize,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doc.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Company: ${doc.companyName} • Category: ${doc.category}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),

            // Secretary feedback box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRejected ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isRejected ? const Color(0xFFFFE4E6) : const Color(0xFFDBEAFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Icon(
                          isRejected ? Icons.warning_amber_rounded : Icons.support_agent_rounded,
                          size: 14,
                          color: isRejected ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Secretary ($reviewer):',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isRejected ? const Color(0xFF991B1B) : const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062AAE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      showAddMenu(context);
                    },
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: Text(
                      'Upload Requested Document',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onPressed: () => _showClientDocDetails(context, doc),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClientDocDetails(BuildContext context, ClientDocument doc) {
    final isRejected = doc.status == DocumentReviewStatus.rejected;
    final reviewer = doc.reviewDetails?.reviewedBy ?? 'Licensed Secretary';
    final notes = isRejected
        ? (doc.reviewDetails?.rejectionReason ?? 'Document requires amendment.')
        : (doc.reviewDetails?.requestedDetails ?? 'Please provide requested information.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
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
                    color: doc.status.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(doc.status.icon, color: doc.status.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${doc.category} • ${doc.fileSize}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRejected ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secretary Feedback ($reviewer)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isRejected ? const Color(0xFF991B1B) : const Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notes,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showAddMenu(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062AAE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Upload Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilingActionCard(BuildContext context, SsmFiling filing) {
    final lastSecMsg = filing.messages.lastWhere(
      (m) => m.isFromSecretary,
      orElse: () => filing.messages.last,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_chat_unread, size: 12, color: Color(0xFFDC2626)),
                      const SizedBox(width: 4),
                      Text(
                        'Secretary Action Needed',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  filing.referenceNo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF062AAE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              filing.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Company: ${filing.companyName} • Sec: ${filing.assignedSecretary}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE4E6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1.0),
                        child: Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${lastSecMsg.senderName} (${lastSecMsg.time}):',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastSecMsg.text,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF062AAE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SsmFilingDetailPage(filingId: filing.id),
                    ),
                  );
                },
                icon: const Icon(Icons.reply_rounded, size: 16),
                label: Text(
                  'Open Thread & Reply to Secretary',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
