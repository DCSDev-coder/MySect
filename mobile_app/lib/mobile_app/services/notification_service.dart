import 'package:flutter/material.dart';

enum NotificationType {
  secretaryAction,
  documentReview,
  deadlineReminder,
  filingCompleted,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isUnread;
  final String? relatedFilingId;
  final String? relatedDocId;
  final String? routeTag; // 'filing_detail', 'replies_needed', 'document_needed', 'calendar'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = true,
    this.relatedFilingId,
    this.relatedDocId,
    this.routeTag,
  });
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal() {
    _initDefaultNotifications();
  }

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  void _initDefaultNotifications() {
    _notifications.addAll([
      AppNotification(
        id: 'notif-01',
        title: 'Secretary Action Required',
        message:
            'Lim Mei Ling requested Form 48A Consent to Act and NRIC for Section 58 Notice of Appointment (Ref: SSM/S58/2026/01192).',
        time: '25 mins ago',
        type: NotificationType.secretaryAction,
        isUnread: true,
        routeTag: 'filing_detail',
        relatedFilingId: 'SSM-02',
      ),
      AppNotification(
        id: 'notif-02',
        title: 'Document Rejected – Action Required',
        message:
            'Sarah binti Ahmad rejected New_Investor_Passport_Scan.pdf. Passport expires in less than 3 months (minimum 6 months required).',
        time: '1 hour ago',
        type: NotificationType.documentReview,
        isUnread: true,
        routeTag: 'replies_needed',
      ),
      AppNotification(
        id: 'notif-03',
        title: 'Upcoming Statutory Deadline',
        message:
            'Section 68 Annual Return Lodgement 2026 is due in 18 days (14 Nov 2026) for Data Center Specialists Sdn Bhd (M).',
        time: '3 hours ago',
        type: NotificationType.deadlineReminder,
        isUnread: true,
        routeTag: 'calendar',
        relatedFilingId: 'SSM-01',
      ),
      AppNotification(
        id: 'notif-04',
        title: 'Filing Lodged to SSM',
        message:
            'Section 46 Change of Registered Address (Ref: SSM/S46/2026/00731) has been successfully lodged to SSM MBRS Portal.',
        time: '1 day ago',
        type: NotificationType.secretaryAction,
        isUnread: false,
        routeTag: 'filing_detail',
        relatedFilingId: 'SSM-03',
      ),
      AppNotification(
        id: 'notif-05',
        title: 'SSM Filing Completed & Approved',
        message:
            'Section 78 Return of Share Allotment (Capital Increase) completed. Official SSM Receipt generated.',
        time: '2 days ago',
        type: NotificationType.filingCompleted,
        isUnread: false,
        routeTag: 'filing_detail',
        relatedFilingId: 'SSM-04',
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && _notifications[index].isUnread) {
      _notifications[index].isUnread = false;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final notif in _notifications) {
      if (notif.isUnread) {
        notif.isUnread = false;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedFilingId,
    String? relatedDocId,
    String? routeTag,
  }) {
    final newNotif = AppNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      time: 'Just now',
      type: type,
      isUnread: true,
      relatedFilingId: relatedFilingId,
      relatedDocId: relatedDocId,
      routeTag: routeTag,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
  }
}
