import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/secretary_notification_service.dart';
import '../screens/notifications/secretary_notifications_page.dart';

class AppTopHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? badge;
  final bool showNotificationBell;
  final VoidCallback? onNotificationTap;
  final Widget? trailing;
  final Color? backgroundColor;

  const AppTopHeader({
    super.key,
    this.title,
    this.subtitle,
    this.badge,
    this.showNotificationBell = true,
    this.onNotificationTap,
    this.trailing,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final elevatedTop = topPadding > 20 ? (topPadding + 6.0) : 34.0;
    final isTransparent = backgroundColor == null || backgroundColor == Colors.transparent;

    final header = Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: elevatedTop,
        right: 16.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Brand Logo & Notification Bell (Always present)
          Row(
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
                      onPressed: onNotificationTap ??
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

          // Row 2: Page Title & Badge (When navigating subtabs)
          if (title != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  badge!,
                ],
              ],
            ),
          ],
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
