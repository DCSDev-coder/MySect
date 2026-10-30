import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ssm_filing_model.dart';

class SsmFilingService extends ChangeNotifier {
  static final SsmFilingService _instance = SsmFilingService._internal();
  static SsmFilingService get instance => _instance;

  SsmFilingService._internal() {
    _initDefaultFilings();
    syncFromBackend();
  }

  List<SsmFiling> _filings = [];
  List<SsmFiling> get filings => List.unmodifiable(_filings);

  int get waitingSecretaryCount =>
      _filings.where((f) => f.status == SsmFilingStatus.waitingSecretaryReview).length;

  int get secretaryRepliesNeededCount =>
      _filings.where((f) => f.status == SsmFilingStatus.secretaryReplied).length;

  int get pendingClientApprovalCount =>
      _filings.where((f) => f.status == SsmFilingStatus.waitingClientApproval).length;

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
        title: 'Section 68 Annual Return 2026',
        description:
            'Annual Return submission with management accounts and director report.',
        submittedDate: DateTime(2026, 10, 20, 14, 30),
        deadline: '2026-11-14',
        status: SsmFilingStatus.waitingSecretaryReview,
        attachedFiles: [
          'DCS_Management_Accounts_FY2026.pdf (2.4 MB)',
          'Director_Declaration_Form.pdf (850 KB)',
          'Bank_Statement_Confirmation.pdf (1.1 MB)',
        ],
        messages: [
          const SsmMessage(
            id: 'm-01',
            senderName: 'Adam Bin Hamzah',
            senderRole: 'Managing Director (Client)',
            text:
                'Hi Mei Ling, I have attached our management accounts and declarations for the upcoming Annual Return. Please check and let us know if anything else is needed before submitting to SSM.',
            time: '20 Oct 2026, 2:30 PM',
            isFromSecretary: false,
            attachments: ['DCS_Management_Accounts_FY2026.pdf'],
          ),
          const SsmMessage(
            id: 'm-02',
            senderName: 'Lim Mei Ling (MIA)',
            senderRole: 'Licensed Corporate Secretary',
            text:
                'Hello Adam! We have received your files. I am currently running the preliminary verification against the SSM register. Will update you once the formal resolution is drafted.',
            time: '20 Oct 2026, 3:15 PM',
            isFromSecretary: true,
          ),
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'File Submitted to Secretary',
            description: 'Uploaded management accounts and declarations.',
            timestamp: '20 Oct 2026, 2:30 PM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Waiting for Secretary Review',
            description: 'Assigned to Lim Mei Ling (MIA) at SectPro Corporate Services.',
            timestamp: 'In Progress',
            isCompleted: false,
            isCurrent: true,
          ),
          const SsmTimelineStep(
            title: 'Secretary Preparation & Customer Approval',
            description: 'Drafting Section 68 e-Filing schedule and resolution.',
            timestamp: 'Pending review',
            isCompleted: false,
          ),
          const SsmTimelineStep(
            title: 'Submitted to SSM',
            description: 'Official submission to Suruhanjaya Syarikat Malaysia.',
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
            'Appointment of new Non-Executive Director (Dato\' Adam Bin Hamzah).',
        submittedDate: DateTime(2026, 10, 18, 10, 0),
        deadline: '2026-10-31',
        status: SsmFilingStatus.secretaryReplied,
        attachedFiles: [
          'Dato_Adam_Profile_Resume.pdf (1.2 MB)',
          'Draft_Board_Resolution_Director.docx (420 KB)',
        ],
        messages: [
          const SsmMessage(
            id: 'm-03',
            senderName: 'Adam Bin Hamzah',
            senderRole: 'Managing Director (Client)',
            text:
                'Submitting the appointment documentation for Dato Adam to join the board.',
            time: '18 Oct 2026, 10:00 AM',
            isFromSecretary: false,
          ),
          const SsmMessage(
            id: 'm-04',
            senderName: 'Lim Mei Ling (MIA)',
            senderRole: 'Licensed Corporate Secretary',
            text:
                'Hi Adam, thank you for the documents. Under Section 201 of the Companies Act 2016, we also require a signed Form 48A / Statutory Declaration of Consent to Act, plus a clear scanned copy of Dato Adam\'s NRIC (front and back). Could you please upload those here so we can complete Section 58 submission?',
            time: '19 Oct 2026, 11:20 AM',
            isFromSecretary: true,
          ),
        ],
        timeline: [
          const SsmTimelineStep(
            title: 'File Submitted to Secretary',
            description: 'Uploaded appointment documentation.',
            timestamp: '18 Oct 2026, 10:00 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Secretary Query / Clarification Needed',
            description: 'Secretary requested Section 201 Consent to Act and NRIC copy.',
            timestamp: '19 Oct 2026, 11:20 AM',
            isCompleted: false,
            isCurrent: true,
          ),
          const SsmTimelineStep(
            title: 'Client Re-submission & Approval',
            description: 'Waiting for requested NRIC and Consent to Act.',
            timestamp: 'Action required',
            isCompleted: false,
          ),
          const SsmTimelineStep(
            title: 'Submitted to SSM',
            description: 'Submission of Form 58 to SSM.',
            timestamp: 'Pending client response',
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
        assignedSecretary: 'Azman bin Ibrahim (MAICSA)',
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
        messages: [
          const SsmMessage(
            id: 'm-05',
            senderName: 'Azman bin Ibrahim (MAICSA)',
            senderRole: 'Principal Secretary',
            text:
                'Good day! Section 46 documents verified and signed. Successfully submitted to SSM (Ref: MBRS-2026-99381). Awaiting SSM Certificate generation.',
            time: '15 Oct 2026, 4:10 PM',
            isFromSecretary: true,
          ),
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
        assignedSecretary: 'Sarah binti Ahmad (MAICSA)',
        assignedFirmName: 'Apex Corporate Secretarial Partners',
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
        messages: [
          const SsmMessage(
            id: 'm-06',
            senderName: 'Sarah binti Ahmad (MAICSA)',
            senderRole: 'Licensed Secretary',
            text:
                'Congratulations! The Section 78 Return of Share Allotment has been approved and endorsed by SSM. Updated corporate profile with new capital is now available in your Files tab.',
            time: '28 Sep 2026, 2:30 PM',
            isFromSecretary: true,
          ),
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
            title: 'Submitted to SSM',
            description: 'Submitted with SSM Section 78 schedule.',
            timestamp: '25 Sep 2026, 9:30 AM',
            isCompleted: true,
          ),
          const SsmTimelineStep(
            title: 'Completed & Certified by SSM',
            description: 'Official Certificate and SSM receipt generated.',
            timestamp: '28 Sep 2026, 2:30 PM',
            isCompleted: true,
          ),
        ],
      ),
    ];
  }

