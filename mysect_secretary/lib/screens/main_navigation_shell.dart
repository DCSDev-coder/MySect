import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/secretary_document_service.dart';
import '../widgets/app_top_header.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/mysect_stroke_logo_loader.dart';
import 'secretary_dashboard_tab.dart';
import 'document_intake_queue_tab.dart';
import 'client_companies_tab.dart';
import 'secretary_profile_tab.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  bool _isSwitchingTab = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex && !_isSwitchingTab) return;
    setState(() {
      _isSwitchingTab = true;
      _currentIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isSwitchingTab = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
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
                              index: _currentIndex,
                              children: [
                                SecretaryDashboardTab(
                                  onNavigateToQueue: () => _onTabSelected(1),
                                ),
                                const DocumentIntakeQueueTab(),
                                const ClientCompaniesTab(),
                                const SecretaryProfileTab(),
                              ],
                            ),
                            if (_isSwitchingTab)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.90),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const RepeatingStrokeLogoLoader(
                                          width: 90,
                                          height: 60,
                                          cycleDuration: Duration(
                                            milliseconds: 750,
                                          ),
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
                              ),
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
                currentIndex: _currentIndex,
                onTap: _onTabSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}
