import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../tasks/document_needed_page.dart';
import '../tasks/replies_needed_page.dart';
import '../transactions/ssm_filing_detail_page.dart';
import '../more/calendar_page.dart';
import '../widgets/app_top_header.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(showNotificationBell: false),
            Expanded(
              child: AnimatedBuilder(
                animation: NotificationService.instance,
                builder: (context, _) {
                  final allNotifications =
                      NotificationService.instance.notifications;
                  final unreadCount = NotificationService.instance.unreadCount;

                  // Filter logic
                  final filteredList = allNotifications.where((n) {
                    if (_selectedFilter == 'Unread') {
                      return n.isUnread;
                    } else if (_selectedFilter == 'Secretary Actions') {
                      return n.type == NotificationType.secretaryAction ||
                          n.type == NotificationType.documentReview;
                    } else if (_selectedFilter == 'Deadlines') {
                      return n.type == NotificationType.deadlineReminder;
                    }
                    return true;
                  }).toList();

                  return Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 14.0,
                          bottom: 8.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black87,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    'Notifications',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (unreadCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              TextButton(
                                onPressed: () {
                                  NotificationService.instance.markAllAsRead();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'All notifications marked as read.',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFF062AAE),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Mark all read',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF062AAE),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        child: Row(
                          children: [
                            _buildFilterChip('All', allNotifications.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Unread', unreadCount),
                            const SizedBox(width: 8),
                            _buildFilterChip('Secretary Actions', null),
                            const SizedBox(width: 8),
                            _buildFilterChip('Deadlines', null),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Notification List
                      Expanded(
                        child: filteredList.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final notif = filteredList[index];
                                  return _buildNotificationCard(context, notif);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? count) {
    final isSelected = _selectedFilter == label;
    final text = count != null ? '$label ($count)' : label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF062AAE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF062AAE) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF062AAE).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You are all caught up with your corporate secretarial updates and statutory filings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notif) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case NotificationType.secretaryAction:
        icon = Icons.support_agent_rounded;
        iconColor = const Color(0xFFDC2626);
        break;
      case NotificationType.documentReview:
        icon = Icons.description_outlined;
        iconColor = const Color(0xFFD97706);
        break;
      case NotificationType.deadlineReminder:
        icon = Icons.calendar_month_outlined;
        iconColor = const Color(0xFF2563EB);
        break;
      case NotificationType.filingCompleted:
        icon = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF059669);
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        iconColor = const Color(0xFF062AAE);
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
      ),
      onDismissed: (_) {
        NotificationService.instance.deleteNotification(notif.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notif.isUnread ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isUnread ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: notif.isUnread ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Mark read
            NotificationService.instance.markAsRead(notif.id);

            // Navigate
            if (notif.relatedFilingId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SsmFilingDetailPage(filingId: notif.relatedFilingId!),
                ),
              );
            } else if (notif.routeTag == 'replies_needed') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RepliesNeededPage(),
                ),
              );
            } else if (notif.routeTag == 'document_needed') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentNeededPage(),
                ),
              );
            } else if (notif.routeTag == 'calendar') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarPage(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: GoogleFonts.poppins(
                                fontWeight: notif.isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (notif.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF062AAE),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif.time,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF062AAE),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: Color(0xFF062AAE),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
