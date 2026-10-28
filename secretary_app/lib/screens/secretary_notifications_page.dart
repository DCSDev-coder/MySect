import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/secretary_notification_service.dart';
import '../services/secretary_document_service.dart';
import '../widgets/app_top_header.dart';
import 'document_review_detail_page.dart';

class SecretaryNotificationsPage extends StatelessWidget {
  const SecretaryNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SecretaryNotificationService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final notifications = service.notifications;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                const AppTopHeader(showNotificationBell: false),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (service.unreadCount > 0)
                        TextButton.icon(
                          onPressed: () => service.markAllAsRead(),
                          icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF062AAE)),
                          label: Text(
                            'Mark all read',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF062AAE),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Expanded(
                  child: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No notifications yet',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are all caught up on statutory updates',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildNotificationCard(context, notif);
                  },
                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, SecretaryNotificationItem notif) {
    Color categoryBg;
    Color categoryColor;
    IconData categoryIcon;

    switch (notif.category) {
      case 'Client Upload':
        categoryBg = const Color(0xFFEFF6FF);
        categoryColor = const Color(0xFF2563EB);
        categoryIcon = Icons.upload_file_rounded;
        break;
      case 'Clarification':
        categoryBg = const Color(0xFFFEF3C7);
        categoryColor = const Color(0xFFD97706);
        categoryIcon = Icons.help_outline_rounded;
        break;
      case 'Compliance Notice':
        categoryBg = const Color(0xFFFEE2E2);
        categoryColor = const Color(0xFFDC2626);
        categoryIcon = Icons.warning_amber_rounded;
        break;
      default:
        categoryBg = const Color(0xFFECFDF5);
        categoryColor = const Color(0xFF059669);
        categoryIcon = Icons.shield_outlined;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        SecretaryNotificationService.instance.removeNotification(notif.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? Colors.grey.shade200 : const Color(0xFF93C5FD),
            width: notif.isRead ? 1.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              SecretaryNotificationService.instance.markAsRead(notif.id);
              if (notif.documentId != null) {
                final doc = SecretaryDocumentService.instance.documents
                    .where((d) => d.id == notif.documentId)
                    .firstOrNull;
                if (doc != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentReviewDetailPage(document: doc),
                    ),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(categoryIcon, size: 20, color: categoryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notif.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            Text(
                              notif.timestamp,
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notif.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          notif.body,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!notif.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF062AAE),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
