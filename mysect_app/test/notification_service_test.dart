import 'package:flutter_test/flutter_test.dart';
import 'package:mysect/mobile_app/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService.instance;
    });

    test('Initializes with default Malaysian corporate notifications', () {
      expect(service.notifications.isNotEmpty, true);
      expect(service.unreadCount, greaterThan(0));
    });

    test('Can mark a specific notification as read', () {
      final unreadNotif = service.notifications.firstWhere((n) => n.isUnread);
      final initialUnread = service.unreadCount;

      service.markAsRead(unreadNotif.id);

      expect(service.unreadCount, initialUnread - 1);
      final updated = service.notifications.firstWhere((n) => n.id == unreadNotif.id);
      expect(updated.isUnread, false);
    });

    test('Can mark all notifications as read', () {
      service.markAllAsRead();
      expect(service.unreadCount, 0);
    });

    test('Can add a new real-time statutory notification', () {
      final initialCount = service.notifications.length;

      service.addNotification(
        title: 'New SSM Certificate Issued',
        message: 'Section 46 Change of Address officially approved by SSM.',
        type: NotificationType.filingCompleted,
        relatedFilingId: 'SSM-03',
      );

      expect(service.notifications.length, initialCount + 1);
      expect(service.notifications.first.title, 'New SSM Certificate Issued');
      expect(service.notifications.first.isUnread, true);
    });
  });
}
