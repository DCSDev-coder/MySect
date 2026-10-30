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
        return 'Waiting for Your Approval';
      case SsmFilingStatus.lodgedToSsm:
        return 'Submitted to SSM (Processing)';
      case SsmFilingStatus.completed:
        return 'Completed & Approved by SSM';
    }
  }

  String get shortLabel {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return 'In Review';
      case SsmFilingStatus.secretaryReplied:
        return 'Action Needed';
      case SsmFilingStatus.waitingClientApproval:
        return 'Approval';
      case SsmFilingStatus.lodgedToSsm:
        return 'Submitted to SSM';
      case SsmFilingStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return const Color(0xFFD97706); // Amber
      case SsmFilingStatus.secretaryReplied:
        return const Color(0xFFDC2626); // Red/Action
      case SsmFilingStatus.waitingClientApproval:
        return const Color(0xFF2563EB); // Blue
      case SsmFilingStatus.lodgedToSsm:
        return const Color(0xFF7C3AED); // Purple
      case SsmFilingStatus.completed:
        return const Color(0xFF059669); // Emerald
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

  IconData get icon {
    switch (this) {
      case SsmFilingStatus.waitingSecretaryReview:
        return Icons.hourglass_top_rounded;
      case SsmFilingStatus.secretaryReplied:
        return Icons.mark_chat_unread_rounded;
      case SsmFilingStatus.waitingClientApproval:
        return Icons.draw_rounded;
      case SsmFilingStatus.lodgedToSsm:
        return Icons.account_balance_rounded;
      case SsmFilingStatus.completed:
        return Icons.check_circle_rounded;
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

class SsmMessage {
  final String id;
  final String senderName;
  final String senderRole;
  final String text;
  final String time;
  final bool isFromSecretary;
  final List<String> attachments;

  const SsmMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.time,
    required this.isFromSecretary,
    this.attachments = const [],
  });

  factory SsmMessage.fromJson(Map<String, dynamic> json) {
    return SsmMessage(
      id: json['id'] ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      text: json['text'] ?? '',
      time: json['time'] ?? '',
      isFromSecretary: json['isFromSecretary'] ?? false,
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'time': time,
        'isFromSecretary': isFromSecretary,
        'attachments': attachments,
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
  final List<SsmMessage> messages;
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
    required this.messages,
    required this.timeline,
  });

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
    final rawMessages = json['messages'] as List<dynamic>? ?? [];

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
      messages: rawMessages.map((e) => SsmMessage.fromJson(e as Map<String, dynamic>)).toList(),
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
        'messages': messages.map((e) => e.toJson()).toList(),
        'timeline': timeline.map((e) => e.toJson()).toList(),
      };
}
