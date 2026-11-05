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
      SsmFiling(
        id: 'SSM-03',
        referenceNo: 'SSM/S46/2026/00731',
        companyId: 'comp-02',
        companyName: 'C2 Coffee + Candle',
        companySsmNo: '202001019482 (1382941-T)',
        assignedSecretary: 'Lim Mei Ling (MIA)',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        filingType: 'Section 46 Change of Registered Address',
        title: 'Section 46 Change of Registered Office Address',
        description:
            'Relocation of registered office address to Level 18, Menara Binjai.',
        submittedDate: DateTime(2026, 10, 12, 16, 45),
        deadline: '2026-10-25',
        status: SsmFilingStatus.lodgedToSsm,
        attachedFiles: [
          'Tenancy_Agreement_Binjai.pdf (3.1 MB)',
          'Signed_Board_Resolution_S46.pdf (640 KB)',
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'SSM File Submitted',
            description: 'Registered address relocation request submitted.',
            timestamp: '12 Oct 2026, 4:45 PM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Secretary Verification Complete',
            description: 'Board resolution vetted and approved.',
            timestamp: '14 Oct 2026, 10:30 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Submitted to SSM',
            description: 'Submitted under SSM Reference MBRS-2026-99381.',
            timestamp: '15 Oct 2026, 4:10 PM',
            isCompleted: true,
            isCurrent: true,
          ),
          const SsmTimelineStep(
            title: 'SSM Registration Acknowledged',
            description: 'SSM generates official confirmation notice.',
            timestamp: 'Expected within 2 business days',
            isCompleted: false,
          ),
        ],
      ),
      SsmFiling(
        id: 'SSM-04',
        referenceNo: 'SSM/S78/2026/00194',
        companyId: 'comp-03',
        companyName: '5Luxe Scents Co.',
        companySsmNo: '202201082918 (1482910-P)',
        assignedSecretary: 'Lim Mei Ling (MIA)',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        filingType: 'Section 78 Return of Allotment of Shares',
        title: 'Section 78 Return of Share Allotment (Capital Increase)',
        description: 'Increase of paid-up capital from RM 20,000 to RM 50,000.',
        submittedDate: DateTime(2026, 09, 20, 11, 0),
        deadline: '2026-10-15',
        status: SsmFilingStatus.completed,
        attachedFiles: [
          'Bank_In_Slip_Capital.pdf (890 KB)',
          'Members_Resolution_S78.pdf (1.2 MB)',
          'SSM_Official_Receipt_S78.pdf (520 KB)',
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'SSM File Submitted',
            description: 'Capital increase documents uploaded.',
            timestamp: '20 Sep 2026, 11:00 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Secretary Preparation',
            description: 'Vetted bank slip and member resolutions.',
            timestamp: '22 Sep 2026, 2:15 PM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Lodged to SSM MBRS',
            description: 'Lodged and verified by SSM registrar.',
            timestamp: '25 Sep 2026, 11:45 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Filing Approved & Endorsed',
            description: 'Certified Return of Share Allotment released.',
            timestamp: '28 Sep 2026, 2:30 PM',
            isCompleted: true,
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
