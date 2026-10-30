import 'package:flutter/material.dart';

import '../services/secretary_notification_service.dart';
import '../screens/secretary_notifications_page.dart';

class AppTopHeader extends StatelessWidget {
  final bool showNotificationBell;
  final VoidCallback? onNotificationTap;
  final Widget? trailing;
  final Color? backgroundColor;

  const AppTopHeader({
    super.key,
    this.showNotificationBell = true,
    this.onNotificationTap,
    this.trailing,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final elevatedTop = topPadding > 0
        ? (topPadding - 24.0).clamp(6.0, 26.0)
        : 6.0;

    final isTransparent = backgroundColor == null || backgroundColor == Colors.transparent;

    final header = Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: elevatedTop,
        right: 16.0,
        bottom: isTransparent ? 2.0 : 4.0,
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
              animation: SecretaryNotificationService.instance,
              builder: (context, _) {
                final unreadCount =
                    SecretaryNotificationService.instance.unreadCount;
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
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed:
                      onNotificationTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SecretaryNotificationsPage(),
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

    if (!isTransparent) {
      return Container(
        color: backgroundColor,
        child: header,
      );
    }

    return header;
  }
}
