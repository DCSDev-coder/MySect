import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../notifications/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../transactions/transactions_page.dart';
import '../transactions/submit_ssm_filing_page.dart';
import '../files/files_page.dart';
import '../chat/chat_page.dart';
import '../more/more_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../tasks/document_needed_page.dart';
import '../tasks/replies_needed_page.dart';
import '../services/company_service.dart';
import '../services/ssm_filing_service.dart';
import '../services/compliance_service.dart';
import '../widgets/app_top_header.dart';
import '../widgets/mysect_stroke_logo_loader.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  final bool initialDocsFilter;
  final bool initialReplyFilter;

  const HomePage({
    super.key,
    this.initialIndex = 0,
    this.initialDocsFilter = false,
    this.initialReplyFilter = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  final CompanyService _companyService = CompanyService.instance;
  late String _selectedCompany;
  bool _isDropdownOpen = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late bool _docsFilterForTransactions;
  late bool _replyFilterForTransactions;
  bool _isSwitchingTab = false;

  void _onTabSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _isSwitchingTab = true;
      _selectedIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isSwitchingTab = false;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _companyService.syncFromAdmin();
    await ComplianceService.instance.syncFromBackend();
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final tasks = ComplianceService.instance.getTasksForDay(day, _selectedCompany);
    if (tasks.isNotEmpty) {
      return tasks.map((t) {
        return {
          'month': DateFormat('MMM').format(t.dueDate).toUpperCase(),
          'day': t.dueDate.day.toString(),
          'title': t.title,
          'subtitle': t.subtitle.isNotEmpty ? t.subtitle : (t.instructions ?? ''),
          'timeRemaining': t.timeRemainingText,
          'pillBgColor': t.pillBgColor,
          'pillTextColor': t.pillTextColor,
          'category': t.category,
        };
      }).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _selectedDay = _focusedDay;
    _docsFilterForTransactions = widget.initialDocsFilter;
    _replyFilterForTransactions = widget.initialReplyFilter;
    _selectedCompany = _companyService.selectedCompany?.name ?? 'Data Center Specialists Sdn Bhd (M)';
    _companyService.addListener(_onCompanyServiceUpdate);
    SsmFilingService.instance.addListener(_onFilingUpdate);
    ComplianceService.instance.addListener(_onComplianceUpdate);
  }

  @override
  void dispose() {
    _companyService.removeListener(_onCompanyServiceUpdate);
    SsmFilingService.instance.removeListener(_onFilingUpdate);
    ComplianceService.instance.removeListener(_onComplianceUpdate);
    super.dispose();
  }

  void _onCompanyServiceUpdate() {
    if (mounted) {
      setState(() {
        _selectedCompany = _companyService.selectedCompany?.name ?? _selectedCompany;
      });
    }
  }

  void _onFilingUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onComplianceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  List<String> get _companies => _companyService.companyNames;

  Widget _buildTaskCard({
    required String number,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.blue.shade900),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard({
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String timeRemaining,
    Color pillBgColor = const Color(0xFFFFF7A3),
    Color pillTextColor = const Color(0xFFFF8A00),
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD71920),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        month,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: pillTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeRemaining,
                      style: GoogleFonts.poppins(
                        color: pillTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (timeRemaining.toLowerCase() != 'completed')
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'File Now',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF006D67),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF006D67),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopHeader(
            onNotificationTap: () {
              if (_selectedCompany == 'Test Enterprise') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notifications are unavailable to view.',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 2.0,
                        bottom: 6.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                              onSelected: (String newValue) {
                                setState(() {
                                  _selectedCompany = newValue;
                                  _isDropdownOpen = false;
                                });
                                _companyService.selectCompanyByName(newValue);
                              },
                              onOpened: () {
                                setState(() {
                                  _isDropdownOpen = true;
                                });
                              },
                              onCanceled: () {
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                              },
                              offset: const Offset(0, 30),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedCompany,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _isDropdownOpen ? 0.25 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              itemBuilder: (BuildContext context) {
                                return _companies.map((String value) {
                                  return PopupMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            value,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: value == 'Test Enterprise'
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (value == 'Test Enterprise')
                                          const Icon(
                                            Icons.lock,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Financial Year 2026',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _companyService.isConnectedToAdmin
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF062AAE),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _companyService.selectedCompany?.assignedFirmName ?? 'MySect Verified',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _companyService.isConnectedToAdmin
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF062AAE),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCompany == 'Test Enterprise')
                      Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/locked_icon.png',
                                height: 250,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Company Locked',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You do not have access to this company.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'UPCOMING DATELINE',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            eventLoader: _getEventsForDay,
                            calendarFormat: CalendarFormat.month,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            daysOfWeekHeight: 32.0,
                            rowHeight: 46.0,
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              weekendStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFD71920),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFEEEEEE),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD71920),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            calendarStyle: const CalendarStyle(
                              cellMargin: EdgeInsets.all(4.0),
                              selectedDecoration: BoxDecoration(
                                color: Color(0xFF062AAE),
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDay != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasks for ${DateFormat.yMMMd().format(_selectedDay!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_getEventsForDay(_selectedDay!).isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'No tasks scheduled for this day',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ..._getEventsForDay(_selectedDay!).map((event) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: _buildDeadlineCard(
                                      month: event['month'],
                                      day: event['day'],
                                      title: event['title'],
                                      subtitle: event['subtitle'],
                                      timeRemaining: event['timeRemaining'],
                                      pillBgColor:
                                          event['pillBgColor'] ??
                                          const Color(0xFFFFF7A3),
                                      pillTextColor:
                                          event['pillTextColor'] ??
                                          const Color(0xFFFF8A00),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubmitSsmFilingPage(
                                              initialTitle: event['title'],
                                              initialDescription: event['subtitle'],
                                              initialFilingType: event['title'].toString().contains('Annual Return')
                                                  ? 'Section 68 Annual Return'
                                                  : 'General Submission & Inquiry',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'REQUIRED TASKS',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTaskCard(
                        number: '1',
                        color: const Color(0xFF062AAE),
                        title: 'File That Needs to be Submitted',
                        subtitle: 'Upload files for secretary review',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubmitSsmFilingPage(),
                            ),
                          );
                        },
                      ),
                      _buildTaskCard(
                        number: '${SsmFilingService.instance.waitingSecretaryCount}',
                        color: Colors.blue.shade700,
                        title: 'Waiting for Secretary Review',
                        subtitle: 'Files sent to your secretary for review',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DocumentNeededPage(),
                            ),
                          );
                        },
                      ),
                      _buildTaskCard(
                        number: '${SsmFilingService.instance.secretaryRepliesNeededCount}',
                        color: Colors.red.shade400,
                        title: 'Secretary Replies (Action Needed)',
                        subtitle: 'Clarifications & missing docs requested',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RepliesNeededPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          'NO PENDING TASK',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _selectedCompany == 'Test Enterprise' && _selectedIndex != 0
              ? SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTopHeader(
                        onNotificationTap: () {
                          if (_selectedCompany == 'Test Enterprise') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Notifications are unavailable to view.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/locked_icon.png', height: 250),
                              const SizedBox(height: 16),
                              Text(
                                'Company Locked',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You do not have access to this company.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildHomeView(),
                    TransactionsPage(
                      initialDocumentsNeededFilter: _docsFilterForTransactions,
                      initialReplyNeededFilter: _replyFilterForTransactions,
                    ),
                    const FilesPage(),
                    const ChatPage(),
                    const MorePage(),
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
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
