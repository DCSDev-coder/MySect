import 'package:flutter_test/flutter_test.dart';
import 'package:secretary_app/models/client_document_model.dart';
import 'package:secretary_app/services/secretary_document_service.dart';

void main() {
  group('Secretary Document Intake & Review Workflow Tests', () {
    late SecretaryDocumentService service;

    setUp(() {
      service = SecretaryDocumentService.instance;
    });

    test('Loads statutory filings sent by end users across Malaysian companies', () {
      expect(service.documents.isNotEmpty, isTrue);
      expect(service.clientCompanies.length, greaterThanOrEqualTo(2));
      expect(service.pendingCount, greaterThanOrEqualTo(1));
    });

    test('Secretary reviews and approves a statutory document', () async {
      final doc = service.documents.firstWhere(
        (d) => d.status == DocumentReviewStatus.pendingReview,
      );

      final initialAuditCount = doc.auditTrail.length;

      await service.reviewDocument(
        doc.id,
        DocumentReviewStatus.approved,
        remarks: 'Verified against Section 68 Companies Act 2016. All signatures authenticated.',
      );

      expect(doc.status, equals(DocumentReviewStatus.approved));
      expect(doc.reviewDetails, isNotNull);
      expect(doc.reviewDetails!.decision, equals('Approved'));
      expect(doc.reviewDetails!.remarks, contains('Companies Act 2016'));
      expect(doc.auditTrail.length, equals(initialAuditCount + 1));
      expect(doc.auditTrail.last.action, equals('FILE_APPROVED'));
    });

    test('Secretary reviews and rejects a document with statutory non-compliance reason', () async {
      final newDoc = await service.addClientDocument(
        title: 'Draft_Form_48A_Director.pdf',
        category: 'Section 58 Notice',
        fileSize: '1.1 MB',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
      );

      expect(newDoc.status, equals(DocumentReviewStatus.pendingReview));

      await service.reviewDocument(
        newDoc.id,
        DocumentReviewStatus.rejected,
        rejectionReason: 'Form 48A not signed before a Commissioner for Oaths pursuant to Section 201.',
      );

      expect(newDoc.status, equals(DocumentReviewStatus.rejected));
      expect(newDoc.reviewDetails!.decision, equals('Rejected'));
      expect(newDoc.reviewDetails!.rejectionReason, contains('Commissioner for Oaths'));
      expect(newDoc.auditTrail.last.action, equals('FILE_REJECTED'));
    });

    test('Secretary reviews and requests more details / clarifications from client', () async {
      final newDoc = await service.addClientDocument(
        title: 'Tenancy_Cyberjaya_Office.pdf',
        category: 'Section 46 Registered Office',
        fileSize: '3.4 MB',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
      );

      await service.reviewDocument(
        newDoc.id,
        DocumentReviewStatus.moreDetailsNeeded,
        requestedDetails: 'Please provide official LHDN stamp duty certificate for the registered office agreement.',
      );

      expect(newDoc.status, equals(DocumentReviewStatus.moreDetailsNeeded));
      expect(newDoc.reviewDetails!.decision, equals('More Details Needed'));
      expect(newDoc.reviewDetails!.requestedDetails, contains('LHDN stamp duty certificate'));
      expect(newDoc.auditTrail.last.action, equals('DETAILS_REQUESTED'));
    });
  });
}
