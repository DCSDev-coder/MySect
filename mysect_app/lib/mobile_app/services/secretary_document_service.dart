import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/client_document_model.dart';
import 'ssm_filing_service.dart';

class SecretaryDocumentService extends ChangeNotifier {
  static final SecretaryDocumentService _instance =
      SecretaryDocumentService._internal();
  static SecretaryDocumentService get instance => _instance;

  SecretaryDocumentService._internal() {
    _initDefaultDocuments();
    syncFromBackend();
  }

  List<ClientDocument> _documents = [];
  bool _isSyncing = false;
  bool _isConnectedToBackend = false;
  String _activeSecretary = 'Lim Mei Ling (MIA CA 48192)';

  List<ClientDocument> get documents => List.unmodifiable(_documents);
  bool get isSyncing => _isSyncing;
  bool get isConnectedToBackend => _isConnectedToBackend;
  String get activeSecretary => _activeSecretary;

  int get pendingCount => _documents
      .where((d) => d.status == DocumentReviewStatus.pendingReview)
      .length;
  int get approvedCount =>
      _documents.where((d) => d.status == DocumentReviewStatus.approved).length;
  int get rejectedCount =>
      _documents.where((d) => d.status == DocumentReviewStatus.rejected).length;
  int get moreDetailsCount => _documents
      .where((d) => d.status == DocumentReviewStatus.moreDetailsNeeded)
      .length;

  List<ClientDocument> get unsortedDocuments => _documents
      .where(
        (d) =>
            d.folder == 'Unsorted' ||
            (d.folder == null &&
                d.status == DocumentReviewStatus.pendingReview),
      )
      .toList();

  int get unsortedCount => unsortedDocuments.length;

  List<ClientDocument> getDocumentsForFolder(String folderName) {
    return _documents
        .where(
          (d) =>
              d.effectiveFolder.toLowerCase() == folderName.toLowerCase() &&
              d.folder != 'Unsorted',
        )
        .toList();
  }

  int getFolderDocumentCount(String folderName) {
    return getDocumentsForFolder(folderName).length;
  }

  void moveDocument(String docId, String targetFolder) {
    final index = _documents.indexWhere((d) => d.id == docId);
    if (index != -1) {
      _documents[index].folder = targetFolder;
      _documents[index].auditTrail.add(
        DocumentAuditItem(
          timestamp: DateTime.now()
              .toIso8601String()
              .substring(0, 16)
              .replaceAll('T', ' '),
          action: 'MOVED_TO_FOLDER',
          actor: 'Adam Bin Hamzah (Managing Director)',
          details: 'Moved document to $targetFolder folder.',
        ),
      );
      notifyListeners();
    }
  }

