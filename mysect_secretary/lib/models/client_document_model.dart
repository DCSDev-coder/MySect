enum DocumentReviewStatus {
  pendingReview,
  approved,
  rejected,
  moreDetailsNeeded;

  String get label {
    switch (this) {
      case DocumentReviewStatus.pendingReview:
        return 'Pending Review';
      case DocumentReviewStatus.approved:
        return 'Approved';
      case DocumentReviewStatus.rejected:
        return 'Rejected';
      case DocumentReviewStatus.moreDetailsNeeded:
        return 'More Details Needed';
    }
  }

  static DocumentReviewStatus fromString(String val) {
    final lower = val.toLowerCase().replaceAll(' ', '_');
    if (lower.contains('approv')) return DocumentReviewStatus.approved;
    if (lower.contains('reject')) return DocumentReviewStatus.rejected;
    if (lower.contains('detail') || lower.contains('clarif') || lower.contains('more')) {
      return DocumentReviewStatus.moreDetailsNeeded;
    }
    return DocumentReviewStatus.pendingReview;
  }
}

class DocumentReviewDetails {
  final String reviewedBy;
  final String reviewedAt;
  final String decision;
  final String? remarks;
  final String? rejectionReason;
  final String? requestedDetails;
  final String? internalNotes;

  const DocumentReviewDetails({
    required this.reviewedBy,
    required this.reviewedAt,
    required this.decision,
    this.remarks,
    this.rejectionReason,
    this.requestedDetails,
    this.internalNotes,
  });

