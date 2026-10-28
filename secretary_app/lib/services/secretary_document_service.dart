import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/client_document_model.dart';
import '../models/secretary_profile_model.dart';
import '../models/secretary_subscription_model.dart';

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
  SecretaryProfile _profile = SecretaryProfile.defaultProfile();

  String _currentPlanId = 'growth';
  bool _isAnnualBilling = true;

  List<ClientDocument> get documents => List.unmodifiable(_documents);
  bool get isSyncing => _isSyncing;
  bool get isConnectedToBackend => _isConnectedToBackend;
  SecretaryProfile get profile => _profile;

  List<SubscriptionTier> get subscriptionTiers => SubscriptionTier.defaultTiers();
  SubscriptionTier get currentPlan => SubscriptionTier.defaultTiers().firstWhere(
        (t) => t.id == _currentPlanId,
        orElse: () => SubscriptionTier.defaultTiers()[1],
      );
  int get companyLimit => currentPlan.companyLimit;
  int get managedCompaniesCount => clientCompanies.length;
  bool get isAnnualBilling => _isAnnualBilling;

  void upgradePlan(String planId) {
    if (_currentPlanId != planId) {
      _currentPlanId = planId;
      notifyListeners();
    }
  }

  void setAnnualBilling(bool isAnnual) {
    if (_isAnnualBilling != isAnnual) {
      _isAnnualBilling = isAnnual;
      notifyListeners();
    }
  }

  void setActiveSecretary(String name) {
    if (name.contains('Sarah')) {
      _profile = const SecretaryProfile(
        id: 'SEC-02',
        name: 'Sarah binti Ahmad',
        title: 'Chartered Corporate Secretary',
        professionalBody: 'MAICSA (Fellow)',
        licenseNo: 'MAICSA 6028192 / LS 0008412',
        firmName: 'SectPro Corporate Services Sdn Bhd',
        firmRegistrationNo: 'SSM/COSEC/2020/00481',
        email: 'sarah.ahmad@sectpro.com.my',
        phone: '+60 3-2240 8899',
        officeAddress:
            'Level 18, Menara TM, Jalan Pantai Baharu, 50672 Kuala Lumpur',
        totalAssignedCompanies: 18,
        avatarUrl: '',
      );
    } else {
      _profile = SecretaryProfile.defaultProfile();
    }
    notifyListeners();
  }

  int get totalCount => _documents.length;
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

  List<String> get clientCompanies {
    final companies = <String>{
      'Data Center Specialists Sdn Bhd (M)',
      'C2 Coffee + Candle',
      '5Luxe Scents Co.',
      'Test Enterprise',
    };
    for (final doc in _documents) {
      companies.add(doc.companyName);
    }
    return companies.toList();
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
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-01/DCS_Management_Accounts_FY2026.pdf',
        sha256Hash:
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/S68/2026/04812',
        submissionNotes: 'Uploaded unaudited management accounts and draft statutory statements for Annual Return lodgement.',
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
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
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
          reviewedAt: '2026-10-19 11:30',
          decision: 'More Details Needed',
          requestedDetails: 'Please provide statutory Form 48A (Statutory Declaration before appointment) and certified NRIC copy (front & back) pursuant to Section 201 of Companies Act 2016.',
          internalNotes:
              'Resume verified. Missing formal consent to act as director.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-18 10:00:45',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Director)',
            details: 'Uploaded via MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-10-19 11:30:20',
            action: 'DETAILS_REQUESTED',
            actor: 'Lim Mei Ling (MIA CA 48192)',
            details: 'Requested Form 48A and certified NRIC copy.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-003',
        title: 'Signed_Board_Resolution_S46.pdf',
        originalName: 'Signed_Board_Resolution_S46.pdf',
        category: 'Registered Address (Section 46)',
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
        uploadedAt: '2026-10-12 16:45',
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-02/Signed_Board_Resolution_S46.pdf',
        sha256Hash:
            '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b',
        status: DocumentReviewStatus.approved,
        linkedFilingRef: 'SSM/S46/2026/00731',
        submissionNotes: 'Board resolution approving change of registered office address to Menara Binjai.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Azman bin Ibrahim (MAICSA 7019284)',
          reviewedAt: '2026-10-14 10:30',
          decision: 'Approved',
          remarks: 'Board resolution is duly signed by quorum of directors. Tenancy proof verified. Cleared for MBRS submission.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-12 16:45:10',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Director)',
            details: 'Uploaded via MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-10-14 10:30:15',
            action: 'FILE_APPROVED',
            actor: 'Azman bin Ibrahim (MAICSA 7019284)',
            details: 'Verified against Section 46 requirements. Approved for lodgement.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-004',
        title: 'Form_Section_78_Return_of_Allotment.pdf',
        originalName: 'Form_Section_78_Return_of_Allotment.pdf',
        category: 'Share Allotment (Section 78)',
        fileSize: '890 KB',
        fileType: 'application/pdf',
        companyId: 'comp-03',
        companyName: '5Luxe Scents Co.',
        companySsmNo: '202201082918 (1482910-P)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Eidza Binti Jumanis',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-09-20 11:00',
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-03/Form_Section_78_Return_of_Allotment.pdf',
        sha256Hash:
            '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b',
        status: DocumentReviewStatus.approved,
        linkedFilingRef: 'SSM/S78/2026/00194',
        submissionNotes: 'Section 78 Return of Allotment for newly issued 30,000 ordinary shares.',
        isSigned: true,
        signedBy: 'Lim Mei Ling (MIA CA 48192)',
        signedAt: '2026-09-22 14:15',
        signatureSealId: 'MYSECT-SIG-2026-LML-00194',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Lim Mei Ling (MIA CA 48192)',
          reviewedAt: '2026-09-22 14:15',
          decision: 'Approved',
          remarks: 'Bank confirmation of capital receipt verified. Form 78 ready for submission.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-09-20 11:00:00',
            action: 'FILE_UPLOADED',
            actor: 'Eidza Binti Jumanis (Director)',
            details: 'Uploaded via MySect Mobile App.',
          ),
          const DocumentAuditItem(
            timestamp: '2026-09-22 14:15:10',
            action: 'FILE_APPROVED',
            actor: 'Lim Mei Ling (MIA CA 48192)',
            details: 'Payment proof authenticated. Approved for lodgement.',
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
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Eidza Binti Jumanis',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-15 09:30',
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl:
            'tmcloud://alpha-dc1/vault/comp-03/New_Investor_Passport_Scan.pdf',
        sha256Hash:
            '8b7a6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b',
        status: DocumentReviewStatus.rejected,
        linkedFilingRef: 'SSM/S78/2026/00194',
        submissionNotes:
            'Foreign investor passport copy for member register entry.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'Lim Mei Ling (MIA CA 48192)',
          reviewedAt: '2026-10-16 11:00',
          decision: 'Rejected',
          rejectionReason: 'Passport scan is blurry and expires in less than 3 months. SSM regulations require valid passport with minimum 6 months validity.',
          internalNotes: 'Informed director to request renewed passport copy.',
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
            actor: 'Lim Mei Ling (MIA CA 48192)',
            details: 'Rejected due to expiry and poor scan resolution.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-007',
        title: 'Statutory_Declaration_Section_201.pdf',
        originalName: 'Statutory_Declaration_Section_201.pdf',
        category: 'Director Consent (Section 201)',
        fileSize: '1.5 MB',
        fileType: 'application/pdf',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA CA 48192)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        uploadedAt: '2026-10-22 15:40',
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-01/Statutory_Declaration_Section_201.pdf',
        sha256Hash:
            '3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d',
        status: DocumentReviewStatus.pendingReview,
        linkedFilingRef: 'SSM/S58/2026/00388',
        submissionNotes: 'Declaration by person before appointment as director under Section 201.',
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-22 15:40:22',
            action: 'FILE_UPLOADED',
            actor: 'Adam Bin Hamzah (Managing Director)',
            details: 'Uploaded via MySect Mobile App.',
          ),
        ],
      ),
      ClientDocument(
        id: 'DOC-2026-008',
        title: 'Notice_of_Access_Restriction.pdf',
        originalName: 'Notice_of_Access_Restriction.pdf',
        category: 'Account Verification',
        fileSize: '420 KB',
        fileType: 'application/pdf',
        companyId: 'comp-locked',
        companyName: 'Test Enterprise',
        companySsmNo: '202401999999 (999999-T)',
        assignedFirmId: 'none',
        assignedFirmName: 'Unassigned',
        assignedSecretary: 'None',
        uploadedBy: 'MySect Security System',
        uploadedByRole: 'Platform Administrator',
        uploadedAt: '2026-10-24 09:00',
        storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
        storageUrl: 'tmcloud://alpha-dc1/vault/comp-locked/Notice_of_Access_Restriction.pdf',
        sha256Hash: '7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c',
        status: DocumentReviewStatus.rejected,
        linkedFilingRef: 'SYS/LOCK/2026/0001',
        submissionNotes: 'Company account restricted pending verification of authorized company secretary custody.',
        reviewDetails: const DocumentReviewDetails(
          reviewedBy: 'MySect Platform Moderator',
          reviewedAt: '2026-10-24 09:30',
          decision: 'Rejected',
          rejectionReason: 'Account locked. Unassigned to verified secretary firm.',
        ),
        auditTrail: [
          const DocumentAuditItem(
            timestamp: '2026-10-24 09:00:00',
            action: 'ACCESS_RESTRICTED',
            actor: 'MySect Platform Moderator',
            details: 'Placed company under locked status pending firm assignment.',
          ),
        ],
      ),
    ];
  }

  /// Synchronize documents from backend API if available
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
            final fetched = data
                .map((json) => ClientDocument.fromJson(json))
                .toList();
            _documents = fetched;
            _isConnectedToBackend = true;
            _isSyncing = false;
            notifyListeners();
            return;
          }
        }
      } catch (_) {
        // Continue to fallback
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
    bool isSigned = false,
    String? signatureSealId,
  }) async {
    final docIndex = _documents.indexWhere((d) => d.id == docId);
    if (docIndex == -1) return;

    final doc = _documents[docIndex];
    final reviewer =
        '${_profile.name} (${_profile.licenseNo.split(' /').first})';
    final now = DateTime.now();
    final nowStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final shouldMarkSigned =
        isSigned || decision == DocumentReviewStatus.approved;
    final sealId =
        signatureSealId ??
        (shouldMarkSigned
            ? 'MYSECT-SIG-${now.year}-${_profile.id}-${now.millisecondsSinceEpoch.toString().substring(7)}'
            : null);

    doc.status = decision;
    doc.isSigned = shouldMarkSigned;
    if (shouldMarkSigned) {
      doc.signedBy = reviewer;
      doc.signedAt = nowStr;
      doc.signatureSealId = sealId;
    }

    doc.reviewDetails = DocumentReviewDetails(
      reviewedBy: reviewer,
      reviewedAt: nowStr,
      decision: decision.label,
      remarks: decision == DocumentReviewStatus.approved
          ? (remarks ??
                'Approved in accordance with Companies Act 2016 statutory filing rules.')
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
    String auditDetail = 'Secretary checked file: ${decision.label}';

    if (decision == DocumentReviewStatus.approved) {
      auditAction = 'FILE_APPROVED';
      auditDetail = 'Approved: ${remarks ?? "Statutory requirements verified"}';
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
        await http
            .patch(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'status': decision.label,
                'decision': decision.label,
                'reviewedBy': reviewer,
                'reviewedAt': nowStr,
                'remarks': remarks,
                'rejectionReason': rejectionReason,
                'requestedDetails': requestedDetails,
                'internalNotes': internalNotes,
              }),
            )
            .timeout(const Duration(milliseconds: 1500));
        break;
      } catch (_) {}
    }
  }

  /// SECRETARY ACTION: Sign and endorse a statutory document
  Future<void> signAndApproveDocument(
    String docId, {
    String? remarks,
    String? signatureType,
  }) async {
    await reviewDocument(
      docId,
      DocumentReviewStatus.approved,
      remarks:
          remarks ??
          'Digitally signed and endorsed under Practising License ${_profile.licenseNo}.',
      isSigned: true,
      signatureSealId: 'MYSECT-SEAL-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Add / upload a new test document
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
      assignedFirmName: _profile.firmName,
      assignedSecretary:
          '${_profile.name} (${_profile.licenseNo.split(' /').first})',
      uploadedBy: uploadedBy,
      uploadedByRole: uploadedByRole,
      uploadedAt: nowStr,
      storageLocation: 'TM One Cloud Alpha (DC1-Cyberjaya)',
      storageUrl: 'tmcloud://alpha-dc1/vault/$companyId/$title',
      sha256Hash:
          '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}abcdef1234567890',
      status: DocumentReviewStatus.pendingReview,
      linkedFilingRef:
          linkedFilingRef ??
          'SSM/GEN/2026/${DateTime.now().millisecondsSinceEpoch % 10000}',
      submissionNotes: notes ?? 'Uploaded by client for Secretary review.',
      auditTrail: [
        DocumentAuditItem(
          timestamp: nowStr,
          action: 'FILE_UPLOADED',
          actor: '$uploadedBy ($uploadedByRole)',
          details:
              'Uploaded from MySect Client App to TM Cloud encrypted storage.',
        ),
      ],
    );

    _documents.insert(0, newDoc);
    notifyListeners();
    return newDoc;
  }
}
