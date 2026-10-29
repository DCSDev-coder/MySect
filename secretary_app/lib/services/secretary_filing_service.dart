import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/ssm_filing_model.dart';

class SecretaryFilingService extends ChangeNotifier {
  static final SecretaryFilingService _instance =
      SecretaryFilingService._internal();
  static SecretaryFilingService get instance => _instance;

  SecretaryFilingService._internal() {
    _initDefaultFilings();
    syncFromBackend();
  }

  List<SsmFiling> _filings = [];
  bool _isSyncing = false;

  List<SsmFiling> get filings => List.unmodifiable(_filings);
  bool get isSyncing => _isSyncing;

  SsmFiling? getFilingByRefOrCompany(String refNo, String companyName) {
    if (refNo.isNotEmpty) {
      final match = _filings.where(
        (f) => f.referenceNo.toLowerCase().trim() == refNo.toLowerCase().trim(),
      );
      if (match.isNotEmpty) return match.first;
    }
    final compMatch = _filings.where(
      (f) =>
          f.companyName.toLowerCase().trim() ==
          companyName.toLowerCase().trim(),
    );
    if (compMatch.isNotEmpty) return compMatch.first;
    return null;
  }

  void _initDefaultFilings() {
    _filings = [
      SsmFiling(
        id: 'SSM-01',
        referenceNo: 'SSM/S68/2026/04812',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedSecretary: 'Lim Mei Ling (MIA)',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        filingType: 'Section 68 Annual Return',
        title: 'Section 68 Annual Return Lodgement 2026',
        description: 'Annual Return submission with unaudited management accounts and audited director report for statutory filing.',
        submittedDate: DateTime(2026, 10, 20, 14, 30),
        deadline: '2026-11-14',
        status: SsmFilingStatus.waitingSecretaryReview,
        attachedFiles: [
          'DCS_Management_Accounts_FY2026.pdf (2.4 MB)',
          'Director_Declaration_Form.pdf (850 KB)',
          'Bank_Statement_Confirmation.pdf (1.1 MB)',
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'File Submitted to Secretary',
            description:
                'Uploaded management accounts and statutory declarations.',
            timestamp: '20 Oct 2026, 2:30 PM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Waiting for Secretary Review',
            description:
                'Assigned to Lim Mei Ling (MIA) at SectPro Corporate Services.',
            timestamp: 'In Progress',
            isCompleted: false,
            isCurrent: true,
          ),
          const SsmTimelineStep(
            title: 'Secretary Preparation & Customer Approval',
            description:
                'Drafting Section 68 e-Filing schedule and resolution.',
            timestamp: 'Pending review',
            isCompleted: false,
          ),
          const SsmTimelineStep(
            title: 'Submitted to SSM',
            description:
                'Official submission to Suruhanjaya Syarikat Malaysia.',
            timestamp: 'Scheduled',
            isCompleted: false,
          ),
        ],
      ),
      SsmFiling(
        id: 'SSM-02',
        referenceNo: 'SSM/S58/2026/01192',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        assignedSecretary: 'Lim Mei Ling (MIA)',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        filingType: 'Section 58 Notice of Director Change',
        title: 'Section 58 Notice of Appointment of Director',
        description:
            'Appointment of new Non-Executive Director (Dato Adam Bin Hamzah).',
        submittedDate: DateTime(2026, 10, 18, 10, 0),
        deadline: '2026-10-31',
        status: SsmFilingStatus.secretaryReplied,
        attachedFiles: [
          'Dato_Adam_Profile_Resume.pdf (1.2 MB)',
          'Draft_Board_Resolution_Director.docx (420 KB)',
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'File Submitted to Secretary',
            description: 'Uploaded appointment documentation.',
            timestamp: '18 Oct 2026, 10:00 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Waiting for Secretary Review',
            description: 'Verified by Lim Mei Ling (MIA).',
            timestamp: '19 Oct 2026, 11:20 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Clarification & Form 48A Requested',
            description:
                'Requested Form 48A and clear NRIC scan under Section 201.',
            timestamp: 'In Progress',
            isCompleted: false,
            isCurrent: true,
          ),
          const SsmTimelineStep(
            title: 'Submitted to SSM',
            description: 'Pending document resolution from client.',
            timestamp: 'Pending',
            isCompleted: false,
          ),
        ],
      ),
    ];
  }

  Future<void> updateFilingStep({
    required String referenceNo,
    required int
    targetStepIndex, // 0 = Submitted, 1 = Review, 2 = Preparation, 3 = Lodged
  }) async {
    final idx = _filings.indexWhere(
      (f) =>
          f.referenceNo.toLowerCase().trim() ==
          referenceNo.toLowerCase().trim(),
    );
    if (idx == -1) return;

    final filing = _filings[idx];
    final now = DateTime.now();
    final timeStr = DateFormat('dd MMM yyyy, h:mm a').format(now);

    final updatedTimeline = <SsmTimelineStep>[];
    for (int i = 0; i < filing.timeline.length; i++) {
      final step = filing.timeline[i];
      if (i < targetStepIndex) {
        updatedTimeline.add(
          step.copyWith(
            isCompleted: true,
            isCurrent: false,
            timestamp:
                step.timestamp.contains('Progress') ||
                    step.timestamp.contains('Pending')
                ? timeStr
                : step.timestamp,
          ),
        );
      } else if (i == targetStepIndex) {
        final isLast = targetStepIndex == filing.timeline.length - 1;
        updatedTimeline.add(
          step.copyWith(
            isCompleted: isLast,
            isCurrent: !isLast,
            timestamp: isLast ? 'Lodged at $timeStr' : 'In Progress ($timeStr)',
          ),
        );
      } else {
        updatedTimeline.add(
          step.copyWith(
            isCompleted: false,
            isCurrent: false,
            timestamp: 'Scheduled',
          ),
        );
      }
    }

    filing.timeline = updatedTimeline;

    // Update filing status
    if (targetStepIndex >= 3) {
      filing.status = SsmFilingStatus.lodgedToSsm;
    } else if (targetStepIndex == 2) {
      filing.status = SsmFilingStatus.waitingClientApproval;
    } else if (targetStepIndex == 1) {
      filing.status = SsmFilingStatus.waitingSecretaryReview;
    }

    notifyListeners();

    // Push to backend
    await _pushFilingUpdateToBackend(filing);
  }

  Future<void> syncFromBackend() async {
    _isSyncing = true;
    notifyListeners();

    final candidateUrls = [
      'http://127.0.0.1:5173/api/ssm-filings',
      'http://localhost:5173/api/ssm-filings',
      'http://10.0.2.2:5173/api/ssm-filings',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http
            .get(uri)
            .timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            _filings = data.map((json) => SsmFiling.fromJson(json)).toList();
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

  Future<void> _pushFilingUpdateToBackend(SsmFiling filing) async {
    final candidateUrls = [
      'http://127.0.0.1:5173/api/ssm-filings/${filing.referenceNo}',
      'http://localhost:5173/api/ssm-filings/${filing.referenceNo}',
      'http://10.0.2.2:5173/api/ssm-filings/${filing.referenceNo}',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        await http
            .patch(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(filing.toJson()),
            )
            .timeout(const Duration(milliseconds: 1500));
        break;
      } catch (_) {}
    }
  }
}
