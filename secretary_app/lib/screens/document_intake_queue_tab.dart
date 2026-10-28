import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/client_document_model.dart';
import '../services/secretary_document_service.dart';
import 'document_review_detail_page.dart';

class DocumentIntakeQueueTab extends StatefulWidget {
  const DocumentIntakeQueueTab({super.key});

  @override
  State<DocumentIntakeQueueTab> createState() => _DocumentIntakeQueueTabState();
}

class _DocumentIntakeQueueTabState extends State<DocumentIntakeQueueTab> {
  final SecretaryDocumentService _service = SecretaryDocumentService.instance;

  String _searchQuery = '';
  DocumentReviewStatus? _selectedStatusFilter;
  String _selectedCompanyFilter = 'All';

  Color _getStatusColor(DocumentReviewStatus status) {
    switch (status) {
      case DocumentReviewStatus.pendingReview:
        return const Color(0xFFDC2626);
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
        return const Color(0xFFFEE2E2);
      case DocumentReviewStatus.approved:
        return const Color(0xFFECFDF5);
      case DocumentReviewStatus.rejected:
        return const Color(0xFFFEE2E2);
      case DocumentReviewStatus.moreDetailsNeeded:
        return const Color(0xFFEFF6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allDocs = _service.documents;
        final companies = ['All', ..._service.clientCompanies];

        final filteredDocs = allDocs.where((doc) {
          final matchesSearch = doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.uploadedBy.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.category.toLowerCase().contains(_searchQuery.toLowerCase());

          final matchesStatus = _selectedStatusFilter == null || doc.status == _selectedStatusFilter;

          final matchesCompany = _selectedCompanyFilter == 'All' || doc.companyName == _selectedCompanyFilter;

          return matchesSearch && matchesStatus && matchesCompany;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () => _service.syncFromBackend(),
            color: const Color(0xFF062AAE),
            child: CustomScrollView(
              slivers: [
                // Filter Header Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Document Review Queue',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_service.profile.name} • ${_service.profile.licenseNo.split(' /').first}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF062AAE), size: 22),
                              onPressed: () async {
                                await _service.syncFromBackend();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _service.isConnectedToBackend
                                            ? 'Synced live client files from MySect backend'
                                            : 'Synchronized local review queue',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFF062AAE),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              hintText: 'Search file name, company, or category...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Metric Status Chips Row (Clean, Neutral Filter)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildMetricChip(
                                label: 'All Files',
                                count: allDocs.length,
                                isSelected: _selectedStatusFilter == null,
                                onTap: () => setState(() => _selectedStatusFilter = null),
                              ),
                              const SizedBox(width: 8),
                              _buildMetricChip(
                                label: 'Action Needed',
                                count: _service.pendingCount,
                                isSelected: _selectedStatusFilter == DocumentReviewStatus.pendingReview,
                                onTap: () => setState(() => _selectedStatusFilter = DocumentReviewStatus.pendingReview),
                              ),
                              const SizedBox(width: 8),
                              _buildMetricChip(
                                label: 'Approved',
                                count: _service.approvedCount,
                                isSelected: _selectedStatusFilter == DocumentReviewStatus.approved,
                                onTap: () => setState(() => _selectedStatusFilter = DocumentReviewStatus.approved),
                              ),
                              const SizedBox(width: 8),
                              _buildMetricChip(
                                label: 'Clarifications',
                                count: _service.moreDetailsCount,
                                isSelected: _selectedStatusFilter == DocumentReviewStatus.moreDetailsNeeded,
                                onTap: () => setState(() => _selectedStatusFilter = DocumentReviewStatus.moreDetailsNeeded),
                              ),
                              const SizedBox(width: 8),
                              _buildMetricChip(
                                label: 'Rejected',
                                count: _service.rejectedCount,
                                isSelected: _selectedStatusFilter == DocumentReviewStatus.rejected,
                                onTap: () => setState(() => _selectedStatusFilter = DocumentReviewStatus.rejected),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Company Dropdown Filter Row
                        Row(
                          children: [
                            Text(
                              'Company Filter:',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedCompanyFilter,
                                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
                                    items: companies.map((c) {
                                      return DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(fontSize: 11),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedCompanyFilter = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Documents List
                if (filteredDocs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No documents found in queue',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adjust filter criteria or pull to refresh',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = filteredDocs[index];
                          return _buildDocumentCard(doc);
                        },
                        childCount: filteredDocs.length,
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

  Widget _buildMetricChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF062AAE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF062AAE) : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(ClientDocument doc) {
    final statusColor = _getStatusColor(doc.status);
    final statusBg = _getStatusBg(doc.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentReviewDetailPage(document: doc),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category tag and Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doc.category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      doc.status.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title and File info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF062AAE).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF062AAE),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc.companyName} • ${doc.fileSize}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
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
              const SizedBox(height: 12),

              // Uploader & Storage Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${doc.uploadedBy} (${doc.uploadedByRole.split(' ').first})',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    doc.uploadedAt.split(' ').first,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
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