  void moveDocuments(List<String> docIds, String targetFolder) {
    final now = DateTime.now()
        .toIso8601String()
        .substring(0, 16)
        .replaceAll('T', ' ');
    for (final docId in docIds) {
      final index = _documents.indexWhere((d) => d.id == docId);
      if (index != -1) {
        _documents[index].folder = targetFolder;
        _documents[index].auditTrail.add(
          DocumentAuditItem(
            timestamp: now,
            action: 'MOVED_TO_FOLDER',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Moved document to $targetFolder folder.',
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> reuploadDocument(
    String docId,
    String newFileName,
    String newFileSize,
  ) async {
    final index = _documents.indexWhere((d) => d.id == docId);
    if (index == -1) return;
    final doc = _documents[index];
    doc.title = newFileName;
    doc.fileSize = newFileSize;
    doc.status = DocumentReviewStatus.pendingReview;
    doc.auditTrail.add(
      DocumentAuditItem(
        timestamp: DateTime.now()
            .toIso8601String()
            .substring(0, 16)
            .replaceAll('T', ' '),
        action: 'FILE_REUPLOADED',
        actor: 'Adam Bin Hamzah (Managing Director)',
        details:
            'Uploaded replacement file $newFileName ($newFileSize) in response to secretary query.',
      ),
    );
    notifyListeners();
  }

  void setActiveSecretary(String name) {
    _activeSecretary = name;
    notifyListeners();
  }

  void _initDefaultDocuments() {
    _documents = [
      ClientDocument(
        id: 'DOC-2026-001',
        title: 'DCS_Management_Accounts_FY2026.pdf',
        originalName: 'DCS_Management_Accounts_FY2026.pdf',
        category: 'Annual Return (Section 68)',
        fileSize: '2.4 MB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-20 14:30',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-01/DCS_Management_Accounts_FY2026.pdf',
        sha256Hash:
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/S68/2026/04812',
        submissionNotes:
            'Uploaded unaudited management accounts and draft statements for Annual Return submission.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-20 14:30:12',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details:
                'Uploaded from MySect Mobile App to TM Cloud encrypted vault.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-002',
        title: 'Dato_Adam_Profile_Resume.pdf',
        originalName: 'Dato_Adam_Profile_Resume.pdf',
        category: 'Director Appointment (Section 58)',
        fileSize: '1.2 MB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-18 10:00',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-01/Dato_Adam_Profile_Resume.pdf',
        sha256Hash:
            '4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945',
        status: DocumentReviewStatus.moreDetailsNeeded,
        linkedFilingRef: 'SSM/S58/2026/01192',
        submissionNotes:
            'Candidate profile for new non-executive board member appointment.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Lim Mei Ling (MIA CA 48192)',
          reviewedAt: '2026-10-19 11:20',
          decision: 'More Details Needed',
          internalNotes:
              'Profile received, but statutory compliance requires Section 201 Consent to Act and clear NRIC copies.',
          requestedDetails:
              'Under Section 201 Companies Act 2016, please provide signed Form 48A (Consent to Act as Director) and clear scanned copy of Dato\' Adam\'s NRIC (front and back).',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-18 10:00:22',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-10-19 11:20:45',
            action: 'DETAILS_REQUESTED',
            actor: 'Lim Mei Ling (MIA CA 48192)',
            details:
                'Requested Form 48A Consent to Act and NRIC copy before Section 58 submission.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-003',
        title: 'Signed_Board_Resolution_S46.pdf',
        originalName: 'Signed_Board_Resolution_S46.pdf',
        category: 'Change of Registered Office (Section 46)',
        fileSize: '640 KB',
        fileType: 'application/pdf',
        companyId: 'comp-02',
        companyName: 'C2 Coffee + Candle',
        companySsmNo: '202001019482 (1382941-T)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Azman bin Ibrahim (MAICSA 7019284)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Director (Client)',
        uploadedAt: '2026-10-12 16:45',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-02/Signed_Board_Resolution_S46.pdf',
        sha256Hash:
            '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b',
        status: DocumentReviewStatus.approved,
        linkedFilingRef: 'SSM/S46/2026/00731',
        submissionNotes:
            'Directors circular resolution approving change of registered office address to Menara Binjai.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Azman bin Ibrahim (MAICSA 7019284)',
          reviewedAt: '2026-10-14 10:30',
          decision: 'Approved',
          remarks:
              'All signatures verified against records. Form 46 submitted to SSM.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-12 16:45:00',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-10-14 10:30:15',
            action: 'FILE_APPROVED',
            actor: 'Azman bin Ibrahim (MAICSA 7019284)',
            details: 'Verified and approved for SSM submission.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-004',
        title: 'Bank_In_Slip_Capital_RM30k.pdf',
        originalName: 'Bank_In_Slip_Capital_RM30k.pdf',
        category: 'Share Allotment (Section 78)',
        fileSize: '890 KB',
        fileType: 'application/pdf',
        companyId: 'comp-03',
        companyName: '5Luxe Scents Co.',
        companySsmNo: '202201082918 (1482910-P)',
        assignedFirmId: 'firm-02',
        assignedFirmName: 'Apex Corporate Secretarial Partners',
        assignedSecretary: 'Sarah binti Ahmad (MAICSA 6028192)',
        uploadedBy: 'Eidza Binti Jumanis',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-09-20 11:00',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-03/Bank_In_Slip_Capital_RM30k.pdf',
        sha256Hash:
            '1f2e3d4c5b6a798890abcdcdef0123456789abcdef0123456789abcdef012345',
        status: DocumentReviewStatus.approved,
        linkedFilingRef: 'SSM/S78/2026/00194',
        submissionNotes:
            'Proof of RM 30,000 capital injection for increase of paid-up capital.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Sarah binti Ahmad (MAICSA 6028192)',
          reviewedAt: '2026-09-22 14:15',
          decision: 'Approved',
          remarks:
              'Capital injection proof verified. Form 78 submitted and SSM certificate generated.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-09-20 11:00:30',
            action: 'FILE_UPLOADED',
            actor: 'Eidza Binti Jumanis (Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-09-22 14:15:10',
            action: 'FILE_APPROVED',
            actor: 'Sarah binti Ahmad (MAICSA 6028192)',
            details: 'Payment proof authenticated.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-005',
        title: 'New_Investor_Passport_Scan.pdf',
        originalName: 'New_Investor_Passport_Scan.pdf',
        category: 'Identity Verification (e-KYC)',
        fileSize: '1.8 MB',
        fileType: 'application/pdf',
        companyId: 'comp-03',
        companyName: '5Luxe Scents Co.',
        companySsmNo: '202201082918 (1482910-P)',
        assignedFirmId: 'firm-02',
        assignedFirmName: 'Apex Corporate Secretarial Partners',
        assignedSecretary: 'Sarah binti Ahmad (MAICSA 6028192)',
        uploadedBy: 'Eidza Binti Jumanis',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-15 09:30',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-03/New_Investor_Passport_Scan.pdf',
        sha256Hash:
            '8b7a6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b',
        status: DocumentReviewStatus.rejected,
        linkedFilingRef: 'SSM/S78/2026/00194',
        submissionNotes:
            'Foreign investor passport copy for member register entry.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Sarah binti Ahmad (MAICSA 6028192)',
          reviewedAt: '2026-10-16 11:00',
          decision: 'Rejected',
          rejectionReason:
              'Passport scan is blurry and expires in less than 3 months. SSM regulations require valid passport with minimum 6 months validity.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-15 09:30:10',
            action: 'FILE_UPLOADED',
            actor: 'Eidza Binti Jumanis (Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-10-16 11:00:25',
            action: 'FILE_REJECTED',
            actor: 'Sarah binti Ahmad (MAICSA 6028192)',
            details: 'Rejected due to expiry and poor scan resolution.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-007',
        title: 'Director_Declaration_Form.pdf',
        originalName: 'Director_Declaration_Form.pdf',
        category: 'Director Statutory Declaration',
        fileSize: '850 KB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-20 14:35',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-01/Director_Declaration_Form.pdf',
        sha256Hash:
            '3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/S68/2026/04812',
        submissionNotes:
            'Statutory declaration of solvency and director verification.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-20 14:35:10',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-008',
        title: 'Tenancy_Agreement_DCS_Office.pdf',
        originalName: 'Tenancy_Agreement_DCS_Office.pdf',
        category: 'Proof of Address / Tenancy',
        fileSize: '3.1 MB',
        fileType: 'application/pdf',
        companyId: 'comp-02',
        companyName: 'C2 Coffee + Candle',
        companySsmNo: '202001019482 (1382941-T)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Azman bin Ibrahim (MAICSA 7019284)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Director (Client)',
        uploadedAt: '2026-10-12 16:40',
        storageLocation: 'TM Cloud',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-02/Tenancy_Agreement_DCS_Office.pdf',
        sha256Hash:
            '7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/S46/2026/00731',
        submissionNotes:
            'Stamped tenancy agreement supporting change of registered address.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-12 16:40:15',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Director)',
            details: 'Uploaded from MySect Mobile App.',
          ),
        ],
        folder: 'Other',
      ),
      ClientDocument(
        id: 'DOC-UNSORTED-01',
        title: 'Scanned Document 01',
        originalName: 'Scanned_Doc_01.pdf',
        category: 'Scanned Statutory Form',
        fileSize: '1.2 MB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: 'Today, 11:15 AM',
        storageLocation: 'TM Cloud',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-01/Scanned_Doc_01.pdf',
        sha256Hash:
            'a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/GEN/2026/01',
        submissionNotes:
            'Newly scanned document awaiting sorting and secretary review.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-27 11:15:00',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded to TM Cloud unsorted queue.',
          ),
        ],
        folder: 'Unsorted',
      ),
      ClientDocument(
        id: 'DOC-UNSORTED-02',
        title: 'IMG_20251120.jpg',
        originalName: 'IMG_20251120.jpg',
        category: 'Statutory Notice Scan',
        fileSize: '2.5 MB',
        fileType: 'image/jpeg',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: 'Yesterday, 02:20 PM',
        storageLocation: 'TM Cloud',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-01/IMG_20251120.jpg',
        sha256Hash:
            'b2c3d4e5f6a178901234567890abcdef1234567890abcdef1234567890abcdef',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/GEN/2026/02',
        submissionNotes: 'Notice image uploaded from mobile camera.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-26 14:20:00',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded to TM Cloud unsorted queue.',
          ),
        ],
        folder: 'Unsorted',
      ),
      ClientDocument(
        id: 'DOC-UNSORTED-03',
        title: 'Unknown_Attachment.pdf',
        originalName: 'Unknown_Attachment.pdf',
        category: 'Unclassified Document',
        fileSize: '980 KB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: 'Yesterday, 10:05 AM',
        storageLocation: 'TM Cloud',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-01/Unknown_Attachment.pdf',
        sha256Hash:
            'c3d4e5f6a1b278901234567890abcdef1234567890abcdef1234567890abcdef',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/GEN/2026/03',
        submissionNotes: 'Uploaded document awaiting categorization.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-26 10:05:00',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded to TM Cloud unsorted queue.',
          ),
        ],
        folder: 'Unsorted',
      ),
    ];
  }

  // Sync documents from backend API if available
  Future<void> syncFromBackend() async {
    _isSyncing = true;
    notifyListeners();

    final candidateUrls = [
      'http://127.0.0.1:5173/api/documents',
      'http://localhost:5173/api/documents',
      'http://10.0.2.2:5173/api/documents',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final response = await http
            .get(uri)
            .timeout(const Duration(milliseconds: 1500));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            _documents = data
                .map(
                  (item) => ClientDocument.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();
            _isConnectedToBackend = true;
            _isSyncing = false;
            notifyListeners();
            return;
          }
        }
      } catch (_) {
        // Fallback to next candidate endpoint
      }
    }

    _isConnectedToBackend = false;
    _isSyncing = false;
    notifyListeners();
  }

  /// SECRETARY ACTION: Check and review a document (Approve, Reject, or Ask Details)
  Future<void> reviewDocument(
    String docId,
    DocumentReviewStatus decision, {
    String? remarks,
    String? rejectionReason,
    String? requestedDetails,
    String? internalNotes,
    String? customReviewer,
  }) async {
    final docIndex = _documents.indexWhere((d) => d.id == docId);
    if (docIndex == -1) return;

    final doc = _documents[docIndex];
    final reviewer = customReviewer ?? _activeSecretary;
    final now = DateTime.now();
    final nowStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    doc.status = decision;
    doc.reviewDetails = DocumentReviewDetails(
      reviewedBy: reviewer,
      reviewedAt: nowStr,
      decision: decision.label,
      remarks: decision == DocumentReviewStatus.approved
          ? (remarks ?? 'Approved for SSM compliance.')
          : null,
      rejectionReason: decision == DocumentReviewStatus.rejected
          ? (rejectionReason ?? 'Discrepancy in submitted statutory file.')
          : null,
      requestedDetails: decision == DocumentReviewStatus.moreDetailsNeeded
          ? (requestedDetails ??
                'Please provide additional supporting details.')
          : null,
      internalNotes: internalNotes,
    );

    String auditAction = 'FILE_REVIEWED';
    String auditDetail =
        'Secretary $reviewer checked the file: ${decision.label}';

    if (decision == DocumentReviewStatus.approved) {
      auditAction = 'FILE_APPROVED';
      auditDetail = 'Approved: ${remarks ?? "Statutory criteria verified"}';
    } else if (decision == DocumentReviewStatus.rejected) {
      auditAction = 'FILE_REJECTED';
      auditDetail = 'Rejected: $rejectionReason';
    } else if (decision == DocumentReviewStatus.moreDetailsNeeded) {
      auditAction = 'DETAILS_REQUESTED';
      auditDetail = 'Clarification requested: $requestedDetails';
    }

    doc.auditTrail.add(
      DocumentAuditItem(
        timestamp: nowStr,
        action: auditAction,
        actor: reviewer,
        details: auditDetail,
      ),
    );

    // Cross-link with SsmFilingService if attached to an SSM filing
    if (doc.linkedFilingRef.isNotEmpty) {
      _syncLinkedSsmFiling(
        doc,
        decision,
        remarks,
        rejectionReason,
        requestedDetails,
      );
    }

    notifyListeners();

    // Push review decision to backend API
    final candidateUrls = [
      'http://127.0.0.1:5173/api/documents/$docId/review',
      'http://localhost:5173/api/documents/$docId/review',
      'http://10.0.2.2:5173/api/documents/$docId/review',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http
            .patch(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'decision': decision.label,
                'reviewedBy': reviewer,
                'remarks': remarks,
                'rejectionReason': rejectionReason,
                'requestedDetails': requestedDetails,
                'internalNotes': internalNotes,
              }),
            )
            .timeout(const Duration(milliseconds: 1500));

        if (res.statusCode == 200) {
          _isConnectedToBackend = true;
          break;
        }
      } catch (_) {}
    }
  }

  // Keep SsmFilingService in sync with document actions
  void _syncLinkedSsmFiling(
    ClientDocument doc,
    DocumentReviewStatus decision,
    String? remarks,
    String? rejectionReason,
    String? requestedDetails,
  ) {
    try {
      final ssmService = SsmFilingService.instance;
      final matchingFiling = ssmService.filings.cast<dynamic>().firstWhere(
        (f) =>
            f.referenceNo == doc.linkedFilingRef ||
            f.companyId == doc.companyId,
        orElse: () => null,
      );

      if (matchingFiling != null) {
        if (decision == DocumentReviewStatus.moreDetailsNeeded) {
          ssmService.simulateSecretaryClarification(
            matchingFiling.id,
            requestedDetails ??
                'Secretary requires additional clarification on ${doc.title}.',
          );
        } else if (decision == DocumentReviewStatus.approved) {
          ssmService.simulateSecretaryApproval(matchingFiling.id);
        }
      }
    } catch (_) {}
  }

  // Upload / add a new document from client mobile app
  Future<ClientDocument> addClientDocument({
    required String title,
    required String category,
    required String fileSize,
    required String companyId,
    required String companyName,
    required String companySsmNo,
    required String uploadedBy,
    required String uploadedByRole,
    String? notes,
    String? linkedFilingRef,
    String? folder,
  }) => uploadClientDocument(
    title: title,
    category: category,
    fileSize: fileSize,
    companyId: companyId,
    companyName: companyName,
    companySsmNo: companySsmNo,
    uploadedBy: uploadedBy,
    uploadedByRole: uploadedByRole,
    notes: notes,
    linkedFilingRef: linkedFilingRef,
    folder: folder,
  );

  // Upload a new document from client mobile app
  Future<ClientDocument> uploadClientDocument({
    required String title,
    required String category,
    required String fileSize,
    required String companyId,
    required String companyName,
    required String companySsmNo,
    required String uploadedBy,
    required String uploadedByRole,
    String? notes,
    String? linkedFilingRef,
    String? folder,
  }) async {
    final newId =
        'DOC-2026-${(_documents.length + 1).toString().padLeft(3, '0')}';
    final now = DateTime.now();
    final nowStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final newDoc = ClientDocument(
      id: newId,
      title: title,
      originalName: title,
      category: category,
      fileSize: fileSize,
      fileType: 'application/pdf',
      companyId: companyId,
      companyName: companyName,
      companySsmNo: companySsmNo,
      assignedFirmId: 'firm-01',
      assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
      assignedSecretary: _activeSecretary,
      uploadedBy: uploadedBy,
      uploadedByRole: uploadedByRole,
      uploadedAt: nowStr,
      storageLocation: 'TM Cloud',
      storageUrl: 'tmcloud://alpha-dc1/vault/$companyId/$title',
      sha256Hash:
          '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}abcdef1234567890',
      status: DocumentReviewStatus.pendingReview,
      linkedFilingRef:
          linkedFilingRef ??
          'SSM/GEN/2026/${DateTime.now().millisecondsSinceEpoch % 10000}',
      submissionNotes:
          notes ?? 'Uploaded via MySect Mobile App for Secretary review.',
      auditTrail: [
        DocumentAuditItem(
          timestamp: nowStr,
          action: 'FILE_UPLOADED',
          actor: '$uploadedBy ($uploadedByRole)',
          details:
              'Uploaded from MySect Mobile App to TM Cloud encrypted storage.',
        ),
      ],
      folder: folder ?? 'Unsorted',
    );

    _documents.insert(0, newDoc);
    notifyListeners();

    // Call backend API if possible
    final candidateUrls = [
      'http://127.0.0.1:5173/api/documents',
      'http://localhost:5173/api/documents',
      'http://10.0.2.2:5173/api/documents',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(newDoc.toJson()),
            )
            .timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 201) {
          break;
        }
      } catch (_) {}
    }

    return newDoc;
  }
}
