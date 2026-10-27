import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'document_viewer_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/app_top_header.dart';
import '../home/home_page.dart';
import '../services/secretary_document_service.dart';
import '../services/ssm_filing_service.dart';
import '../models/client_document_model.dart';
import '../models/ssm_filing_model.dart';
import '../transactions/ssm_filing_detail_page.dart';

class AttentionPage extends StatelessWidget {
  const AttentionPage({super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 2) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SecretaryDocumentService.instance,
        SsmFilingService.instance,
      ]),
      builder: (context, _) {
        final secService = SecretaryDocumentService.instance;
        final ssmService = SsmFilingService.instance;

        final docsNeedingAction = secService.documents
            .where((d) =>
                d.status == DocumentReviewStatus.moreDetailsNeeded ||
                d.status == DocumentReviewStatus.rejected)
            .toList();

        final filingsNeedingReply = ssmService.filings
            .where((f) => f.status == SsmFilingStatus.secretaryReplied)
            .toList();

        final hasNoItems = docsNeedingAction.isEmpty && filingsNeedingReply.isEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const AppTopHeader(),
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
                        'Attention',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                                  child: const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF059669),
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'All Caught Up!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No documents or statutory filings currently require your attention.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (docsNeedingAction.isNotEmpty) ...[
                                Text(
                                  'DOCUMENTS REQUIRING REVISION (${docsNeedingAction.length})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...docsNeedingAction.map((doc) => _buildDocActionCard(context, doc)),
                                const SizedBox(height: 24),
                              ],
                              if (filingsNeedingReply.isNotEmpty) ...[
                                Text(
                                  'SECRETARY CLARIFICATIONS (${filingsNeedingReply.length})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...filingsNeedingReply.map((filing) => _buildFilingActionCard(context, filing)),
                              ],
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 2,
            onTap: (index) => _onItemTapped(context, index),
          ),
        );
      },
    );
  }

  Widget _buildDocActionCard(BuildContext context, ClientDocument doc) {
    final isRejected = doc.status == DocumentReviewStatus.rejected;
    final reviewer = doc.reviewDetails?.reviewedBy ?? 'Secretary';
    final feedback = isRejected
        ? (doc.reviewDetails?.rejectionReason ?? 'Document rejected by secretary.')
        : (doc.reviewDetails?.requestedDetails ?? 'Additional details requested.');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRejected ? Colors.red.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRejected ? Colors.red.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRejected ? 'Rejected' : 'More Details Needed',
                  style: GoogleFonts.poppins(
                    color: isRejected ? Colors.red.shade800 : Colors.blue.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                doc.uploadedAt,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/pdf.png', width: 44, height: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${doc.fileSize} • ${doc.companyName}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isRejected ? const Color(0xFFFECACA) : const Color(0xFFBFDBFE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isRejected ? Icons.error_outline : Icons.help_outline,
                      size: 16,
                      color: isRejected ? Colors.red.shade700 : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Secretary ($reviewer):',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isRejected ? Colors.red.shade900 : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feedback,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isRejected ? Colors.red.shade800 : const Color(0xFF1E3A8A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentViewerPage(fileName: doc.title),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF062AAE),
                    side: const BorderSide(color: Color(0xFF062AAE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.pickFile();
                    if (result != null) {
                      await SecretaryDocumentService.instance.reuploadDocument(
                        doc.id,
                        result.name,
                        '1.6 MB',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Uploaded ${result.name} - sent to Secretary for re-review',
                              style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFF062AAE),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                  label: const Text('Re-upload', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062AAE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilingActionCard(BuildContext context, SsmFiling filing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Secretary Replied',
                  style: GoogleFonts.poppins(
                    color: Colors.amber.shade900,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Due ${filing.deadline}',
                style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            filing.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 3),
          Text(
            '${filing.referenceNo} • ${filing.companyName}',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SsmFilingDetailPage(filingId: filing.id),
                ),
              );
            },
            icon: const Icon(Icons.reply_rounded, size: 16, color: Colors.white),
            label: const Text('View & Reply to Secretary', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF062AAE),
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
