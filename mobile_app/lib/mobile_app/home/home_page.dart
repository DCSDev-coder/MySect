import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../notifications/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../transactions/transactions_page.dart';
import '../files/files_page.dart';
import '../chat/chat_page.dart';
import '../more/more_page.dart';
import '../tasks/document_needed_page.dart';
import '../tasks/replies_needed_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  String _selectedCompany = 'Data Center Specialists Sdn Bhd (M)';
  bool _isDropdownOpen = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    if (day.day == 3) {
      return [
        {
          'month': DateFormat('MMM').format(day).toUpperCase(),
          'day': day.day.toString(),
          'title': 'Complete Tax Return (C/C-s)',
          'subtitle': 'Filling to IRAS for the year\nending 2025',
          'timeRemaining': 'In 18 days',
          'pillBgColor': const Color(0xFFFFF7A3),
          'pillTextColor': const Color(0xFFFF8A00),
        },
        {
          'month': DateFormat('MMM').format(day).toUpperCase(),
          'day': day.day.toString(),
          'title': 'Annual Return Submission',
          'subtitle': 'Filing to ACRA for the year\nending 2024',
          'timeRemaining': 'In 33 days',
          'pillBgColor': const Color(0xFFE8F5E9),
          'pillTextColor': const Color(0xFF2E7D32),
        },
      ];
    } else if (day.day == 15) {
      return [
        {
          'month': DateFormat('MMM').format(day).toUpperCase(),
          'day': day.day.toString(),
          'title': 'Q3 GST Return',
          'subtitle': 'Filing to IRAS for Q3 2024',
          'timeRemaining': 'Completed',
          'pillBgColor': Colors.grey.shade200,
          'pillTextColor': Colors.grey.shade700,
        },
      ];
    } else if (day.day == 31) {
      return [
        {
          'month': DateFormat('MMM').format(day).toUpperCase(),
          'day': day.day.toString(),
          'title': 'Q4 GST Return',
          'subtitle': 'Filing to IRAS for Q4 2024',
          'timeRemaining': 'In 80 days',
          'pillBgColor': const Color(0xFFE3F2FD),
          'pillTextColor': const Color(0xFF1565C0),
        },
      ];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _selectedDay = _focusedDay;
  }

  final List<String> _companies = [
    'Data Center Specialists Sdn Bhd (M)',
    'C2 Coffee + Candle',
    '5Luxe Scents Co.',
  ];

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
          border: Border.all(color: Colors.grey.shade300),
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Date Icon
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
                        color: Color(0xFFD71920), // Red header
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
              // Text Details
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
              // Pill
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
              // File Now ->
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
                            color: const Color(0xFF006D67), // Teal
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/YourSectComp.png',
                  width: 110,
                  fit: BoxFit.contain,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
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
                        PopupMenuButton<String>(
                          onSelected: (String newValue) {
                            setState(() {
                              _selectedCompany = newValue;
                              _isDropdownOpen = false;
                            });
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
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Financial Year 2026',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        calendarStyle: const CalendarStyle(
                          markersMaxCount: 1,
                          markerDecoration: BoxDecoration(
                            color: Color(0xFFD71920),
                            shape: BoxShape.circle,
                          ),
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
                                padding: const EdgeInsets.only(bottom: 16.0),
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
                                        builder: (context) =>
                                            const DocumentNeededPage(),
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
                    number: '4',
                    color: Colors.blue.shade700,
                    title: 'Document Needed',
                    subtitle: 'Actions required to file returns',
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
                    number: '4',
                    color: Colors.red.shade400,
                    title: 'Replies Needed',
                    subtitle: 'Clarifications with secretary',
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF062AAE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF062AAE) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF062AAE) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeView(),
          const TransactionsPage(),
          const FilesPage(),
          const ChatPage(),
          const MorePage(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: .05),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(
                1,
                Icons.swap_horiz,
                Icons.swap_horiz,
                'Transactions',
              ),
              _buildNavItem(2, Icons.folder_outlined, Icons.folder, 'Files'),
              _buildNavItem(
                3,
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                'Chat',
              ),
              _buildNavItem(4, Icons.more_horiz, Icons.more_horiz, 'More'),
            ],
          ),
        ),
      ),
    );
  }
}