  // Submit a new SSM filing from client
  SsmFiling submitNewFiling({
    required String companyName,
    required String companySsmNo,
    required String filingType,
    required String title,
    required String description,
    required String deadline,
    required List<String> files,
    String? initialNote,
  }) {
    final newId = 'SSM-${(_filings.length + 1).toString().padLeft(2, '0')}';
    final ref = 'SSM/${filingType.split(' ').take(2).join('/')}/2026/${DateTime.now().millisecondsSinceEpoch % 10000}';

    final List<SsmMessage> initialMessages = [];
    if (initialNote != null && initialNote.trim().isNotEmpty) {
      initialMessages.add(
        SsmMessage(
          id: 'm-${DateTime.now().millisecondsSinceEpoch}',
          senderName: 'Client Director',
          senderRole: 'Authorised Representative',
          text: initialNote.trim(),
          time: 'Just now',
          isFromSecretary: false,
          attachments: files,
        ),
      );
    }

    final newFiling = SsmFiling(
      id: newId,
      referenceNo: ref,
      companyId: 'comp-01',
      companyName: companyName,
      companySsmNo: companySsmNo,
      assignedSecretary: 'Lim Mei Ling (MIA)',
      assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
      filingType: filingType,
      title: title,
      description: description,
      submittedDate: DateTime.now(),
      deadline: deadline,
      status: SsmFilingStatus.waitingSecretaryReview,
      attachedFiles: files.isNotEmpty ? files : ['Uploaded_SSM_Document.pdf (1.4 MB)'],
      messages: initialMessages,
      timeline: [
        SsmTimelineStep(
          title: 'SSM File Submitted by Client',
          description: 'Uploaded initial documents for $filingType.',
          timestamp: 'Just now',
          isCompleted: true,
        ),
        const SsmTimelineStep(
          title: 'Waiting for Secretary Review',
          description: 'Queued for assigned licensed secretary verification.',
          timestamp: 'In progress',
          isCompleted: false,
          isCurrent: true,
        ),
        const SsmTimelineStep(
          title: 'Secretary Approval & Draft Resolution',
          description: 'Secretary drafts resolution and prepares filing schedule.',
          timestamp: 'Pending review',
          isCompleted: false,
        ),
        const SsmTimelineStep(
          title: 'Submitted to SSM',
          description: 'Submission to Suruhanjaya Syarikat Malaysia.',
          timestamp: 'Scheduled',
          isCompleted: false,
        ),
      ],
    );

    _filings.insert(0, newFiling);
    notifyListeners();
    return newFiling;
  }

