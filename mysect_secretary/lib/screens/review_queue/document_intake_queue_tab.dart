import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/client_document_model.dart';
import '../../services/secretary_document_service.dart';
import 'document_review_detail_page.dart';

class DocumentIntakeQueueTab extends StatefulWidget {
  const DocumentIntakeQueueTab({super.key});

  @override
  State<DocumentIntakeQueueTab> createState() => _DocumentIntakeQueueTabState();
}

class _DocumentIntakeQueueTabState extends State<DocumentIntakeQueueTab> {
  final SecretaryDocumentService _service = SecretaryDocumentService.instance;
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.hasClients && _scrollController.offset > 160;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

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

        final filteredDocs = allDocs.where((doc) {
          final query = _searchQuery.trim().toLowerCase();
          if (query.isEmpty) return true;
          return doc.title.toLowerCase().contains(query) ||
              doc.companyName.toLowerCase().contains(query) ||
              doc.category.toLowerCase().contains(query);
        }).toList();

        final Map<String, List<ClientDocument>> groupedByCompany = {};
        for (final doc in filteredDocs) {
          groupedByCompany.putIfAbsent(doc.companyName, () => []).add(doc);
        }
        final companyEntries = groupedByCompany.entries.toList();

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _showScrollToTop
              ? FloatingActionButton.small(
                  heroTag: 'review_queue_scroll_top',
                  onPressed: _scrollToTop,
                  backgroundColor: const Color(0xFF062AAE),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  tooltip: 'Scroll to top',
                  child: const Icon(Icons.arrow_upward_rounded, size: 20),
                )
              : null,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 768;

              return RefreshIndicator(
                onRefresh: () => _service.syncFromBackend(),
                color: const Color(0xFF062AAE),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Search Header Section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              hintText: 'Search file name or company...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Received Documents Grouped by Company
                    if (companyEntries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No received documents found',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search or pull to refresh',
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = companyEntries[index];
                              return _buildCompanyGroup(
                                companyName: entry.key,
                                docs: entry.value,
                                isDesktop: isDesktop,
                              );
                            },
                            childCount: companyEntries.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCompanyGroup({
    required String companyName,
    required List<ClientDocument> docs,
    required bool isDesktop,
  }) {
    final fileLabel = docs.length == 1 ? '1 file' : '${docs.length} files';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 16,
                      color: Color(0xFF062AAE),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    companyName,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fileLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 460,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 170,
              ),
              itemCount: docs.length,
              itemBuilder: (context, i) => _buildDocumentCard(docs[i], isGrid: true),
            )
          else
            Column(
              children: [
                for (final doc in docs) _buildDocumentCard(doc, isGrid: false),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(ClientDocument doc, {bool isGrid = false}) {
    final statusColor = _getStatusColor(doc.status);
    final statusBg = _getStatusBg(doc.status);

    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
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
                      doc.isSigned ? 'Signed' : doc.status.label,
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
                          doc.companyName,
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

              // Footer: System source badge (only for MySect Security System) & Date
              Builder(
                builder: (context) {
                  final isSystemNotice = doc.uploadedBy
                      .toLowerCase()
                      .contains('mysect security system');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isSystemNotice)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.security_rounded,
                                  size: 12,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'MySect Security System',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB91C1C),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            doc.uploadedAt.split(' ').first,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
