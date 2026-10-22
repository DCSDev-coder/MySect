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
        return 'Approval';
      case SsmFilingStatus.lodgedToSsm:
        return 'SSM Lodged';
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
  final List<SsmTimelineStep> timeline;

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
}
