import '../../widgets/secretary_sidebar.dart';
import '../../widgets/secretary_desktop_top_bar.dart';
import '../shell/main_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/secretary_notification_service.dart';
import '../../services/secretary_document_service.dart';
import '../review_queue/document_review_detail_page.dart';

class SecretaryNotificationsPage extends StatelessWidget {
  const SecretaryNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SecretaryNotificationService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final notifications = service.notifications;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            final mainContent = Column(
              children: [
                if (isDesktop)
                  SecretaryDesktopTopBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      tooltip: 'Back to Workspace',
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: 'Notifications & Statutory Alerts',
                    badgeText: 'SSM LICENSED',
                  ),
                if (isDesktop && service.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${service.unreadCount} unread statutory notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => service.markAllAsRead(),
                          icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF062AAE)),
                          label: Text(
                            'Mark all as read',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF062AAE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            );

            if (isDesktop) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: Row(
                  children: [
                    SecretarySidebar(
                      currentIndex: 0,
                      onSelectTab: (idx) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainNavigationShell(initialIndex: idx),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    Expanded(child: mainContent),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (service.unreadCount > 0)
                    TextButton.icon(
                      onPressed: () => service.markAllAsRead(),
                      icon: const Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: Color(0xFF062AAE),
                      ),
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
              body: mainContent,
            );
          },
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
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? Colors.grey.shade200 : const Color(0xFF93C5FD),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: categoryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(categoryIcon, size: 16, color: categoryColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: categoryBg,
                                borderRadius: BorderRadius.circular(5),
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
                              style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.title,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notif.body,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!notif.isRead) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 4),
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
