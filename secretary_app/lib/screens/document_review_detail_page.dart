import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/client_document_model.dart';
import '../services/secretary_document_service.dart';
import '../models/ssm_filing_model.dart';
import '../services/secretary_filing_service.dart';
import '../widgets/app_top_header.dart';

class DocumentReviewDetailPage extends StatefulWidget {
  final ClientDocument document;

  const DocumentReviewDetailPage({super.key, required this.document});

  @override
  State<DocumentReviewDetailPage> createState() =>
      _DocumentReviewDetailPageState();
}

class _DocumentReviewDetailPageState extends State<DocumentReviewDetailPage> {
  final SecretaryDocumentService _service = SecretaryDocumentService.instance;
  late ClientDocument _doc;

  @override
  void initState() {
    super.initState();
    _doc = widget.document;
  }

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

  // --- ACTION 1: SECRETARY DIGITAL SIGNING & APPROVAL SHEET ---
  void _showApproveBottomSheet() {
    int signatureMode = 0; // 0 = Official PKI Seal, 1 = Draw Signature
    bool declarationConfirmed = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final profile = _service.profile;

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
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.draw_rounded,
                            color: Color(0xFF059669),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secretary Digital Signature',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Official Statutory Endorsement • Companies Act 2016',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Secretary Credential Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF062AAE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Licensed',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'License: ${profile.licenseNo}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                Text(
                                  profile.firmName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Signature Mode Selector
                    Text(
                      'Endorsement Signature Method',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => signatureMode = 0),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: signatureMode == 0 ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: signatureMode == 0 ? const Color(0xFF2563EB) : Colors.grey.shade300,
                                  width: signatureMode == 0 ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.military_tech_rounded,
                                    size: 16,
                                    color: signatureMode == 0 ? const Color(0xFF2563EB) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Official PKI Seal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: signatureMode == 0 ? const Color(0xFF2563EB) : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => signatureMode = 1),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: signatureMode == 1 ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: signatureMode == 1 ? const Color(0xFF2563EB) : Colors.grey.shade300,
                                  width: signatureMode == 1 ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: signatureMode == 1 ? const Color(0xFF2563EB) : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Draw Signature',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: signatureMode == 1 ? const Color(0xFF2563EB) : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (signatureMode == 0) ...[
                      // PKI Seal Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF16A34A)),
                              ),
                              child: const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SSM STATUTORY SECRETARY ENDORSEMENT SEAL',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                  Text(
                                    'Practising License: ${profile.licenseNo}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    'Cert ID: MYSECT-PKI-CA48192-STAMP',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Draw signature pad
                      _SignatureDrawingPad(
                        onHasDrawnChanged: (_) {},
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Statutory confirmation check
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          declarationConfirmed = !declarationConfirmed;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            declarationConfirmed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            color: declarationConfirmed ? const Color(0xFF059669) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'I hereby certify and endorse that this document has been reviewed in compliance with the Companies Act 2016, and authenticate its contents under my secretarial practising certificate.',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: Colors.grey.shade700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.verified_rounded, size: 18),
                        label: Text(
                          'Sign & Approve Document',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: !declarationConfirmed
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(modalCtx);

                                await _service.signAndApproveDocument(
                                  _doc.id,
                                  remarks: 'Statutory compliance reviewed and endorsed under License ${profile.licenseNo}.',
                                  signatureType: signatureMode == 0 ? 'official_seal' : 'draw_signature',
                                );

                                if (!mounted) return;
                                final updated = _service.documents.firstWhere(
                                  (d) => d.id == _doc.id,
                                  orElse: () => _doc,
                                );
                                setState(() {
                                  _doc = updated;
                                });

                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Document digitally signed & approved under License MIA CA 48192!',
                                            style: GoogleFonts.poppins(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF059669),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              },
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

