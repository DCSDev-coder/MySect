import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';

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
    final elevatedTop = topPadding > 0 ? (topPadding - 24.0).clamp(6.0, 26.0) : 6.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: elevatedTop,
        right: 16.0,
        bottom: 2.0,
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
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
                size: 24,
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
            )
          else
            const SizedBox(width: 24, height: 24),
        ],
      ),
    );
  }
}