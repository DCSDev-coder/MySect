import 'package:flutter/material.dart';

class ComplianceTask {
  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final String category;
  final String status;
  final String createdBy;
  final String? instructions;

  const ComplianceTask({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.subtitle,
    required this.dueDate,
    this.category = 'General Statutory',
    this.status = 'Pending',
    required this.createdBy,
    this.instructions,
  });

  String get timeRemainingText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (status.toLowerCase() == 'completed') return 'Completed';
    if (diff < 0) return 'Overdue by ${diff.abs()} days';
    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  Color get pillBgColor {
    if (status.toLowerCase() == 'completed') return const Color(0xFFE8F5E9);
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return const Color(0xFFFEE2E2);
    if (diff <= 7) return const Color(0xFFFFF7A3);
    return const Color(0xFFE3F2FD);
  }

  Color get pillTextColor {
    if (status.toLowerCase() == 'completed') return const Color(0xFF2E7D32);
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return const Color(0xFFDC2626);
    if (diff <= 7) return const Color(0xFFFF8A00);
    return const Color(0xFF1565C0);
  }

  factory ComplianceTask.fromJson(Map<String, dynamic> json) {
    return ComplianceTask(
      id: json['id'] ?? 'task-${DateTime.now().millisecondsSinceEpoch}',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'] ?? '',
      title: json['title'] ?? 'Compliance Dateline',
      subtitle: json['subtitle'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      category: json['category'] ?? 'General Statutory',
      status: json['status'] ?? 'Pending',
      createdBy: json['createdBy'] ?? 'Licensed Secretary',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'companyName': companyName,
        'title': title,
        'subtitle': subtitle,
        'dueDate': dueDate.toIso8601String().split('T').first,
        'category': category,
        'status': status,
        'createdBy': createdBy,
        if (instructions != null) 'instructions': instructions,
      };

  ComplianceTask copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? title,
    String? subtitle,
    DateTime? dueDate,
    String? category,
    String? status,
    String? createdBy,
    String? instructions,
  }) {
    return ComplianceTask(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      instructions: instructions ?? this.instructions,
    );
  }
}

