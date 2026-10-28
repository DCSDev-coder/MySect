import 'package:flutter/material.dart';

class SecretaryNotificationItem {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String category;
  final String? documentId;
  bool isRead;

  SecretaryNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.documentId,
    this.isRead = false,
  });
}

class SecretaryNotificationService extends ChangeNotifier {
  static final SecretaryNotificationService instance = SecretaryNotificationService._();
  SecretaryNotificationService._() {
    _initDefaultNotifications();
  }

  late List<SecretaryNotificationItem> _notifications;

  List<SecretaryNotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required String category,
    String? documentId,
  }) {
    final item = SecretaryNotificationItem(
      id: 'SEC-NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: 'Just now',
      category: category,
      documentId: documentId,
      isRead: false,
    );
    _notifications.insert(0, item);
    notifyListeners();
  }

  void _initDefaultNotifications() {
    _notifications = [
      SecretaryNotificationItem(
        id: 'SEC-NOTIF-001',
        title: 'New Client Upload Pending Review',
        body: 'Adam Bin Hamzah uploaded DCS_Management_Accounts_FY2026.pdf for Data Center Specialists Sdn Bhd (M).',
        timestamp: '10 mins ago',
        category: 'Client Upload',
        documentId: 'DOC-2026-001',
        isRead: false,
      ),
      SecretaryNotificationItem(
        id: 'SEC-NOTIF-002',
        title: 'Client Responded to Clarification Request',
        body: 'Data Center Specialists Sdn Bhd submitted updated tenancy stamping endorsement for Section 46 registered office.',
        timestamp: '1 hour ago',
        category: 'Clarification',
        documentId: 'DOC-2026-003',
        isRead: false,
      ),
      SecretaryNotificationItem(
        id: 'SEC-NOTIF-003',
        title: 'Statutory Lodgement Deadline Notice',
        body: 'Annual Return Section 68 statutory lodgement deadline is due within 14 days for Nexus Cloud Technologies Sdn Bhd.',
        timestamp: '3 hours ago',
        category: 'Compliance Notice',
        isRead: false,
      ),
      SecretaryNotificationItem(
        id: 'SEC-NOTIF-004',
        title: 'SSM MyCoID API Gateway Synchronized',
        body: 'All statutory certificates and company profiles have successfully synced with Suruhanjaya Syarikat Malaysia.',
        timestamp: 'Yesterday',
        category: 'SSM Gateway',
        isRead: true,
      ),
    ];
  }
}