  factory DocumentReviewDetails.fromJson(Map<String, dynamic> json) {
    return DocumentReviewDetails(
      reviewedBy: json['reviewedBy'] ?? 'Licensed Company Secretary',
      reviewedAt: json['reviewedAt'] ?? '',
      decision: json['decision'] ?? 'Pending',
      remarks: json['remarks'],
      rejectionReason: json['rejectionReason'],
      requestedDetails: json['requestedDetails'],
      internalNotes: json['internalNotes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt,
        'decision': decision,
        if (remarks != null) 'remarks': remarks,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (requestedDetails != null) 'requestedDetails': requestedDetails,
        if (internalNotes != null) 'internalNotes': internalNotes,
      };
}

class DocumentAuditItem {
  final String timestamp;
  final String action;
  final String actor;
  final String details;

  const DocumentAuditItem({
    required this.timestamp,
    required this.action,
    required this.actor,
    required this.details,
  });

  factory DocumentAuditItem.fromJson(Map<String, dynamic> json) {
    return DocumentAuditItem(
      timestamp: json['timestamp'] ?? '',
      action: json['action'] ?? 'ACTION',
      actor: json['actor'] ?? 'System',
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'action': action,
        'actor': actor,
        'details': details,
      };
}

class ClientDocument {
  final String id;
  final String title;
  final String originalName;
  final String category;
  final String fileSize;
  final String fileType;
  final String companyId;
  final String companyName;
  final String companySsmNo;
  final String assignedFirmId;
  final String assignedFirmName;
  final String assignedSecretary;
  final String uploadedBy;
  final String uploadedByRole;
  final String uploadedAt;
  final String storageLocation;
  final String storageUrl;
  final String sha256Hash;
  DocumentReviewStatus status;
  final String linkedFilingRef;
  final String submissionNotes;
  DocumentReviewDetails? reviewDetails;
  final List<DocumentAuditItem> auditTrail;
  bool isSigned;
  String? signedBy;
  String? signedAt;
  String? signatureSealId;

  ClientDocument({
    required this.id,
    required this.title,
    required this.originalName,
    required this.category,
    required this.fileSize,
    required this.fileType,
    required this.companyId,
    required this.companyName,
    required this.companySsmNo,
    required this.assignedFirmId,
    required this.assignedFirmName,
    required this.assignedSecretary,
    required this.uploadedBy,
    required this.uploadedByRole,
    required this.uploadedAt,
    required this.storageLocation,
    required this.storageUrl,
    required this.sha256Hash,
    required this.status,
    this.linkedFilingRef = '',
    this.submissionNotes = '',
    this.reviewDetails,
    List<DocumentAuditItem>? auditTrail,
    this.isSigned = false,
    this.signedBy,
    this.signedAt,
    this.signatureSealId,
  }) : auditTrail = auditTrail ?? [];

  factory ClientDocument.fromJson(Map<String, dynamic> json) {
    return ClientDocument(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled Document',
      originalName: json['originalName'] ?? json['name'] ?? 'document.pdf',
      category: json['category'] ?? 'Statutory Document',
      fileSize: json['fileSize'] ?? json['size'] ?? '1.2 MB',
      fileType: json['fileType'] ?? 'application/pdf',
      companyId: json['companyId'] ?? 'comp-01',
      companyName: json['companyName'] ?? 'Data Center Specialists Sdn Bhd (M)',
      companySsmNo: json['companySsmNo'] ?? '202101039281 (1429581-X)',
      assignedFirmId: json['assignedFirmId'] ?? 'firm-01',
      assignedFirmName: json['assignedFirmName'] ?? 'SectPro Corporate Services Sdn Bhd',
      assignedSecretary: json['assignedSecretary'] ?? 'Lim Mei Ling (MIA CA 48192)',
      uploadedBy: json['uploadedBy'] ?? 'Client Representative',
      uploadedByRole: json['uploadedByRole'] ?? 'Managing Director (Client)',
      uploadedAt: json['uploadedAt'] ?? '',
      storageLocation: () {
        final loc = json['storageLocation']?.toString() ?? 'TM Cloud';
        if (loc.contains('TM One Cloud Alpha') || loc.contains('Cyberjaya') || loc.contains('DC1')) {
          return 'TM Cloud';
        }
        return loc;
      }(),
      storageUrl: json['storageUrl'] ?? 'tmcloud://alpha-dc1/vault/default.pdf',
      sha256Hash: json['sha256Hash'] ?? 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      status: DocumentReviewStatus.fromString(json['status'] ?? 'pending'),
      linkedFilingRef: json['linkedFilingRef'] ?? '',
      submissionNotes: json['submissionNotes'] ?? '',
      reviewDetails: json['reviewDetails'] != null
          ? DocumentReviewDetails.fromJson(json['reviewDetails'])
          : null,
      auditTrail: (json['auditTrail'] as List<dynamic>?)
              ?.map((item) => DocumentAuditItem.fromJson(item))
              .toList() ??
          [],
      isSigned: json['isSigned'] ?? (json['status'] == 'Approved' || json['status'] == 'approved'),
      signedBy: json['signedBy'],
      signedAt: json['signedAt'],
      signatureSealId: json['signatureSealId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'originalName': originalName,
        'category': category,
        'fileSize': fileSize,
        'fileType': fileType,
        'companyId': companyId,
        'companyName': companyName,
        'companySsmNo': companySsmNo,
        'assignedFirmId': assignedFirmId,
        'assignedFirmName': assignedFirmName,
        'assignedSecretary': assignedSecretary,
        'uploadedBy': uploadedBy,
        'uploadedByRole': uploadedByRole,
        'uploadedAt': uploadedAt,
        'storageLocation': storageLocation,
        'storageUrl': storageUrl,
        'sha256Hash': sha256Hash,
        'status': status.label,
        'linkedFilingRef': linkedFilingRef,
        'submissionNotes': submissionNotes,
        'isSigned': isSigned,
        if (signedBy != null) 'signedBy': signedBy,
        if (signedAt != null) 'signedAt': signedAt,
        if (signatureSealId != null) 'signatureSealId': signatureSealId,
        if (reviewDetails != null) 'reviewDetails': reviewDetails!.toJson(),
        'auditTrail': auditTrail.map((a) => a.toJson()).toList(),
      };
}