  // --- ACTION: OPEN FULL DOCUMENT VIEWER ---
  void _openFullDocumentViewer(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (viewerCtx) {
        return _FullDocumentViewerDialog(
          document: _doc,
          onSignRequested: () {
            Navigator.pop(viewerCtx);
            _showApproveBottomSheet();
          },
        );
      },
    );
  }

  // --- ACTION 2: REJECT BOTTOM SHEET ---
  void _showRejectBottomSheet() {
    final customReasonController = TextEditingController();
    String selectedReason = 'Signatures missing or incomplete';

    final rejectionOptions = [
      'Signatures missing or incomplete',
      'Scan resolution is illegible / blurry',
      'NRIC / Passport validity expired or less than 6 months',
      'Inconsistent director particulars against SSM Form 48A',
      'Missing formal tenancy proof / stamp certificate for Section 46',
      'Other non-compliance with Companies Act 2016',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 28,
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cancel_rounded,
                          color: Color(0xFFDC2626),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reject Document',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Notify client to submit a replacement',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Statutory Rejection Reason',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedReason,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: rejectionOptions.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(
                              opt,
                              style: GoogleFonts.poppins(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedReason = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Specific Notes / Instructions to Client',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: customReasonController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g. Please resign with a fresh wet-ink signature or digital certificate and re-upload.',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Reject Document & Notify Client',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(modalCtx);
                        final finalReason = customReasonController.text.trim().isNotEmpty
                            ? '${customReasonController.text.trim()} ($selectedReason)'
                            : selectedReason;

                        await _service.reviewDocument(
                          _doc.id,
                          DocumentReviewStatus.rejected,
                          rejectionReason: finalReason,
                        );
                        if (!mounted) return;
                        setState(() {});
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Document marked as Rejected and client notified.',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- ACTION 3: ASK FOR MORE DETAILS BOTTOM SHEET ---
  void _showAskDetailsBottomSheet() {
    final detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 28,
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask for More Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Request clarifications or supporting filings',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Statutory Templates',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildQuickTemplateChip(
                        'Missing Form 48A Consent',
                        'Please provide statutory Form 48A (Consent to Act as Director) pursuant to Section 201 of Companies Act 2016.',
                        detailsController,
                        setModalState,
                      ),
                      _buildQuickTemplateChip(
                        'Certified NRIC (CTC)',
                        'Please provide Certified True Copy (CTC) of NRIC / Passport (front & back with signature verified).',
                        detailsController,
                        setModalState,
                      ),
                      _buildQuickTemplateChip(
                        'Section 251 Statement',
                        'Financial statements must include signed Directors\' Statement pursuant to Section 251 of Companies Act 2016.',
                        detailsController,
                        setModalState,
                      ),
                      _buildQuickTemplateChip(
                        'Quorum Signatures',
                        'Board resolution requires formal signatures from the statutory director quorum before SSM filing.',
                        detailsController,
                        setModalState,
                      ),
                      _buildQuickTemplateChip(
                        'Registered Address Proof',
                        'Please provide latest tenancy agreement or utility bill for registered office address verification.',
                        detailsController,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Clarification Request to Client',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Select a template above or type clarification instructions...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        'Send Request to Client',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if (detailsController.text.trim().isEmpty) return;
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(modalCtx);
                        await _service.reviewDocument(
                          _doc.id,
                          DocumentReviewStatus.moreDetailsNeeded,
                          requestedDetails: detailsController.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() {});
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Request for details sent to client successfully!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickTemplateChip(
    String label,
    String fullText,
    TextEditingController controller,
    StateSetter setModalState,
  ) {
    return InkWell(
      onTap: () {
        setModalState(() {
          controller.text = fullText;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 12, color: Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateFilingProgressSheet(BuildContext context, SsmFiling filing) {
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
            final currentIdx = filing.currentStepIndex;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
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
                          Icons.alt_route_rounded,
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
                              'Update Filing Stage',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${filing.referenceNo} â€¢ ${filing.companyName}',
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
                  const SizedBox(height: 16),
                  Text(
                    'Select Current Milestone:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...filing.timeline.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isCurrent = idx == currentIdx;
                    final isDone = idx < currentIdx;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFEFF6FF)
                            : (isDone ? const Color(0xFFF8FAFC) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade200,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        leading: Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : (isCurrent
                                  ? Icons.timelapse_rounded
                                  : Icons.radio_button_unchecked),
                          color: isDone
                              ? const Color(0xFF059669)
                              : (isCurrent ? const Color(0xFF2563EB) : Colors.grey.shade400),
                          size: 20,
                        ),
                        title: Text(
                          step.title,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent ? const Color(0xFF1E40AF) : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          step.description,
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isCurrent
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  await SecretaryFilingService.instance.updateFilingStep(
                                    referenceNo: filing.referenceNo,
                                    targetStepIndex: idx,
                                  );
                                  if (modalCtx.mounted) Navigator.pop(modalCtx);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF059669),
                                        content: Text(
                                          'Filing stage updated to "${step.title}"! Pushed to client mobile app.',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Set Stage',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF062AAE),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilingProgressSection(BuildContext context) {
    return AnimatedBuilder(
      animation: SecretaryFilingService.instance,
      builder: (context, _) {
        final filing = SecretaryFilingService.instance.getFilingByRefOrCompany(
          _doc.linkedFilingRef,
          _doc.companyName,
        );
        if (filing == null) return const SizedBox.shrink();

        final currentIdx = filing.currentStepIndex;
        final currentStep = filing.timeline[currentIdx];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF062AAE).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.linear_scale_rounded,
                          color: Color(0xFF062AAE),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Statutory Filing Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: filing.status.bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Step ${currentIdx + 1} of ${filing.timeline.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: filing.status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentStep.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.timelapse_rounded,
                      size: 16,
                      color: currentStep.isCompleted
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentStep.title,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF062AAE),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showUpdateFilingProgressSheet(context, filing),
                      icon: const Icon(Icons.edit_note_rounded, size: 14),
                      label: Text(
                        'Update',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_doc.status);
    final statusBg = _getStatusBg(_doc.status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const AppTopHeader(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _doc.status.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Document Review',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _openFullDocumentViewer(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF062AAE).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFF062AAE),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doc.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_doc.category} • ${_doc.fileSize}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _doc.companyName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF062AAE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),
                  _buildMetaRow('Company Registration', _doc.companySsmNo),
                  _buildMetaRow('Uploaded By', '${_doc.uploadedBy} (${_doc.uploadedByRole})'),
                  _buildMetaRow('Upload Timestamp', _doc.uploadedAt),
                  _buildMetaRow('Encrypted Storage', _cleanStorageLocation(_doc.storageLocation)),
                  _buildMetaRow('SHA-256 Digest', '${_doc.sha256Hash.substring(0, 16)}...'),
                  if (_doc.linkedFilingRef.isNotEmpty)
                    _buildMetaRow('Linked SSM Filing Ref', _doc.linkedFilingRef),
                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF062AAE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: Text(
                            'Open Document',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _openFullDocumentViewer(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review Status Alert Banner
            if (_doc.status == DocumentReviewStatus.approved) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approved by ${_doc.reviewDetails?.reviewedBy ?? "Secretary"}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Verified and endorsed for statutory compliance.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_doc.status == DocumentReviewStatus.rejected) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejected by ${_doc.reviewDetails?.reviewedBy ?? "Secretary"}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _doc.reviewDetails?.rejectionReason ?? 'Document does not meet SSM statutory filing criteria.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_doc.status == DocumentReviewStatus.moreDetailsNeeded) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clarification Requested by ${_doc.reviewDetails?.reviewedBy ?? "Secretary"}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _doc.reviewDetails?.requestedDetails ?? 'Additional supporting documents requested from client.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],



            _buildFilingProgressSection(context),

            // Audit Trail Timeline
            Text(
              'Audit & Verification Trail',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: _doc.auditTrail.map((audit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF062AAE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    audit.action,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF062AAE),
                                    ),
                                  ),
                                  Text(
                                    audit.timestamp,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${audit.actor}: ${audit.details}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 100), // padding for bottom bar
          ],
        ),
      ),
    ),
  ],
),
),

      // Fixed Bottom Secretary Review Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 42,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reject Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showRejectBottomSheet,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(
                      'Reject',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Ask Details Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showAskDetailsBottomSheet,
                    icon: const Icon(Icons.help_outline_rounded, size: 16),
                    label: Text(
                      'Ask Details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Sign Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showApproveBottomSheet,
                    icon: Icon(
                      _doc.isSigned ? Icons.verified_rounded : Icons.draw_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _doc.isSigned ? 'Signed' : 'Sign',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  String _cleanStorageLocation(String loc) {
    if (loc.contains('TM One Cloud Alpha') || loc.contains('Cyberjaya') || loc.contains('DC1')) {
      return 'TM Cloud';
    }
    return loc;
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FULL DOCUMENT VIEWER MODAL
// ==========================================
class _FullDocumentViewerDialog extends StatefulWidget {
  final ClientDocument document;
  final VoidCallback onSignRequested;

  const _FullDocumentViewerDialog({
    required this.document,
    required this.onSignRequested,
  });

  @override
  State<_FullDocumentViewerDialog> createState() =>
      _FullDocumentViewerDialogState();
}

class _FullDocumentViewerDialogState extends State<_FullDocumentViewerDialog> {
  int _currentPage = 1;
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final isApproved = doc.isSigned || doc.status == DocumentReviewStatus.approved;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF062AAE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${doc.companyName} • ${doc.category}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Compact Zoom Controls Pill
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _zoom = (_zoom - 0.15).clamp(0.6, 1.8)),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(Icons.remove_rounded, color: Colors.white70, size: 15),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _zoom = 1.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${(_zoom * 100).toInt()}%',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _zoom = (_zoom + 0.15).clamp(0.6, 1.8)),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(Icons.add_rounded, color: Colors.white70, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 19),
                    tooltip: 'Download Document',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading ${doc.originalName} from secure vault...'),
                          backgroundColor: const Color(0xFF062AAE),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Page Selector Navigation Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPagePill(1, '1. Particulars'),
                          const SizedBox(width: 6),
                          _buildPagePill(2, '2. Declarations'),
                          const SizedBox(width: 6),
                          _buildPagePill(3, '3. Signatures'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isApproved ? 'Approved' : doc.status.label,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Document Canvas Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Center(
                  child: Transform.scale(
                    scale: _zoom,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 580),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Official Malaysian Header
                          Center(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF062AAE).withValues(alpha: 0.1),
                                        border: Border.all(color: const Color(0xFF062AAE)),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.shield_rounded, color: Color(0xFF062AAE), size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'SURUHANJAYA SYARIKAT MALAYSIA',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'COMPANIES COMMISSION OF MALAYSIA',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'COMPANIES ACT 2016 [ACT 777]',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF062AAE),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: const Color(0xFF062AAE),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Render Page Content
                          if (_currentPage == 1)
                            _buildDocumentPage1(doc)
                          else if (_currentPage == 2)
                            _buildDocumentPage2(doc)
                          else
                            _buildDocumentPage3(doc, isApproved),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation & Quick Sign Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios_new, size: 11),
                        label: Text('Prev', style: GoogleFonts.poppins(fontSize: 10.5)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_currentPage / 3',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _currentPage < 3
                            ? () => setState(() => _currentPage++)
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios, size: 11),
                        label: Text('Next', style: GoogleFonts.poppins(fontSize: 10.5)),
                      ),
                    ],
                  ),
                  if (!isApproved)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.draw_rounded, size: 15),
                      label: Text(
                        'Sign & Endorse',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: widget.onSignRequested,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF059669)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFF34D399), size: 15),
                          const SizedBox(width: 5),
                          Text(
                            'Signed & Endorsed',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagePill(int page, String label) {
    final isSel = _currentPage == page;
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF062AAE) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? Colors.white : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  // --- PAGE 1: STATUTORY PARTICULARS ---
  Widget _buildDocumentPage1(ClientDocument doc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                doc.category.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: const Color(0xFF062AAE),
                ),
              ),
              Text(
                'LODGEMENT REF: ${doc.linkedFilingRef.isNotEmpty ? doc.linkedFilingRef : "SSM/S68/2026/04812"}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '1. COMPANY PARTICULARS',
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildDocTableRow('Company Name', doc.companyName),
        _buildDocTableRow('SSM Registration No.', doc.companySsmNo),
        _buildDocTableRow('Registered Office', 'Level 18, Menara TM, Jalan Pantai Baharu, 50672 Kuala Lumpur'),
        _buildDocTableRow('Principal Activity', 'Data Center Infrastructure, Cloud Migration & IT Architecture Consulting'),
        _buildDocTableRow('Share Capital', 'RM 500,000.00 Divided into 500,000 Ordinary Shares'),
        _buildDocTableRow('Financial Year End', '31 December 2026'),
        const SizedBox(height: 16),
        Text(
          '2. DIRECTORS & SECRETARIAL OFFICERS',
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Name & Designation', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('NRIC / License', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Status', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              _buildOfficerRow(doc.uploadedBy, doc.uploadedByRole, '880214-14-5521', 'Active Director'),
              const Divider(height: 1),
              _buildOfficerRow('Eidza Binti Jumanis', 'Director (Client)', '900512-10-6102', 'Active Director'),
              const Divider(height: 1),
              _buildOfficerRow('Lim Mei Ling', 'Licensed Secretary', 'MIA CA 48192', 'Active Secretary'),
            ],
          ),
        ),
      ],
    );
  }

  // --- PAGE 2: STATUTORY DECLARATION & RESOLUTIONS ---
  Widget _buildDocumentPage2(ClientDocument doc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'STATUTORY DECLARATION & BOARD RESOLUTIONS',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: const Color(0xFF062AAE),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'WHEREAS the Board of Directors of ${doc.companyName} at a duly convened meeting or via Directors\' Written Resolution pursuant to the Constitution of the Company, hereby resolve and declare:',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, height: 1.45),
        ),
        const SizedBox(height: 12),
        _buildStatutoryClause(
          '1. STATUTORY COMPLIANCE',
          'The directors confirm that all statements, financial declarations, and supporting statutory records have been compiled in accordance with the Malaysian Companies Act 2016 and applicable Malaysian Financial Reporting Standards (MFRS).',
        ),
        _buildStatutoryClause(
          '2. SECRETARIAL AUTHORIZATION',
          'The Company Secretary, Lim Mei Ling (MIA CA 48192 / LS 0009214) of SectPro Corporate Services Sdn Bhd, is hereby authorized to review, digitally endorse, and lodge this return with the Suruhanjaya Syarikat Malaysia (SSM).',
        ),
        _buildStatutoryClause(
          '3. REGISTERS AND ACCURACY',
          'All statutory registers including the register of members, directors, managers, and debenture holders are maintained and kept current at the registered office address.',
        ),
        _buildStatutoryClause(
          '4. SOLVENCY DECLARATION',
          'The directors confirm that the company is solvent and will be able to meet all debts and obligations as and when they fall due during the relevant statutory period.',
        ),
      ],
    );
  }

  // --- PAGE 3: EXECUTION & DIGITAL ENDORSEMENT ---
  Widget _buildDocumentPage3(ClientDocument doc, bool isApproved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'EXECUTION CLAUSE AND STATUTORY ENDORSEMENTS',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: const Color(0xFF062AAE),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'IN WITNESS WHEREOF the parties have caused this instrument to be executed with cryptographic signatures under the Digital Signature Act 1997.',
          style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 16),

        // Primary Signer: Director
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DIRECTOR / APPLICANT SIGNATURE',
                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF062AAE)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                    child: Text('e-KYC Level 3 Passed', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF059669), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.fingerprint, color: Color(0xFF062AAE), size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.uploadedBy, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${doc.uploadedByRole} • ${doc.companyName}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                        Text('Signed at: ${doc.uploadedAt} • SHA-256: ${doc.sha256Hash.substring(0, 16)}...', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Secondary Signer: Secretary Digital Endorsement Seal
        if (isApproved) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'SSM SECRETARIAL ENDORSEMENT SEAL',
                          style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)),
                      child: Text('VERIFIED', style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF059669), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.military_tech_rounded, color: Color(0xFF059669), size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.signedBy ?? 'Lim Mei Ling (MIA CA 48192)',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                          ),
                          Text(
                            'Licensed Company Secretary • SectPro Corporate Services Sdn Bhd',
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF047857)),
                          ),
                          Text(
                            'Seal Ref: ${doc.signatureSealId ?? "MYSECT-SIG-LML-001"} • Endorsed: ${doc.signedAt ?? doc.uploadedAt}',
                            style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(
                    'Certified that this document conforms to SSM Companies Act 2016 statutory requirements.',
                    style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF065F46), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'AWAITING SECRETARY DIGITAL ENDORSEMENT',
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pursuant to the Companies Act 2016, this document must be examined and endorsed by practicing secretary Lim Mei Ling (MIA CA 48192) prior to official lodgement with SSM.',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFFB45309), height: 1.4),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.draw_rounded, size: 16),
                    label: Text(
                      'Sign & Endorse Document Now',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: widget.onSignRequested,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDocTableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerRow(String name, String role, String icOrLic, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold)),
                Text(role, style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(icOrLic, style: GoogleFonts.poppins(fontSize: 10))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryClause(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF062AAE))),
          const SizedBox(height: 3),
          Text(body, style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}

