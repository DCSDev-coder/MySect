import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/compliance_task_model.dart';

class ComplianceService extends ChangeNotifier {
  static final ComplianceService _instance = ComplianceService._internal();
  static ComplianceService get instance => _instance;

  ComplianceService._internal() {
    _initDefaultTasks();
    syncFromBackend();
  }

  List<ComplianceTask> _tasks = [];
  bool _isSyncing = false;

  List<ComplianceTask> get tasks => List.unmodifiable(_tasks);
  bool get isSyncing => _isSyncing;

  List<ComplianceTask> getTasksForDay(DateTime day, String? companyName) {
    return _tasks.where((t) {
      final isSameDate = t.dueDate.year == day.year &&
          t.dueDate.month == day.month &&
          t.dueDate.day == day.day;

      if (companyName != null && companyName.isNotEmpty && companyName != 'All') {
        final matchesComp =
            t.companyName.toLowerCase().trim() == companyName.toLowerCase().trim();
        return isSameDate && matchesComp;
      }

      return isSameDate;
    }).toList();
  }

  bool hasEventsOnDay(DateTime day, String? companyName) {
    return getTasksForDay(day, companyName).isNotEmpty;
  }

  void _initDefaultTasks() {
    final now = DateTime.now();
    _tasks = [
      ComplianceTask(
        id: 'task-sec-01',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        title: 'Section 68 Annual Return',
        subtitle: 'Submit to SSM with financial reports',
        dueDate: DateTime(now.year, now.month, 14),
        category: 'Section 68 Annual Return',
        status: 'Pending',
        createdBy: 'Lim Mei Ling (MIA CA 48192)',
        instructions:
            'Upload certified true copies of audited accounts and board declaration for Section 68 submission.',
      ),
      ComplianceTask(
        id: 'task-sec-02',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        title: 'Tax Estimate (CP204)',
        subtitle: 'LHDN company tax schedule submission',
        dueDate: DateTime(now.year, now.month, 28),
        category: 'Tax Filing (CP204)',
        status: 'Pending',
        createdBy: 'Lim Mei Ling (MIA CA 48192)',
        instructions: 'Submit revised CP204 tax estimate to LHDN Malaysia.',
      ),
      ComplianceTask(
        id: 'task-sec-03',
        companyId: 'comp-03',
        companyName: '5Luxe Scents Co.',
        title: 'Financial Statements Submission',
        subtitle: 'Annual Financial Statements to SSM',
        dueDate: DateTime(now.year, now.month, 20),
        category: 'Financial Statements',
        status: 'Pending',
        createdBy: 'Sarah binti Ahmad (MAICSA 6028192)',
        instructions: 'Prepare directors report and circulation to shareholders.',
      ),
      ComplianceTask(
        id: 'task-sec-04',
        companyId: 'comp-02',
        companyName: 'C2 Coffee + Candle',
        title: 'Section 46 Notice of Office Address',
        subtitle: 'Submission of change of registered address',
        dueDate: DateTime(now.year, now.month, 10),
        category: 'General Submission',
        status: 'Completed',
        createdBy: 'Azman bin Ibrahim (MAICSA 7019284)',
        instructions: 'Submitted to SSM successfully.',
      ),
    ];
  }

  Future<void> syncFromBackend() async {
    _isSyncing = true;
    notifyListeners();

    final candidateUrls = [
      'http://127.0.0.1:5173/api/compliance-tasks',
      'http://localhost:5173/api/compliance-tasks',
      'http://10.0.2.2:5173/api/compliance-tasks',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http.get(uri).timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            _tasks = data.map((json) => ComplianceTask.fromJson(json)).toList();
            _isSyncing = false;
            notifyListeners();
            return;
          }
        }
      } catch (_) {}
    }

    _isSyncing = false;
    notifyListeners();
  }
}

