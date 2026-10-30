import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/compliance_task_model.dart';
import 'secretary_document_service.dart';

class SecretaryComplianceService extends ChangeNotifier {
  static final SecretaryComplianceService _instance =
      SecretaryComplianceService._internal();
  static SecretaryComplianceService get instance => _instance;

  SecretaryComplianceService._internal() {
    _initDefaultTasks();
    syncFromBackend();
  }

  List<ComplianceTask> _tasks = [];
  bool _isSyncing = false;

  List<ComplianceTask> get tasks => List.unmodifiable(_tasks);
  bool get isSyncing => _isSyncing;

  List<ComplianceTask> getTasksForCompany(String companyName) {
    return _tasks
        .where((t) =>
            t.companyName.toLowerCase().trim() ==
            companyName.toLowerCase().trim())
        .toList();
  }

  void _initDefaultTasks() {
    final now = DateTime.now();
    _tasks = [
      ComplianceTask(
        id: 'task-sec-01',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        title: 'Section 68 Annual Return Lodgement',
        subtitle: 'Filing to SSM with audited financial reports',
        dueDate: DateTime(now.year, now.month, 14),
        category: 'Section 68 Annual Return',
        status: 'Pending',
        createdBy: 'Lim Mei Ling (MIA CA 48192)',
        instructions:
            'Upload certified true copies of audited accounts and board declaration for Section 68 lodgement.',
      ),
      ComplianceTask(
        id: 'task-sec-02',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        title: 'Statutory Tax Estimate (CP204)',
        subtitle: 'LHDN statutory company tax schedule lodgement',
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
        title: 'Statutory Financial Statements Submission',
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
        subtitle: 'Lodgement of change of registered address',
        dueDate: DateTime(now.year, now.month, 10),
        category: 'General Statutory',
        status: 'Completed',
        createdBy: 'Azman bin Ibrahim (MAICSA 7019284)',
        instructions: 'Lodged to SSM MBRS portal successfully.',
      ),
    ];
  }

  Future<void> addOrUpdateTask({
    required String companyName,
    required String title,
    required String subtitle,
    required DateTime dueDate,
    required String category,
    String? instructions,
    String? taskId,
  }) async {
    final profile = SecretaryDocumentService.instance.profile;
    final secretary = '${profile.name} (${profile.licenseNo.split(' /').first})';

    final id = taskId ?? 'task-sec-${DateTime.now().millisecondsSinceEpoch}';

    final index = _tasks.indexWhere((t) => t.id == id);
    final task = ComplianceTask(
      id: id,
      companyId: 'comp-01',
      companyName: companyName,
      title: title,
      subtitle: subtitle,
      dueDate: dueDate,
      category: category,
      status: 'Pending',
      createdBy: secretary,
      instructions: instructions,
    );

    if (index != -1) {
      _tasks[index] = task;
    } else {
      _tasks.insert(0, task);
    }
    notifyListeners();

    // Push to backend
    await _pushTaskToBackend(task);
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    final candidateUrls = [
      'http://127.0.0.1:5173/api/compliance-tasks/$taskId',
      'http://localhost:5173/api/compliance-tasks/$taskId',
      'http://10.0.2.2:5173/api/compliance-tasks/$taskId',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        await http.delete(uri).timeout(const Duration(milliseconds: 1200));
        break;
      } catch (_) {}
    }
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

  Future<void> _pushTaskToBackend(ComplianceTask task) async {
    final candidateUrls = [
      'http://127.0.0.1:5173/api/compliance-tasks',
      'http://localhost:5173/api/compliance-tasks',
      'http://10.0.2.2:5173/api/compliance-tasks',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(task.toJson()),
            )
            .timeout(const Duration(milliseconds: 1500));
        break;
      } catch (_) {}
    }
  }
}

