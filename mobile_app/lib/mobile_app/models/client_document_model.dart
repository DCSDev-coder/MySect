import 'package:flutter/material.dart';

enum DocumentReviewStatus {
  pendingReview,
  approved,
  rejected,
  moreDetailsNeeded,
}

extension DocumentReviewStatusExtension on DocumentReviewStatus {
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

  String get shortLabel {
    switch (this) {
      case DocumentReviewStatus.pendingReview:
        return 'In Review';
      case DocumentReviewStatus.approved:
        return 'Approved';
      case DocumentReviewStatus.rejected:
        return 'Rejected';
      case DocumentReviewStatus.moreDetailsNeeded:
        return 'Action Needed';
    }
  }

  Color get color {
    switch (this) {
      case DocumentReviewStatus.pendingReview:
        return const Color(0xFFD97706); // Amber
      case DocumentReviewStatus.approved:
        return const Color(0xFF059669); // Emerald
      case DocumentReviewStatus.rejected:
        return const Color(0xFFDC2626); // Rose
      case DocumentReviewStatus.moreDetailsNeeded:
        return const Color(0xFF2563EB); // Blue
    }
  }

  Color get bgColor {
    switch (this) {
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

  IconData get icon {
    switch (this) {
      case DocumentReviewStatus.pendingReview:
        return Icons.hourglass_top_rounded;
      case DocumentReviewStatus.approved:
        return Icons.check_circle_rounded;
      case DocumentReviewStatus.rejected:
        return Icons.cancel_rounded;
      case DocumentReviewStatus.moreDetailsNeeded:
        return Icons.help_outline_rounded;
    }
  }

  static DocumentReviewStatus fromString(String? val) {
    if (val == null) return DocumentReviewStatus.pendingReview;
    final lower = val.toLowerCase();
    if (lower.contains('approved')) return DocumentReviewStatus.approved;
    if (lower.contains('reject')) return DocumentReviewStatus.rejected;
    if (lower.contains('detail') || lower.contains('clarif') || lower.contains('repli')) {
      return DocumentReviewStatus.moreDetailsNeeded;
    }
    return DocumentReviewStatus.pendingReview;
  }
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
      action: json['action'] ?? '',
      actor: json['actor'] ?? '',
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
      reviewedBy: json['reviewedBy'] ?? 'Lim Mei Ling (MIA)',
      reviewedAt: json['reviewedAt'] ?? '',
      decision: json['decision'] ?? 'Approved',
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
    'remarks': remarks,
    'rejectionReason': rejectionReason,
    'requestedDetails': requestedDetails,
    'internalNotes': internalNotes,
  };
}

class ClientDocument {
  final String id;
  String title;
  final String originalName;
  final String category;
  String fileSize;
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
  String? folder; // 'Accounting', 'Corporate', 'Personal', 'Other', or 'Unsorted'

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
    required this.linkedFilingRef,
    required this.submissionNotes,
    this.reviewDetails,
    required this.auditTrail,
    this.folder,
  });

  String get effectiveFolder {
    if (folder != null && folder!.isNotEmpty) return folder!;
    final cat = category.toLowerCase();
    final t = title.toLowerCase();
    if (cat.contains('account') ||
        cat.contains('financial') ||
        cat.contains('balance') ||
        cat.contains('tax') ||
        cat.contains('audit') ||
        cat.contains('invoice') ||
        t.contains('account') ||
        t.contains('financial') ||
        t.contains('balance') ||
        t.contains('statement') ||
        t.contains('invoice') ||
        t.contains('bank_in')) {
      return 'Accounting';
    }
    if (cat.contains('corporate') ||
        cat.contains('section 68') ||
        cat.contains('section 58') ||
        cat.contains('section 46') ||
        cat.contains('section 78') ||
        cat.contains('resolution') ||
        cat.contains('allotment') ||
        cat.contains('ssm') ||
        cat.contains('register') ||
        cat.contains('return') ||
        t.contains('resolution') ||
        t.contains('return') ||
        t.contains('section') ||
        t.contains('register') ||
        t.contains('annual return')) {
      return 'Corporate';
    }
    if (cat.contains('kyc') ||
        cat.contains('identity') ||
        cat.contains('passport') ||
        cat.contains('nric') ||
        cat.contains('director') ||
        cat.contains('personal') ||
        t.contains('passport') ||
        t.contains('resume') ||
        t.contains('profile') ||
        t.contains('nric') ||
        t.contains('declaration')) {
      return 'Personal';
    }
    return 'Other';
  }

  factory ClientDocument.fromJson(Map<String, dynamic> json) {
    return ClientDocument(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      originalName: json['originalName'] ?? json['title'] ?? '',
      category: json['category'] ?? 'General Document',
      fileSize: json['fileSize'] ?? '1.0 MB',
      fileType: json['fileType'] ?? 'application/pdf',
      companyId: json['companyId'] ?? 'comp-01',
      companyName: json['companyName'] ?? '',
      companySsmNo: json['companySsmNo'] ?? '',
      assignedFirmId: json['assignedFirmId'] ?? 'firm-01',
      assignedFirmName: json['assignedFirmName'] ?? 'SectPro Corporate Services Sdn Bhd',
      assignedSecretary: json['assignedSecretary'] ?? 'Lim Mei Ling (MIA CA 48192)',
      uploadedBy: json['uploadedBy'] ?? 'Client',
      uploadedByRole: json['uploadedByRole'] ?? 'Managing Director (Client)',
      uploadedAt: json['uploadedAt'] ?? '',
      storageLocation: () {
        final loc = json['storageLocation']?.toString() ?? 'TM Cloud';
        if (loc.contains('TM One Cloud Alpha') || loc.contains('Cyberjaya') || loc.contains('DC1')) {
          return 'TM Cloud';
        }
        return loc;
      }(),
      storageUrl: json['storageUrl'] ?? '',
      sha256Hash: json['sha256Hash'] ?? '',
      status: DocumentReviewStatusExtension.fromString(json['status']),
      linkedFilingRef: json['linkedFilingRef'] ?? '',
      submissionNotes: json['submissionNotes'] ?? '',
      reviewDetails: json['reviewDetails'] != null
          ? DocumentReviewDetails.fromJson(Map<String, dynamic>.from(json['reviewDetails']))
          : null,
      auditTrail: (json['auditTrail'] as List<dynamic>?)
              ?.map((item) => DocumentAuditItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
      folder: json['folder'],
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
    'reviewDetails': reviewDetails?.toJson(),
    'auditTrail': auditTrail.map((a) => a.toJson()).toList(),
    'folder': folder,
  };
}
