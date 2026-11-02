import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/secretary_document_service.dart';
import '../services/secretary_notification_service.dart';
import '../widgets/mysect_stroke_logo_loader.dart';
import '../widgets/secretary_sidebar.dart';
import 'client_companies_tab.dart';
import 'document_intake_queue_tab.dart';
import 'secretary_dashboard_tab.dart';
import 'secretary_notifications_page.dart';
import 'secretary_profile_tab.dart';
import 'secretary_settings_page.dart';
import 'secretary_subscription_page.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  bool _isSwitchingTab = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 5);
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex && !_isSwitchingTab) return;
    setState(() {
      _isSwitchingTab = true;
      _currentIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isSwitchingTab = false;
        });
      }
    });
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    await SecretaryDocumentService.instance.syncFromBackend();
    if (mounted) {
      setState(() => _isSyncing = false);
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

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard Overview';
      case 1:
        return 'Document Review Queue';
      case 2:
        return 'Client Companies & Portfolios';
      case 3:
        return 'Secretary Profile & Credentials';
      case 4:
        return 'Firm Settings & Security';
      case 5:
        return 'Plans & Company Quota';
      default:
        return 'Secretary Workspace';
    }
  }

  Widget _buildNotificationBell(BuildContext context) {
    return AnimatedBuilder(
      animation: SecretaryNotificationService.instance,
      builder: (context, _) {
        final unreadCount = SecretaryNotificationService.instance.unreadCount;
        return IconButton(
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
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SecretaryNotificationsPage(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withValues(alpha: 0.88),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RepeatingStrokeLogoLoader(
                width: 90,
                height: 60,
                cycleDuration: Duration(milliseconds: 750),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading...',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF062AAE),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(
    BuildContext context,
    SecretaryDocumentService service,
  ) {
    final profile = service.profile;
    final initials = profile.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(_currentIndex),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF059669),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'SSM LICENSED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF047857),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Sync Action
          OutlinedButton.icon(
            onPressed: _isSyncing ? null : _handleSync,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isSyncing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF062AAE),
                    ),
                  )
                : const Icon(
                    Icons.sync_rounded,
                    size: 16,
                    color: Color(0xFF062AAE),
                  ),
            label: Text(
              _isSyncing ? 'Syncing...' : 'Sync',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notifications
          _buildNotificationBell(context),
          const SizedBox(width: 12),
          // Profile Chip
          InkWell(
            onTap: () => _onTabSelected(3),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFF062AAE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : 'ML',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final profile = service.profile;
        final initials = profile.name
            .split(' ')
            .where((e) => e.isNotEmpty)
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join();

        final tabs = [
          SecretaryDashboardTab(
            onNavigateToQueue: () => _onTabSelected(1),
          ),
          const DocumentIntakeQueueTab(),
          const ClientCompaniesTab(),
          SecretaryProfileTab(
            onNavigateToTab: _onTabSelected,
          ),
          const SecretarySettingsPage(isEmbedded: true),
          const SecretarySubscriptionPage(isEmbedded: true),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              // Desktop & Tablet Side-by-Side Left Navigation Layout
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: SafeArea(
                  child: Row(
                    children: [
                      // Left Navigation Sidebar (Matching Admin)
                      SecretarySidebar(
                        currentIndex: _currentIndex,
                        onSelectTab: _onTabSelected,
                      ),
                      // Main Content Area
                      Expanded(
                        child: Column(
                          children: [
                            _buildDesktopTopBar(context, service),
                            Expanded(
                              child: Stack(
                                children: [
                                  IndexedStack(
                                    index: _currentIndex,
                                    children: tabs,
                                  ),
                                  if (_isSwitchingTab) _buildLoadingOverlay(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Mobile Layout with Left Navigation Drawer (No bottom bar)
            return Scaffold(
              backgroundColor: Colors.white,
              drawer: Drawer(
                width: 260,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: SafeArea(
                  child: SecretarySidebar(
                    isDrawer: true,
                    currentIndex: _currentIndex,
                    onSelectTab: (idx) {
                      Navigator.pop(context);
                      _onTabSelected(idx);
                    },
                    onCloseDrawer: () => Navigator.pop(context),
                  ),
                ),
              ),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                ),
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF1E293B),
                      size: 24,
                    ),
                    tooltip: 'Open Menu',
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                centerTitle: true,
                title: Image.asset(
                  'assets/mysect_logo.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
                actions: [
                  _buildNotificationBell(context),
                  const SizedBox(width: 4),
                  Builder(
                    builder: (ctx) => InkWell(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF062AAE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials.isNotEmpty ? initials : 'ML',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Stack(
                children: [
                  IndexedStack(
                    index: _currentIndex,
                    children: tabs,
                  ),
                  if (_isSwitchingTab) _buildLoadingOverlay(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
