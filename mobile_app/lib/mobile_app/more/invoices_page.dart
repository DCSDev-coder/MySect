import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import '../home/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_invoice_page.dart';
import 'payment_methods_page.dart';
import 'customers_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final int _selectedIndex = 4;
  String _selectedFilter = 'Due Date';
  DateTime? _selectedDueDate;
  DateTime? _selectedIssuedDate;
  String? _selectedStatus;

  Widget _buildFilterButton(String title) {
    bool isSelected = _selectedFilter == title;
    
    String displayText = title;
    bool hasValue = false;
    if (title == 'Due Date' && _selectedDueDate != null) {
      displayText = 'Due: ${_selectedDueDate!.toIso8601String().split('T')[0]}';
      hasValue = true;
    } else if (title == 'Issued' && _selectedIssuedDate != null) {
      displayText = 'Issued: ${_selectedIssuedDate!.toIso8601String().split('T')[0]}';
      hasValue = true;
    } else if (title == 'Status' && _selectedStatus != null) {
      displayText = 'Status: $_selectedStatus';
      hasValue = true;
    }

    Widget pillContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayText,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        if (hasValue && title != 'Status') ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                if (title == 'Due Date') _selectedDueDate = null;
                if (title == 'Issued') _selectedIssuedDate = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ],
        if (title == 'Status') ...[
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ],
      ],
    );

    Widget container = Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF062AAE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: pillContent,
    );

    if (title == 'Status') {
      return PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            _selectedFilter = title;
            if (value == 'Clear') {
              _selectedStatus = null;
            } else {
              _selectedStatus = value;
            }
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'All', child: Text('All', style: GoogleFonts.poppins())),
          PopupMenuItem(value: 'Paid', child: Text('Paid', style: GoogleFonts.poppins())),
          PopupMenuItem(value: 'Unpaid', child: Text('Unpaid', style: GoogleFonts.poppins())),
          PopupMenuItem(value: 'Draft', child: Text('Draft', style: GoogleFonts.poppins())),
          if (_selectedStatus != null)
            PopupMenuItem(value: 'Clear', child: Text('Clear', style: GoogleFonts.poppins(color: Colors.red))),
        ],
        child: container,
      );
    }

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedFilter = title;
        });

        if (title == 'Due Date' || title == 'Issued') {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() {
              if (title == 'Due Date') {
                _selectedDueDate = picked;
              } else {
                _selectedIssuedDate = picked;
              }
            });
          }
        }
      },
      child: container,
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/YourSectComp.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 28,
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Invoices',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              'Manage',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF062AAE),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onSelected: (value) {
                            if (value == 'Payment Methods') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentMethodsPage(),
                                ),
                              );
                            } else if (value == 'Customers') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomersPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Manage $value coming soon', style: GoogleFonts.poppins()),
                                  backgroundColor: const Color(0xFF062AAE),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'Payment Methods', child: Text('Payment Methods', style: GoogleFonts.poppins())),
                            PopupMenuItem(value: 'Customers', child: Text('Customers', style: GoogleFonts.poppins())),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterButton('Due Date'),
                          const SizedBox(width: 8),
                          _buildFilterButton('Issued'),
                          const SizedBox(width: 8),
                          _buildFilterButton('Status'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Image.asset(
                      'assets/invoices page.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'Create and send professional\ninvoices in minutes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Get paid faster with Mysect invoices',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateInvoicePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF062AAE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Create invoice',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
