import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/notifications/secretary_notifications_page.dart';
import '../screens/review_queue/document_review_detail_page.dart';
import '../services/secretary_document_service.dart';
import '../services/secretary_notification_service.dart';

class SecretaryDesktopTopBar extends StatefulWidget {
  final String title;
  final Widget? leading;
  final bool showBadge;
  final String badgeText;
  final VoidCallback? onSync;
  final bool isSyncing;
  final VoidCallback? onProfileTap;

  const SecretaryDesktopTopBar({
    super.key,
    required this.title,
    this.leading,
    this.showBadge = false,
    this.badgeText = '',
    this.onSync,
    this.isSyncing = false,
    this.onProfileTap,
  });

  @override
  State<SecretaryDesktopTopBar> createState() => _SecretaryDesktopTopBarState();
}

class _SecretaryDesktopTopBarState extends State<SecretaryDesktopTopBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _rotationController;
  bool _localSyncing = false;

  AnimationController get _effectiveRotationController {
    return _rotationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isSyncing) {
      _rotationController!.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SecretaryDesktopTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ctrl = _rotationController;
    if (ctrl != null) {
      if (widget.isSyncing && !ctrl.isAnimating) {
        ctrl.repeat();
      } else if (!widget.isSyncing && oldWidget.isSyncing && !_localSyncing) {
        ctrl.stop();
        ctrl.reset();
      }
    }
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    super.dispose();
  }

  Future<void> _triggerSync() async {
    if (_localSyncing || widget.isSyncing) return;

    _effectiveRotationController.repeat();

    if (widget.onSync != null) {
      widget.onSync!();
      return;
    }
    setState(() => _localSyncing = true);
    await SecretaryDocumentService.instance.syncFromBackend();
    if (mounted) {
      setState(() => _localSyncing = false);
      _rotationController?.stop();
      _rotationController?.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synced latest SSM filings & client documents.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF062AAE),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNotificationDropdown(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.08),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 16),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 390,
                  constraints: const BoxConstraints(maxHeight: 520),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildNotificationDropdownContent(dialogContext),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationDropdownContent(BuildContext dialogContext) {
    final notifService = SecretaryNotificationService.instance;

    return AnimatedBuilder(
      animation: notifService,
      builder: (context, _) {
        final notifications = notifService.notifications;
        final unreadCount = notifService.unreadCount;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown Header (Chrome/Google account style)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF062AAE),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        '$unreadCount New',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => notifService.markAllAsRead(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF062AAE),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
            ),

            // Notification Items List
            Flexible(
              child: notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When clients submit SSM returns or statutory filings, alerts will show here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF8FAFC),
                      ),
                      itemBuilder: (ctx, index) {
                        final n = notifications[index];
                        final isUnread = !n.isRead;

                        Color iconColor = const Color(0xFF062AAE);
                        Color iconBg = const Color(0xFFEFF6FF);
                        IconData iconData = Icons.description_outlined;

                        if (n.category == 'Clarification') {
                          iconColor = const Color(0xFFD97706);
                          iconBg = const Color(0xFFFEF3C7);
                          iconData = Icons.chat_bubble_outline_rounded;
                        } else if (n.category == 'Deadline') {
                          iconColor = const Color(0xFFDC2626);
                          iconBg = const Color(0xFFFEE2E2);
                          iconData = Icons.warning_amber_rounded;
                        } else if (n.category == 'Retainer' || n.category == 'Payment') {
                          iconColor = const Color(0xFF059669);
                          iconBg = const Color(0xFFECFDF5);
                          iconData = Icons.check_circle_outline_rounded;
                        }

                        return InkWell(
                          onTap: () {
                            notifService.markAsRead(n.id);
                            Navigator.pop(dialogContext);

                            if (n.documentId != null) {
                              final docService = SecretaryDocumentService.instance;
                              final doc = docService.documents.firstWhere(
                                (d) => d.id == n.documentId,
                                orElse: () => docService.documents.first,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocumentReviewDetailPage(document: doc),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecretaryNotificationsPage(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            color: isUnread
                                ? const Color(0xFFF8FAFC)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(iconData, color: iconColor, size: 17),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: isUnread
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isUnread) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF062AAE),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        n.body,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B),
                                          height: 1.35,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.timestamp,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Dropdown Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SecretaryNotificationsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View All Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF062AAE),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF062AAE),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSyncing = widget.isSyncing || _localSyncing;

    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Leading Button (if any) + Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          // Right: Sync Button + Notification Bell (Flush to far end right)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isSyncing ? null : _triggerSync,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSyncing
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: _effectiveRotationController,
                          child: const Icon(
                            Icons.sync_rounded,
                            size: 16,
                            color: Color(0xFF062AAE),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sync',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Notifications Bell with Dropdown
              AnimatedBuilder(
                animation: SecretaryNotificationService.instance,
                builder: (context, _) {
                  final unreadCount =
                      SecretaryNotificationService.instance.unreadCount;
                  return IconButton(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Notifications',
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF1E293B),
                          size: 22,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => _showNotificationDropdown(context),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
