import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import '../services/notification_service.dart';

/// Standardized top header with the MySect logo and notification bell.
/// Positioned higher up (closer to the status bar / camera cutout) uniformly across all pages.
class AppTopHeader extends StatelessWidget {
  final bool showNotificationBell;
  final VoidCallback? onNotificationTap;
  final Widget? trailing;

  const AppTopHeader({
    super.key,
    this.showNotificationBell = true,
    this.onNotificationTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    // Elevates the logo and notification bell higher up closer to the status bar text/pill
    // Leave clear space for top speaker, camera notch/island, and status bar
    final elevatedTop = topPadding > 20 ? (topPadding + 10.0) : 38.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: elevatedTop,
        right: 16.0,
        bottom: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/mysect_logo.png',
            width: 105,
            fit: BoxFit.contain,
          ),
          if (trailing != null)
            trailing!
          else if (showNotificationBell)
            AnimatedBuilder(
              animation: NotificationService.instance,
              builder: (context, _) {
                final unreadCount = NotificationService.instance.unreadCount;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.black87,
                        size: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: onNotificationTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
                );
              },
            )
          else
            const SizedBox(width: 24, height: 24),
        ],
      ),
    );
  }
}