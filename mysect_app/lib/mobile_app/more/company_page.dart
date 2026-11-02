import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/company_service.dart';
import 'calendar_page.dart';
import 'company_shares_page.dart';
import 'company_documents_page.dart';
import '../widgets/app_top_header.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final int _selectedIndex = 4;
  final CompanyService _companyService = CompanyService.instance;

  @override
  void initState() {
    super.initState();
    _companyService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _companyService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$label copied to clipboard!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final company = _companyService.selectedCompany;

    if (company == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(),

            const SizedBox(height: 12),

            // Header with back button & Sync button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Company',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await _companyService.syncFromAdmin();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _companyService.isConnectedToAdmin
                                  ? 'Synchronized with MySect Admin Console!'
                                  : 'Synced with platform company records.',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: const Color(0xFF062AAE),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _companyService.isConnectedToAdmin
                            ? const Color(0xFFD1FAE5)
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _companyService.isConnectedToAdmin
                              ? const Color(0xFFA7F3D0)
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync,
                            size: 14,
                            color: _companyService.isConnectedToAdmin
                                ? const Color(0xFF065F46)
                                : const Color(0xFF062AAE),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _companyService.isConnectedToAdmin ? 'Admin Synced' : 'Sync',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _companyService.isConnectedToAdmin
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF062AAE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _companyService.syncFromAdmin(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Secretary Firm & Admin Connection Custody Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF062AAE), Color(0xFF0B38D0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF062AAE).withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
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
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.verified_user_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'APPOINTED SECRETARY FIRM',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF34D399), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF34D399),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Connected',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              company.assignedFirmName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Licensed Secretary: ${company.assignedSecretary} • ${company.assignedSecretaryLicense}',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.hub_outlined, color: Colors.white70, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Admin Website Platform: Active',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'SLA: 98.4%',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF34D399),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quick Links
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildQuickLinkItem(
                              icon: Icons.calendar_today_outlined,
                              title: 'Calendar & Statutory Deadlines',
                              subtitle: 'Next: S.68 Annual Return (${company.annualReturnDeadline})',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CalendarPage(),
                                  ),
                                );
                              },
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildQuickLinkItem(
                              icon: Icons.pie_chart_outline,
                              title: 'Shares & Capital',
                              subtitle: '${company.shareholders.length} Shareholders • ${company.paidUpCapital}',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CompanySharesPage(),
                                  ),
                                );
                              },
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildQuickLinkItem(
                              icon: Icons.folder_outlined,
                              title: 'Statutory Documents',
                              subtitle: '${company.statutoryDocuments.length} Verified SSM Records',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CompanyDocumentsPage(),
                                  ),
                                );
                              },
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildQuickLinkItem(
                              icon: Icons.verified_user_outlined,
                              title: 'Secretarial Retainer & Plan',
                              subtitle: '${company.subscriptionPlan} • Expires ${company.formattedSubscriptionExpiry}' + (company.isSubscriptionExpired ? ' (EXPIRED)' : ''),
                              onTap: () => _showRetainerDetailsModal(context, company),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Company Constitution Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Color(0xFF062AAE),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Company Constitution (M&AA)',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Downloading Constitution for ${company.name}...',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: const Color(0xFF062AAE),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.file_download_outlined,
                                          color: Color(0xFF062AAE),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Download PDF (Verified)',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF062AAE),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'STATUTORY COMPANY DETAILS',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildDetailItem(
                              label: 'Company name',
                              value: company.name,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'SSM Registration No.',
                              value: company.ssmNo,
                              infoText:
                                  'Suruhanjaya Syarikat Malaysia (SSM) 12-digit registration and legacy check-digit.',
                              isCopyable: true,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'Company Type',
                              value: company.type,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'Paid-Up Share Capital',
                              value: company.paidUpCapital,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'Incorporation Date',
                              value: company.incorporationDate,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'Official Email for Documents',
                              value: company.officialEmail,
                              infoText:
                                  'Dedicated statutory contact email linked to your company on the MySect Admin Platform.',
                              isCopyable: true,
                            ),
                            Divider(color: Colors.grey.shade200, height: 1),
                            _buildDetailItem(
                              label: 'Registered Office Address',
                              value: company.registeredAddress,
                              isCopyable: true,
                            ),
                            if (company.businessAddress.isNotEmpty) ...[
                              Divider(color: Colors.grey.shade200, height: 1),
                              _buildDetailItem(
                                label: 'Principal Place of Business',
                                value: company.businessAddress,
                                isCopyable: true,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }


  void _showRetainerDetailsModal(BuildContext context, Company comp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isExpired = comp.isSubscriptionExpired;
        final isExpiringSoon = comp.isSubscriptionExpiringSoon;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isExpired ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isExpired ? Icons.cancel_schedule_send_rounded : Icons.verified_user_rounded,
                      color: isExpired ? const Color(0xFFDC2626) : const Color(0xFF062AAE),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secretarial Retainer & Billing',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          comp.subscriptionPlan,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isExpired ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isExpired ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Expiry Date:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        Text(
                          comp.formattedSubscriptionExpiry,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isExpired ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Coverage Status:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isExpired ? 'EXPIRED' : (isExpiringSoon ? 'DUE SOON' : 'ACTIVE'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isExpired ? const Color(0xFFDC2626) : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Appointed Secretary:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        Text(comp.assignedSecretary, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Important Notice: Appointed secretaries only handle statutory filings, annual returns, and document reviews for companies with an active monthly retainer. Once expired, services are suspended.',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF92400E), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062AAE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    CompanyService.instance.renewSubscription(comp.id, additionalMonths: 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Monthly retainer renewed for ${comp.name}!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: Text('Pay Monthly Retainer (RM 100.00)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickLinkItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF062AAE), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    String? infoText,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (infoText != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                              content: Text(infoText, style: GoogleFonts.poppins(fontSize: 14)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 15,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCopyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF062AAE)),
              onPressed: () => _copyToClipboard(value, label),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
