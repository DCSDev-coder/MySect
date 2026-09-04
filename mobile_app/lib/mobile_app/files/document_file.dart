import 'package:flutter/material.dart';

class DocumentFile {
  final String title;
  final String subtitle;
  final String badgeText;
  int requiredActions;
  List<String> uploadedFiles;
  bool isExpanded;

  DocumentFile({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.requiredActions,
    List<String>? uploadedFiles,
    this.isExpanded = false,
  }) : uploadedFiles = uploadedFiles ?? [];

  String get progressText => '${uploadedFiles.length}/$requiredActions';

  Color get progressColor {
    if (uploadedFiles.length >= requiredActions) return Colors.green;
    if (uploadedFiles.isNotEmpty) return Colors.blue;
    return Colors.red;
  }
}
