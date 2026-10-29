import 'package:flutter/material.dart';

enum SsmFilingStatus {
  waitingSecretaryReview,
  secretaryReplied,
  waitingClientApproval,
  lodgedToSsm,
  completed,
}

extension SsmFilingStatusExtension on SsmFilingStatus {
  String get label {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return 'Waiting for Secretary Review';
      case SsmFilingStatus.secretaryReplied:
        return 'Secretary Replied (Action Needed)';
      case SsmFilingStatus.waitingClientApproval:
        return 'Waiting for Client Approval';
      case SsmFilingStatus.lodgedToSsm:
        return 'Lodged to SSM (Processing)';
      case SsmFilingStatus.completed:
        return 'Completed & SSM Receipt Issued';
    }
  }

  String get shortLabel {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return 'In Review';
      case SsmFilingStatus.secretaryReplied:
        return 'Action Needed';
      case SsmFilingStatus.waitingClientApproval:
        return 'Preparation';
      case SsmFilingStatus.lodgedToSsm:
        return 'SSM Lodged';
      case SsmFilingStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return const Color(0xFFD97706);
      case SsmFilingStatus.secretaryReplied:
        return const Color(0xFFDC2626);
      case SsmFilingStatus.waitingClientApproval:
        return const Color(0xFF2563EB);
      case SsmFilingStatus.lodgedToSsm:
        return const Color(0xFF7C3AED);
      case SsmFilingStatus.completed:
        return const Color(0xFF059669);
    }
  }

  Color get bgColor {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return const Color(0xFFFEF3C7);
      case SsmFilingStatus.secretaryReplied:
        return const Color(0xFFFEE2E2);
      case SsmFilingStatus.waitingClientApproval:
        return const Color(0xFFEFF6FF);
      case SsmFilingStatus.lodgedToSsm:
        return const Color(0xFFF5F3FF);
      case SsmFilingStatus.completed:
        return const Color(0xFFECFDF5);
    }
  }
}

class SsmTimelineStep {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const SsmTimelineStep({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  SsmTimelineStep copyWith({
    String? title,
    String? description,
    String? timestamp,
    bool? isCompleted,
    bool? isCurrent,
  }) {
    return SsmTimelineStep(
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  factory SsmTimelineStep.fromJson(Map<String, dynamic> json) {
    return SsmTimelineStep(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'timestamp': timestamp,
        'isCompleted': isCompleted,
        'isCurrent': isCurrent,
      };
}

class SsmFiling {
  final String id;
  final String referenceNo;
  final String companyId;
  final String companyName;
  final String companySsmNo;
  final String assignedSecretary;
  final String assignedFirmName;
  final String filingType;
  final String title;
  final String description;
  final DateTime submittedDate;
  final String deadline;
  SsmFilingStatus status;
  final List<String> attachedFiles;
  List<SsmTimelineStep> timeline;

  SsmFiling({
    required this.id,
    required this.referenceNo,
    required this.companyId,
    required this.companyName,
    required this.companySsmNo,
    required this.assignedSecretary,
    required this.assignedFirmName,
    required this.filingType,
    required this.title,
    required this.description,
    required this.submittedDate,
    required this.deadline,
    required this.status,
    required this.attachedFiles,
    required this.timeline,
  });

  int get currentStepIndex {
    for (int i = timeline.length - 1; i >= 0; i--) {
      if (timeline[i].isCompleted || timeline[i].isCurrent) {
        return i;
      }
    }
    return 0;
  }

  factory SsmFiling.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    SsmFilingStatus parsedStatus = SsmFilingStatus.waitingSecretaryReview;
    if (statusStr.contains('reply') || statusStr.contains('action')) {
      parsedStatus = SsmFilingStatus.secretaryReplied;
    } else if (statusStr.contains('approval') || statusStr.contains('prep')) {
      parsedStatus = SsmFilingStatus.waitingClientApproval;
    } else if (statusStr.contains('lodged') || statusStr.contains('ssm')) {
      parsedStatus = SsmFilingStatus.lodgedToSsm;
    } else if (statusStr.contains('complete')) {
      parsedStatus = SsmFilingStatus.completed;
    }

    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];

    return SsmFiling(
      id: json['id'] ?? 'SSM-01',
      referenceNo: json['referenceNo'] ?? 'SSM/S68/2026/04812',
      companyId: json['companyId'] ?? 'comp-01',
      companyName: json['companyName'] ?? 'Data Center Specialists Sdn Bhd (M)',
      companySsmNo: json['companySsmNo'] ?? '202101039281 (1429581-X)',
      assignedSecretary: json['assignedSecretary'] ?? 'Lim Mei Ling (MIA)',
      assignedFirmName: json['assignedFirmName'] ?? 'SectPro Corporate Services Sdn Bhd',
      filingType: json['filingType'] ?? 'Section 68 Annual Return',
      title: json['title'] ?? 'Statutory Filing',
      description: json['description'] ?? '',
      submittedDate: json['submittedDate'] != null
          ? DateTime.tryParse(json['submittedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deadline: json['deadline'] ?? '2026-11-14',
      status: parsedStatus,
      attachedFiles: (json['attachedFiles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timeline: rawTimeline.map((e) => SsmTimelineStep.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referenceNo': referenceNo,
        'companyId': companyId,
        'companyName': companyName,
        'companySsmNo': companySsmNo,
        'assignedSecretary': assignedSecretary,
        'assignedFirmName': assignedFirmName,
        'filingType': filingType,
        'title': title,
        'description': description,
        'submittedDate': submittedDate.toIso8601String(),
        'deadline': deadline,
        'status': status.name,
        'attachedFiles': attachedFiles,
        'timeline': timeline.map((e) => e.toJson()).toList(),
      };
}