  // Client replies to a filing thread
  void sendClientReply(String filingId, String messageText, {List<String>? attachments}) {
    final filing = _filings.firstWhere((f) => f.id == filingId);
    filing.messages.add(
      SsmMessage(
        id: 'm-${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Client Director',
        senderRole: 'Authorised Representative',
        text: messageText,
        time: 'Just now',
        isFromSecretary: false,
        attachments: attachments ?? const [],
      ),
    );

    // If it was waiting for client action, update status back to waiting for secretary
    if (filing.status == SsmFilingStatus.secretaryReplied) {
      filing.status = SsmFilingStatus.waitingSecretaryReview;
      filing.timeline.add(
        SsmTimelineStep(
          title: 'Client Sent Additional Clarification',
          description: 'Uploaded requested details. Secretary re-reviewing.',
          timestamp: 'Just now',
          isCompleted: true,
        ),
      );
    }
    notifyListeners();
  }

  // Director digitally approves and signs the statutory filing draft
  void approveAndSignOffAsDirector(String filingId, {String? signatureNote}) {
    final filing = _filings.firstWhere((f) => f.id == filingId);
    filing.status = SsmFilingStatus.lodgedToSsm;
    filing.messages.add(
      SsmMessage(
        id: 'sign-${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Client Director',
        senderRole: 'Managing Director (Authorised Signatory)',
        text: signatureNote ?? 'Director digitally reviewed, signed, and approved statutory filing draft. Authorized secretary to lodge with SSM.',
        time: 'Just now',
        isFromSecretary: false,
      ),
    );
    filing.timeline.add(
      SsmTimelineStep(
        title: 'Director Digitally Endorsed & Approved',
        description: 'Statutory approval granted by Director. Queued for SSM lodgement.',
        timestamp: 'Just now',
        isCompleted: true,
      ),
    );
    notifyListeners();
  }

  // SIMULATION METHODS (for interactive demo testing!)
  void simulateSecretaryClarification(String filingId, [String? customMessage]) {
    final filing = _filings.firstWhere((f) => f.id == filingId);
    filing.status = SsmFilingStatus.secretaryReplied;
    filing.messages.add(
      SsmMessage(
        id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
        senderName: filing.assignedSecretary,
        senderRole: 'Licensed Corporate Secretary',
        text: customMessage ??
            'Hi, we checked your submission. Please provide the signed Board Resolution and verify that all current directors have updated their registered addresses.',
        time: 'Just now',
        isFromSecretary: true,
      ),
    );
    notifyListeners();
  }

  void simulateSecretaryApproval(String filingId) {
    final filing = _filings.firstWhere((f) => f.id == filingId);
    filing.status = SsmFilingStatus.lodgedToSsm;
    filing.messages.add(
      SsmMessage(
        id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
        senderName: filing.assignedSecretary,
        senderRole: 'Licensed Corporate Secretary',
        text:
            'All documents and compliance criteria checked and verified! We have officially submitted this to SSM. Waiting for SSM endorsement.',
        time: 'Just now',
        isFromSecretary: true,
      ),
    );
    notifyListeners();
  }

  void simulateSsmCompletion(String filingId) {
    final filing = _filings.firstWhere((f) => f.id == filingId);
    filing.status = SsmFilingStatus.completed;
    filing.messages.add(
      SsmMessage(
        id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
        senderName: filing.assignedSecretary,
        senderRole: 'Licensed Corporate Secretary',
        text:
            'Success! SSM has registered your filing and issued the official acknowledgement certificate. The filing is now fully complete.',
        time: 'Just now',
        isFromSecretary: true,
      ),
    );
    notifyListeners();
  }

  Future<void> syncFromBackend() async {
    final candidateUrls = [
      'http://127.0.0.1:5173/api/ssm-filings',
      'http://localhost:5173/api/ssm-filings',
      'http://10.0.2.2:5173/api/ssm-filings',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http.get(uri).timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            _filings = data.map((json) => SsmFiling.fromJson(json)).toList();
            notifyListeners();
            return;
          }
        }
      } catch (_) {}
    }
  }
}
