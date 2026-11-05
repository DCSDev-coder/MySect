import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/secretary_document_service.dart';
import '../../models/secretary_subscription_model.dart';
import '../../widgets/secretary_desktop_top_bar.dart';

class SecretarySubscriptionPage extends StatefulWidget {
  final bool isEmbedded;

  const SecretarySubscriptionPage({super.key, this.isEmbedded = false});

  @override
  State<SecretarySubscriptionPage> createState() =>
      _SecretarySubscriptionPageState();
}

class _SecretarySubscriptionPageState extends State<SecretarySubscriptionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _paymentFilter = 'All'; // 'All', 'Paid', 'Unpaid'

  void _showCompanyReceiptDialog(BuildContext context, SsmBillingCompany comp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Retainer Official Receipt',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Entity Name', comp.name),
                  const Divider(height: 14),
                  _buildDetailRow('SSM Registration', comp.registrationNo),
                  const Divider(height: 14),
                  _buildDetailRow('Billing Cycle', 'May 2026'),
                  const Divider(height: 14),
                  _buildDetailRow('Invoice Ref', comp.invoiceNo ?? 'INV-2026-05-01'),
                  const Divider(height: 14),
                  _buildDetailRow('Payment Date', comp.paymentDate ?? '02 May 2026'),
                  const Divider(height: 14),
                  _buildDetailRow('Channel', comp.paymentMethod ?? 'FPX Online Banking'),
                  const Divider(height: 14),
                  _buildDetailRow('Amount Paid', 'MYR 50.00'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 14),
                const SizedBox(width: 4),
                Text(
                  'SSM Licensed Secretary Retainer • Verified Settlement',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF059669), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showOnboardCompanyDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final regNoController = TextEditingController();
    String entityType = 'Sdn. Bhd.';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.domain_add_rounded,
                                color: Color(0xFF062AAE),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Onboard New SSM Company',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Flat RM 50.00 / month • Unlimited Cloud Vault',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Company Legal Name',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Apex Global Logistics Sdn Bhd',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter company name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SSM Registration Number',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: regNoController,
                                    decoration: InputDecoration(
                                      hintText: '202601019842 (1600123-X)',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entity Type',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: entityType,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Sdn. Bhd.',
                                        child: Text('Sdn. Bhd.'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Bhd.',
                                        child: Text('Bhd.'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Enterprise',
                                        child: Text('Enterprise'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'LLP',
                                        child: Text('LLP'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => entityType = val);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16A34A),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Billing Impact: +RM 50.00 / month added to your next billing invoice. Instant access to full features.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF15803D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  SecretaryDocumentService.instance
                                      .onboardCompany(
                                    name: nameController.text.trim(),
                                    regNo: regNoController.text.trim(),
                                    entityType: entityType,
                                  );
                                  Navigator.pop(dialogCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${nameController.text.trim()} onboarded successfully at RM 50/mo!',
                                      ),
                                      backgroundColor: const Color(0xFF059669),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF062AAE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Confirm & Onboard (+RM 50/mo)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetails(BuildContext context, SsmBillingInvoice invoice) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNo,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Period: ${invoice.billingPeriod}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          invoice.status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  _buildDetailRow(
                    'Billed Firm',
                    'SectPro Corporate Services Sdn Bhd',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Issue Date', invoice.issueDate),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Active SSM Entities',
                    '${invoice.activeCompaniesCount} Companies',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Rate / Company', 'RM 50.00 / month'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Payment Method', invoice.paymentMethod),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid (MYR)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'RM ${invoice.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF062AAE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Downloading invoice receipt ${invoice.invoiceNo}.pdf...',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: Text(
                            'Download PDF Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = SecretaryDocumentService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final companies = service.billingCompanies.where((c) {
          final matchesSearch = _searchQuery.isEmpty ||
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.registrationNo.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesPayment = _paymentFilter == 'All' ||
              (_paymentFilter == 'Paid' && c.isPaidForMonth) ||
              (_paymentFilter == 'Unpaid' && !c.isPaidForMonth);
          return matchesSearch && matchesPayment;
        }).toList();

        final totalMonthly = service.monthlyBillingTotal;

        final bodyContent = SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header & Quick Action
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Flat RM 50.00 / month per active SSM company • Zero tiers, unlimited TM Cloud vault & statutory MBRS filing tracking.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: () => _showOnboardCompanyDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      '+ Onboard Company (+RM 50/mo)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062AAE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 1. HERO BANNER: Flat Rate Billing Architecture
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF062AAE), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF062AAE).withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF34D399),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'FLAT RATE BILLING MODEL • ACTIVE',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF34D399)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '${service.billingCompanies.length} Active SSM Companies',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Big Price Callout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'RM 50.00',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ active SSM company / month',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF93C5FD),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'No tier locks. No quota penalties. Manage 1 company or 1,000 companies at the exact same transparent flat rate.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Formula Bar & Key Pillars
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          return isNarrow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFormulaText(
                                      service.billingCompanies.length,
                                      totalMonthly,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildPillarsRow(),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildFormulaText(
                                      service.billingCompanies.length,
                                      totalMonthly,
                                    ),
                                    _buildPillarsRow(),
                                  ],
                                );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Real-time Monthly Collection Tracker
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF67E8F9)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'May 2026 Retainer Collection: RM ${service.collectedMonthlyTotal.toStringAsFixed(2)} / RM ${totalMonthly.toStringAsFixed(2)} (${service.paidCompaniesCount} of ${service.billingCompanies.length} Companies Settled)',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (service.unpaidCompaniesCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${service.unpaidCompaniesCount} Pending (RM ${service.outstandingMonthlyTotal.toStringAsFixed(2)})',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. VALUE PROPOSITION PILLARS (Included with every SSM company)
              Text(
                'Full Platform Capabilities Included (Zero Surcharges)',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final cards = [
                    _buildFeatureCard(
                      icon: Icons.cloud_done_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBg: const Color(0xFFEFF6FF),
                      title: 'Unlimited TM Cloud Vault',
                      desc:
                          'Zero storage tier gates. Every onboarded company receives complete encrypted repository space for all statutory registers & board files.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.group_add_rounded,
                      iconColor: const Color(0xFF059669),
                      iconBg: const Color(0xFFECFDF5),
                      title: 'Unlimited Team & CoSec Seats',
                      desc:
                          'Add multiple licensed secretaries, partners, and assistants without any extra per-user seat fees or licenses.',
                    ),
                    _buildFeatureCard(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFF5F3FF),
                      title: 'AI Intake & MBRS Filing Engine',
                      desc:
                          'Instant OCR categorization, resolution drafts, and automated Section 68 statutory annual return compliance monitoring.',
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[1]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[2]),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 10),
                        cards[1],
                        const SizedBox(height: 10),
                        cards[2],
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // 3. ACTIVE SSM PORTFOLIO BREAKDOWN
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Search
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Active SSM Portfolio',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${service.billingCompanies.length} Entities',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF062AAE),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Each entity billed at flat RM 50.00 / month • Retainer Total: RM ${totalMonthly.toStringAsFixed(2)} / mo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val.trim()),
                              decoration: InputDecoration(
                                hintText: 'Search company or SSM...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: Color(0xFF94A3B8),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Payment Filter Buttons Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text(
                            'Filter Retainer:',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => setState(() => _paymentFilter = 'All'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _paymentFilter == 'All' ? const Color(0xFF062AAE) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'All Entities (${service.billingCompanies.length})',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _paymentFilter == 'All' ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _paymentFilter = 'Paid'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _paymentFilter == 'Paid' ? const Color(0xFF059669) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Text(
                                '✓ Paid This Month (${service.paidCompaniesCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _paymentFilter == 'Paid' ? Colors.white : const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _paymentFilter = 'Unpaid'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _paymentFilter == 'Unpaid' ? const Color(0xFFD97706) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                '⚠️ Unpaid / Due (${service.unpaidCompaniesCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _paymentFilter == 'Unpaid' ? Colors.white : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Table Header
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'COMPANY & SSM REGISTRATION',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'DATE ONBOARDED',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'NEXT SSM DUE',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'MAY 2026 RETAINER STATUS',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ACTIONS / RECEIPT',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Table rows
                    if (companies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No matching SSM companies found.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: companies.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final c = companies[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.apartment_rounded,
                                          color: Color(0xFF062AAE),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  'SSM: ${c.registrationNo}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color:
                                                        const Color(0xFF64748B),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF1F5F9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    c.entityType,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF475569),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    c.onboardedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    c.nextFilingDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF062AAE),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: c.isPaidForMonth
                                              ? const Color(0xFFECFDF5)
                                              : const Color(0xFFFFFBEB),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: c.isPaidForMonth
                                                ? const Color(0xFFA7F3D0)
                                                : const Color(0xFFFDE68A),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              c.isPaidForMonth
                                                  ? Icons.check_circle_rounded
                                                  : Icons.warning_amber_rounded,
                                              size: 12,
                                              color: c.isPaidForMonth
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFD97706),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              c.isPaidForMonth
                                                  ? 'PAID (RM 50.00)'
                                                  : 'UNPAID (RM 50.00)',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: c.isPaidForMonth
                                                    ? const Color(0xFF065F46)
                                                    : const Color(0xFF92400E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.isPaidForMonth
                                            ? '${c.paymentDate ?? "02 May 2026"} • ${c.paymentMethod ?? "FPX"}'
                                            : 'Due ${c.dueDate ?? "07 May 2026"} • Outstanding',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: c.isPaidForMonth ? const Color(0xFF64748B) : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: c.isPaidForMonth
                                        ? OutlinedButton.icon(
                                            onPressed: () => _showCompanyReceiptDialog(context, c),
                                            icon: const Icon(Icons.receipt_rounded, size: 13),
                                            label: Text('Receipt', style: GoogleFonts.poppins(fontSize: 11)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF062AAE),
                                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  service.toggleCompanyPaymentStatus(c.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Settled May 2026 retainer for ${c.name} (RM 50.00 received)',
                                                        style: GoogleFonts.poppins(fontSize: 12),
                                                      ),
                                                      backgroundColor: const Color(0xFF059669),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF062AAE),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  elevation: 0,
                                                ),
                                                child: Text('Mark Paid', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Payment reminder dispatched to ${c.name} directors email.',
                                                        style: GoogleFonts.poppins(fontSize: 12),
                                                      ),
                                                      backgroundColor: const Color(0xFF0284C7),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.forward_to_inbox_rounded, size: 16, color: Color(0xFF64748B)),
                                                tooltip: 'Send Reminder to Director',
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Portfolio Total Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      color: const Color(0xFFF8FAFC),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Portfolio Total (${service.billingCompanies.length} Active SSM Entities)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'RM ${totalMonthly.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF062AAE),
                                ),
                              ),
                              Text(
                                ' / mo',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. BILLING STATEMENTS & INVOICES
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoices List
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Invoices & Receipts',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Billed Monthly via FPX',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: service.billingInvoices.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, i) {
                              final inv = service.billingInvoices[i];
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_rounded,
                                    color: Color(0xFF062AAE),
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  '${inv.invoiceNo} • ${inv.billingPeriod}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  '${inv.activeCompaniesCount} SSM Companies • ${inv.paymentMethod}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'RM ${inv.amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.description_outlined,
                                        size: 18,
                                        color: Color(0xFF062AAE),
                                      ),
                                      tooltip: 'View Invoice',
                                      onPressed: () =>
                                          _showInvoiceDetails(context, inv),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // Payment Method & Direct Debit Details
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: Color(0xFFD97706),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Payment Method',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Maybank Corporate Direct Debit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Account: •••• 8820 (FPX Autodebit)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: Verified & Auto-Reconciled',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF059669),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Billing Cycle Details',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Next billing deduction: 01 June 2026\n• Total active companies: ${service.billingCompanies.length}\n• Monthly amount: RM ${totalMonthly.toStringAsFixed(2)}\n• Tax Invoice delivered directly to email',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
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

        if (widget.isEmbedded) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: bodyContent,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                body: Column(
                  children: [
                    SecretaryDesktopTopBar(
                      title: 'Company Billing & SSM Portfolio',
                      badgeText: 'SSM LICENSED',
                      isSyncing: service.isSyncing,
                      onSync: () => service.syncFromBackend(),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        tooltip: 'Back to Workspace',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(child: bodyContent),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: Text(
                  'Company Billing',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: bodyContent,
            );
          },
        );
      },
    );
  }

  Widget _buildFormulaText(int count, double total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calculate_outlined, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          '$count Active Entities × RM 50.00 = RM ${total.toStringAsFixed(2)} / month',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPillarsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPillarChip('Unlimited TM Cloud Vault'),
        const SizedBox(width: 6),
        _buildPillarChip('Unlimited Staff Seats'),
        const SizedBox(width: 6),
        _buildPillarChip('Full MBRS Engine'),
      ],
    );
  }

  Widget _buildPillarChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
