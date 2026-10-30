import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/client_document_model.dart';
import '../services/secretary_document_service.dart';
import 'document_review_detail_page.dart';
import 'package:intl/intl.dart';
import '../services/secretary_compliance_service.dart';

class SecretaryDashboardTab extends StatelessWidget {
  final VoidCallback onNavigateToQueue;

  const SecretaryDashboardTab({super.key, required this.onNavigateToQueue});

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([service, SecretaryComplianceService.instance]),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                  child: Row(
                    children: [
                      _buildCompactStatus(
                        label: 'Pending',
                        count: service.pendingCount,
                        icon: Icons.hourglass_top_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Queries',
                        count: service.moreDetailsCount,
                        icon: Icons.help_outline_rounded,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Approved',
                        count: service.approvedCount,
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                        onTap: onNavigateToQueue,
                      ),
                      _buildStatusDivider(),
                      _buildCompactStatus(
                        label: 'Rejected',
                        count: service.rejectedCount,
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
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

                const SizedBox(height: 20),
                Text(
                  'Client Statutory Deadlines (${SecretaryComplianceService.instance.tasks.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${task.companyName} • ${task.timeRemainingText}',
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
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
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
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
      height: 36,
      color: const Color(0xFFE2E8F0),
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
