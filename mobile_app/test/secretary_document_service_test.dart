import 'package:flutter_test/flutter_test.dart';
import 'package:mysect/mobile_app/models/client_document_model.dart';
import 'package:mysect/mobile_app/services/secretary_document_service.dart';

void main() {
  group('SecretaryDocumentService Tests', () {
    late SecretaryDocumentService service;

    setUp(() {
      service = SecretaryDocumentService.instance;
    });

    test('Initializes with default statutory documents and correct metric counts', () {
      expect(service.documents.isNotEmpty, isTrue);
      expect(service.pendingCount, greaterThanOrEqualTo(1));
      expect(service.approvedCount, greaterThanOrEqualTo(1));
      expect(service.rejectedCount, greaterThanOrEqualTo(1));
      expect(service.moreDetailsCount, greaterThanOrEqualTo(1));
    });

    test('Secretary can approve a pending document with endorsement remarks', () async {
      final doc = service.documents.firstWhere(
        (d) => d.status == DocumentReviewStatus.pendingReview,
      );

      final initialAuditCount = doc.auditTrail.length;

      await service.reviewDocument(
        doc.id,
        DocumentReviewStatus.approved,
        remarks: 'Verified against Companies Act 2016 statutory requirements.',
      );

      expect(doc.status, equals(DocumentReviewStatus.approved));
      expect(doc.reviewDetails, isNotNull);
      expect(doc.reviewDetails!.decision, equals('Approved'));
      expect(doc.reviewDetails!.remarks, contains('Companies Act 2016'));
      expect(doc.auditTrail.length, equals(initialAuditCount + 1));
      expect(doc.auditTrail.last.action, equals('FILE_APPROVED'));
    });

    test('Secretary can reject a document with statutory reason', () async {
      // Add a test document
      final newDoc = await service.addClientDocument(
        title: 'Draft_Constitution_Revision.pdf',
        category: 'Section 32 Constitution',
        fileSize: '3.1 MB',
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
        rejectionReason: 'Special resolution signatures missing on Section 32 lodgement.',
      );

      expect(newDoc.status, equals(DocumentReviewStatus.rejected));
      expect(newDoc.reviewDetails!.decision, equals('Rejected'));
      expect(newDoc.reviewDetails!.rejectionReason, contains('Special resolution signatures missing'));
      expect(newDoc.auditTrail.last.action, equals('FILE_REJECTED'));
    });

    test('Secretary can ask for more details with specific clarification query', () async {
      final newDoc = await service.addClientDocument(
        title: 'Tenancy_Agreement_HQ.pdf',
        category: 'Section 46 Registered Office',
        fileSize: '5.2 MB',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
      );

      await service.reviewDocument(
        newDoc.id,
        DocumentReviewStatus.moreDetailsNeeded,
        requestedDetails: 'Please provide the LHDN stamp duty endorsement certificate for this tenancy agreement.',
      );

      expect(newDoc.status, equals(DocumentReviewStatus.moreDetailsNeeded));
      expect(newDoc.reviewDetails!.decision, equals('More Details Needed'));
      expect(newDoc.reviewDetails!.requestedDetails, contains('LHDN stamp duty endorsement'));
      expect(newDoc.auditTrail.last.action, equals('DETAILS_REQUESTED'));
    });

    test('Client document upload increments documents list and starts with pending status', () async {
      final initialCount = service.documents.length;

      final uploaded = await service.addClientDocument(
        title: 'New_Board_Resolution_Director_Appointment.pdf',
        category: 'Section 58 Notice',
        fileSize: '1.7 MB',
        companyId: 'comp-01',
        companyName: 'Data Center Specialists Sdn Bhd (M)',
        companySsmNo: '202101039281 (1429581-X)',
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        notes: 'Signed board resolution approving new appointment.',
      );

      expect(service.documents.length, equals(initialCount + 1));
      expect(service.documents.first.id, equals(uploaded.id));
      expect(uploaded.status, equals(DocumentReviewStatus.pendingReview));
      expect(uploaded.auditTrail.first.action, equals('FILE_UPLOADED'));
    });

    test('Unsorted documents and folder document operations work correctly', () async {
      expect(service.unsortedCount, greaterThanOrEqualTo(1));
      final unsortedDoc = service.unsortedDocuments.first;

      final initialCorporateCount = service.getFolderDocumentCount('Corporate');

      // Move unsorted document to Corporate
      service.moveDocument(unsortedDoc.id, 'Corporate');

      expect(service.getFolderDocumentCount('Corporate'), equals(initialCorporateCount + 1));
      expect(service.getDocumentsForFolder('Corporate').any((d) => d.id == unsortedDoc.id), isTrue);

      // Re-upload document
      await service.reuploadDocument(unsortedDoc.id, 'Scanned_Doc_Updated.pdf', '2.4 MB');
      final updated = service.documents.firstWhere((d) => d.id == unsortedDoc.id);
      expect(updated.title, equals('Scanned_Doc_Updated.pdf'));
      expect(updated.fileSize, equals('2.4 MB'));
      expect(updated.status, equals(DocumentReviewStatus.pendingReview));
      expect(updated.auditTrail.last.action, equals('FILE_REUPLOADED'));
    });
  });
}

