import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/client_document_model.dart';
import '../services/secretary_document_service.dart';
import 'document_review_detail_page.dart';

class SecretaryDashboardTab extends StatelessWidget {
  final VoidCallback onNavigateToQueue;

  const SecretaryDashboardTab({super.key, required this.onNavigateToQueue});

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final pendingDocs = service.documents
            .where((d) => d.status == DocumentReviewStatus.pendingReview)
            .toList();
        final clarificationDocs = service.documents
            .where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded)
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () => service.syncFromBackend(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Simplified Document Intake Status
                Text(
                  'Client Documents Intake Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildCompactStatus(
                        label: 'Pending',
                        count: service.pendingCount,
                        icon: Icons.hourglass_top_rounded,
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Queries',
                        count: service.moreDetailsCount,
                        icon: Icons.help_outline_rounded,
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Approved',
                        count: service.approvedCount,
                        icon: Icons.check_circle_rounded,
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Rejected',
                        count: service.rejectedCount,
                        icon: Icons.cancel_rounded,
                        onTap: onNavigateToQueue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Files Needing Urgent Review
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Action Needed (${pendingDocs.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToQueue,
                      child: Text(
                        'View All Queue',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF062AAE),
                        ),
                      ),
                    ),
                  ],
                ),
                if (pendingDocs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'All files checked! No pending documents in queue.',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ...pendingDocs.take(3).map((doc) => _buildUrgentItemCard(context, doc)),

                const SizedBox(height: 20),

                // Section: Active Clarification Threads
                if (clarificationDocs.isNotEmpty) ...[
                  Text(
                    'Active Queries with Clients (${clarificationDocs.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...clarificationDocs.map((doc) => _buildClarificationItemCard(context, doc)),
                ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStatus({
    required String label,
    required int count,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF062AAE), size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildUrgentItemCard(BuildContext context, ClientDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.description_outlined, color: Colors.black87, size: 20),
        ),
        title: Text(
          doc.title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${doc.companyName} • ${doc.uploadedBy}',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF062AAE),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
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
          const Icon(Icons.mark_chat_unread_outlined, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Query sent: ${doc.reviewDetails?.requestedDetails ?? "Clarifications needed"}',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1D4ED8)),
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
