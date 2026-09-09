import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import '../home/home_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_invoice_page.dart';
import 'payment_methods_page.dart';
import 'customers_page.dart';
import '../files/document_viewer_page.dart';

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
  String _selectedCurrency = 'MYR';



  final List<Map<String, dynamic>> _invoices = [
    {'no': '#INV-2026-001', 'customer': 'Data Center Specialists Sdn Bhd (M)', 'date': '09 Sep 2026', 'amount': 1250.00, 'status': 'Paid', 'color': Colors.green.shade700, 'bg': Colors.green.shade50},
    {'no': '#INV-2026-002', 'customer': 'C2 Coffee + Candle', 'date': '08 Sep 2026', 'amount': 850.50, 'status': 'Unpaid', 'color': Colors.red.shade700, 'bg': Colors.red.shade50},
    {'no': '#INV-2026-003', 'customer': '5Luxe Scents Co.', 'date': '05 Sep 2026', 'amount': 2400.00, 'status': 'Draft', 'color': Colors.grey.shade700, 'bg': Colors.grey.shade100},
    {'no': '#INV-2026-004', 'customer': 'Data Center Specialists Sdn Bhd (M)', 'date': '01 Sep 2026', 'amount': 15000.00, 'status': 'Paid', 'color': Colors.green.shade700, 'bg': Colors.green.shade50},
    {'no': '#INV-2026-005', 'customer': 'C2 Coffee + Candle', 'date': '28 Aug 2026', 'amount': 4200.00, 'status': 'Unpaid', 'color': Colors.red.shade700, 'bg': Colors.red.shade50},
  ];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }


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
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.2,
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
              size: 14,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ],
        if (title == 'Status') ...[
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ],
      ],
    );

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF062AAE) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isSelected ? Border.all(color: const Color(0xFF062AAE)) : Border.all(color: Colors.grey.shade300),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Container(
        height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
          isDense: true,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    ),
  );
}

  String _getConvertedAmount(double amountSGD) {
    if (_selectedCurrency == 'SGD') {
      return 'S\$${_formatValue(amountSGD)}';
    } else if (_selectedCurrency == 'MYR') {
      return 'RM${_formatValue(amountSGD * 3.45)}';
    } else if (_selectedCurrency == 'USD') {
      return 'US\$${_formatValue(amountSGD * 0.75)}';
    }
    return '';
  }

  String _formatValue(double val) {
    String fixed = val.toStringAsFixed(2);
    List<String> parts = fixed.split('.');
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    parts[0] = parts[0].replaceAllMapped(reg, mathFunc);
    return parts.join('.');
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  Widget _buildInvoiceCard(String invoiceNo, String customer, String date, double amountSGD, String status, Color statusColor, Color bgColor) {
    String amount = _getConvertedAmount(amountSGD);
    return Dismissible(
      key: Key(invoiceNo),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _invoices.removeWhere((i) => i['no'] == invoiceNo);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invoice $invoiceNo deleted'),
          duration: const Duration(seconds: 2),
        ));
      },
      child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerPage(fileName: 'Invoice $invoiceNo'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      invoiceNo,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'delete') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invoice $invoiceNo deleted', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF062AAE),
                ),
              ),
            ],
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/mysect_logo.png',
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

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
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
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterButton('Due Date'),
                          const SizedBox(width: 8),
                          _buildFilterButton('Issued'),
                          const SizedBox(width: 8),
                          _buildFilterButton('Status'),
                          const SizedBox(width: 8),
                          _buildDropdown(
                            value: _selectedCurrency,
                            items: ['SGD', 'MYR', 'USD'],
                            onChanged: (v) => setState(() => _selectedCurrency = v!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        children: [
                          if (_invoices.isEmpty) ...[
                            const SizedBox(height: 40),
                            Image.asset(
                              'assets/transation_money.png',
                              height: 170,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.receipt_long,
                                size: 120,
                                color: const Color(0xFF1E3A8A).withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Invoices Found',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a new invoice to get started.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateInvoicePage()));
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Create Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF062AAE),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            ..._invoices.map((inv) => _buildInvoiceCard(
                                  inv['no'],
                                  inv['customer'],
                                  inv['date'],
                                  inv['amount'],
                                  inv['status'],
                                  inv['color'],
                                  inv['bg'],
                                )),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
              ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvoicePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF062AAE),
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.receipt_long, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
