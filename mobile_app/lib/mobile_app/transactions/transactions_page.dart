import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';
  String _selectedBank = 'Maybank';
  bool _isBankDropdownOpen = false;

  final List<Map<String, String>> _banks = [
    {'name': 'Maybank', 'icon': 'assets/maybank.png'},
    {'name': 'Public Bank', 'icon': 'assets/publicbank.gif'},
    {'name': 'CIMB Bank', 'icon': 'assets/cimb.png'},
  ];

  String _getBankIcon(String name) {
    return _banks.firstWhere(
      (b) => b['name'] == name,
      orElse: () => _banks.first,
    )['icon']!;
  }

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'DEBIT PURCHASE USD',
      'subtitle': 'Shopify',
      'amount': '-RM1.06',
      'account': 'OCBC SGD-9001',
      'type': 'Expenses',
    },
    {
      'title': 'DEBIT PURCHASE USD',
      'subtitle': 'Shopify',
      'amount': '-RM1.06',
      'account': 'OCBC SGD-9001',
      'type': 'Expenses',
    },
    {
      'title': 'CLIENT PAYMENT',
      'subtitle': 'Mira',
      'amount': '+RM150.00',
      'account': 'OCBC SGD-9001',
      'type': 'Income',
    },
    {
      'title': 'DEBIT PURCHASE USD',
      'subtitle': 'Shopify',
      'amount': '-RM1.06',
      'account': 'OCBC SGD-9001',
      'type': 'Expenses',
    },
    {
      'title': 'INVOICE #1029',
      'subtitle': 'Tech Corp',
      'amount': '+RM2,400.00',
      'account': 'Maybank MYR-1002',
      'type': 'Income',
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _allTransactions;
    return _allTransactions.where((t) => t['type'] == _selectedFilter).toList();
  }

  Widget _buildFilterButton(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.download_rounded,
                color: Colors.blue.shade700,
                size: 24,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloading receipt...', style: GoogleFonts.poppins()),
                    backgroundColor: const Color(0xFF062AAE),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Text(
                  transaction['subtitle'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                transaction['account'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Standard App Header (Logo + Notification)
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
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: Colors.black),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Advanced filters coming soon', style: GoogleFonts.poppins()),
                                  backgroundColor: const Color(0xFF062AAE),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'TOTAL EXPENSES',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM 128,450.00',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'TOTAL INCOME',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM 128,450.00',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: PopupMenuButton<String>(
                              onSelected: (String newValue) {
                                setState(() {
                                  _selectedBank = newValue;
                                  _isBankDropdownOpen = false;
                                });
                              },
                              onOpened: () {
                                setState(() {
                                  _isBankDropdownOpen = true;
                                });
                              },
                              onCanceled: () {
                                setState(() {
                                  _isBankDropdownOpen = false;
                                });
                              },
                              offset: const Offset(0, 50),
                              child: Row(
                                children: [
                                  AnimatedRotation(
                                    turns: _isBankDropdownOpen ? 0.25 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.expand_more,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ClipOval(
                                    child: Image.asset(
                                      _getBankIcon(_selectedBank),
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedBank,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              itemBuilder: (BuildContext context) {
                                return _banks.map((Map<String, String> bank) {
                                  String value = bank['name']!;
                                  return PopupMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Image.asset(
                                            bank['icon']!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(child: _buildFilterButton('All')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildFilterButton('Income')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildFilterButton('Expenses')),
                            ],
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'RECENT TRANSACTIONS',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ..._filteredTransactions.map(
                            (t) => _buildTransactionCard(context, t),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