// ==========================================
// SIGNATURE DRAWING PAD WIDGET & PAINTER
// ==========================================
class _SignatureDrawingPad extends StatefulWidget {
  final ValueChanged<bool> onHasDrawnChanged;

  const _SignatureDrawingPad({required this.onHasDrawnChanged});

  @override
  State<_SignatureDrawingPad> createState() => _SignatureDrawingPadState();
}

class _SignatureDrawingPadState extends State<_SignatureDrawingPad> {
  final List<Offset?> _points = [];

  void _clear() {
    setState(() {
      _points.clear();
    });
    widget.onHasDrawnChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sign with finger or stylus:',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            TextButton.icon(
              onPressed: _points.isEmpty ? null : _clear,
              icon: const Icon(Icons.refresh_rounded, size: 14),
              label: Text(
                'Clear',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF062AAE).withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                if (_points.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded, color: Colors.grey.shade400, size: 30),
                        const SizedBox(height: 4),
                        Text(
                          'Lim Mei Ling (Draw signature here)',
                          style: GoogleFonts.caveat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _points.add(details.localPosition);
                    });
                    widget.onHasDrawnChanged(true);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _points.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _points.add(null);
                    });
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(_points),
                    size: Size.infinite,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Stylus / Touch Active',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF062AAE)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
