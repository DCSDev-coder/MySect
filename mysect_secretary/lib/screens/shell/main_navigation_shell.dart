import '../../widgets/secretary_desktop_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/secretary_document_service.dart';
import '../../widgets/app_top_header.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/mysect_stroke_logo_loader.dart';
import '../../widgets/secretary_sidebar.dart';
import '../companies/client_companies_tab.dart';
import '../review_queue/document_intake_queue_tab.dart';
import '../dashboard/secretary_dashboard_tab.dart';
import '../profile/secretary_profile_tab.dart';
import '../settings/secretary_settings_page.dart';
import '../settings/secretary_subscription_page.dart';

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
        return 'Company Documents & Vaults';
      case 3:
        return 'Secretary Profile & Credentials';
      case 4:
        return 'Firm Settings & Security';
      case 5:
        return 'Company Billing & SSM Portfolio';
      default:
        return 'Secretary Workspace';
    }
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
    return SecretaryDesktopTopBar(
      title: _getPageTitle(_currentIndex),
      badgeText: 'SSM LICENSED',
      isSyncing: _isSyncing,
      onSync: _handleSync,
      onProfileTap: () => _onTabSelected(3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            final tabs = [
              SecretaryDashboardTab(
                onNavigateToQueue: () => _onTabSelected(1),
                onNavigateToCompanies: () => _onTabSelected(2),
                onNavigateToSubscription: () {
                  if (isDesktop) {
                    _onTabSelected(5);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecretarySubscriptionPage(),
                      ),
                    );
                  }
                },
              ),
              const DocumentIntakeQueueTab(),
              const ClientCompaniesTab(),
              SecretaryProfileTab(
                onNavigateToTab: (idx) {
                  if (isDesktop) {
                    _onTabSelected(idx);
                  } else {
                    if (idx == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecretarySettingsPage(),
                        ),
                      );
                    } else if (idx == 5) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecretarySubscriptionPage(),
                        ),
                      );
                    } else {
                      _onTabSelected(idx);
                    }
                  }
                },
              ),
              const SecretarySettingsPage(isEmbedded: true),
              const SecretarySubscriptionPage(isEmbedded: true),
            ];

            if (isDesktop) {
              // Desktop & Tablet: Left Sidebar Navigation (Matching Admin)
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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

            // Mobile Layout: Kept as before (AppTopHeader + CustomBottomNavBar)
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                top: true,
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: Column(
                      children: [
                        const AppTopHeader(),
                        Expanded(
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: Stack(
                              children: [
                                IndexedStack(
                                  index: _currentIndex >= 4 ? 3 : _currentIndex,
                                  children: tabs,
                                ),
                                if (_isSwitchingTab) _buildLoadingOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Center(
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: CustomBottomNavBar(
                    currentIndex: _currentIndex >= 4 ? 3 : _currentIndex,
                    onTap: _onTabSelected,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
