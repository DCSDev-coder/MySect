class SsmBillingCompany {
  final String id;
  final String name;
  final String registrationNo;
  final String entityType;
  final double monthlyFee;
  final String onboardedDate;
  final String nextFilingDate;
  final String status;
  final int vaultFilesCount;
  final bool isPaidForMonth;
  final String currentMonth;
  final String? paymentDate;
  final String? paymentMethod;
  final String? invoiceNo;
  final String? dueDate;

  const SsmBillingCompany({
    required this.id,
    required this.name,
    required this.registrationNo,
    required this.entityType,
    this.monthlyFee = 50.00,
    required this.onboardedDate,
    required this.nextFilingDate,
    this.status = 'Active',
    this.vaultFilesCount = 0,
    this.isPaidForMonth = true,
    this.currentMonth = 'May 2026',
    this.paymentDate,
    this.paymentMethod,
    this.invoiceNo,
    this.dueDate,
  });

  SsmBillingCompany copyWith({
    String? id,
    String? name,
    String? registrationNo,
    String? entityType,
    double? monthlyFee,
    String? onboardedDate,
    String? nextFilingDate,
    String? status,
    int? vaultFilesCount,
    bool? isPaidForMonth,
    String? currentMonth,
    String? paymentDate,
    String? paymentMethod,
    String? invoiceNo,
    String? dueDate,
  }) {
    return SsmBillingCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNo: registrationNo ?? this.registrationNo,
      entityType: entityType ?? this.entityType,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      onboardedDate: onboardedDate ?? this.onboardedDate,
      nextFilingDate: nextFilingDate ?? this.nextFilingDate,
      status: status ?? this.status,
      vaultFilesCount: vaultFilesCount ?? this.vaultFilesCount,
      isPaidForMonth: isPaidForMonth ?? this.isPaidForMonth,
      currentMonth: currentMonth ?? this.currentMonth,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  static List<SsmBillingCompany> defaultCompanies() {
    return const [
      SsmBillingCompany(
        id: 'CO-01',
        name: 'Data Center Specialists Sdn Bhd (M)',
        registrationNo: '202401048291 (1584135-V)',
        entityType: 'Sdn. Bhd.',
        monthlyFee: 50.00,
        onboardedDate: '15 Jan 2024',
        nextFilingDate: '30 Jun 2026',
        status: 'Active',
        vaultFilesCount: 8,
        isPaidForMonth: true,
        currentMonth: 'May 2026',
        paymentDate: '02 May 2026',
        paymentMethod: 'FPX (Maybank2u)',
        invoiceNo: 'INV-2026-05-01',
      ),
      SsmBillingCompany(
        id: 'CO-02',
        name: 'C2 Coffee + Candle',
        registrationNo: '202301019283 (1521402-A)',
        entityType: 'Sdn. Bhd.',
        monthlyFee: 50.00,
        onboardedDate: '04 Mar 2024',
        nextFilingDate: '15 Jul 2026',
        status: 'Active',
        vaultFilesCount: 5,
        isPaidForMonth: true,
        currentMonth: 'May 2026',
        paymentDate: '03 May 2026',
        paymentMethod: 'DuitNow QR',
        invoiceNo: 'INV-2026-05-02',
      ),
      SsmBillingCompany(
        id: 'CO-03',
        name: '5Luxe Scents Co.',
        registrationNo: '202201089201 (1489201-K)',
        entityType: 'Sdn. Bhd.',
        monthlyFee: 50.00,
        onboardedDate: '12 Jun 2024',
        nextFilingDate: '28 Aug 2026',
        status: 'Active',
        vaultFilesCount: 6,
        isPaidForMonth: true,
        currentMonth: 'May 2026',
        paymentDate: '01 May 2026',
        paymentMethod: 'Credit Card',
        invoiceNo: 'INV-2026-05-03',
      ),
      SsmBillingCompany(
        id: 'CO-04',
        name: 'Test Enterprise',
        registrationNo: '202101034920 (1412039-P)',
        entityType: 'Enterprise',
        monthlyFee: 50.00,
        onboardedDate: '01 Sep 2024',
        nextFilingDate: '10 Oct 2026',
        status: 'Active',
        vaultFilesCount: 3,
        isPaidForMonth: false,
        currentMonth: 'May 2026',
        paymentDate: null,
        paymentMethod: null,
        invoiceNo: 'INV-2026-05-04',
        dueDate: '07 May 2026',
      ),
    ];
  }
}

class SsmBillingInvoice {
  final String invoiceNo;
  final String billingPeriod;
  final String issueDate;
  final int activeCompaniesCount;
  final double amount;
  final String status;
  final String paymentMethod;

  const SsmBillingInvoice({
    required this.invoiceNo,
    required this.billingPeriod,
    required this.issueDate,
    required this.activeCompaniesCount,
    required this.amount,
    required this.status,
    required this.paymentMethod,
  });

  static List<SsmBillingInvoice> defaultInvoices() {
    return const [
      SsmBillingInvoice(
        invoiceNo: 'INV-2026-005',
        billingPeriod: 'May 2026',
        issueDate: '01 May 2026',
        activeCompaniesCount: 4,
        amount: 200.00,
        status: 'Paid',
        paymentMethod: 'Maybank FPX Autodebit (•••• 8820)',
      ),
      SsmBillingInvoice(
        invoiceNo: 'INV-2026-004',
        billingPeriod: 'Apr 2026',
        issueDate: '01 Apr 2026',
        activeCompaniesCount: 4,
        amount: 200.00,
        status: 'Paid',
        paymentMethod: 'Maybank FPX Autodebit (•••• 8820)',
      ),
      SsmBillingInvoice(
        invoiceNo: 'INV-2026-003',
        billingPeriod: 'Mar 2026',
        issueDate: '01 Mar 2026',
        activeCompaniesCount: 3,
        amount: 150.00,
        status: 'Paid',
        paymentMethod: 'Maybank FPX Autodebit (•••• 8820)',
      ),
      SsmBillingInvoice(
        invoiceNo: 'INV-2026-002',
        billingPeriod: 'Feb 2026',
        issueDate: '01 Feb 2026',
        activeCompaniesCount: 3,
        amount: 150.00,
        status: 'Paid',
        paymentMethod: 'Maybank FPX Autodebit (•••• 8820)',
      ),
    ];
  }
}

class SubscriptionTier {
  final String id;
  final String name;
  final String tierCode;
  final String targetAudience;
  final double monthlyPrice;
  final double annualPrice;
  final int companyLimit;
  final int staffSeats;
  final int cloudStorageGB;
  final List<String> features;
  final bool isPopular;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.tierCode,
    required this.targetAudience,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.companyLimit,
    required this.staffSeats,
    required this.cloudStorageGB,
    required this.features,
    this.isPopular = false,
  });

  static List<SubscriptionTier> defaultTiers() {
    return const [
      SubscriptionTier(
        id: 'flat_ssm',
        name: 'RM 50 / SSM Company',
        tierCode: 'RM50-SSM',
        targetAudience: 'Flat rate per active SSM registered company',
        monthlyPrice: 50.00,
        annualPrice: 600.00,
        companyLimit: 9999,
        staffSeats: 999,
        cloudStorageGB: 9999,
        features: [
          'Flat RM 50.00 / month per active SSM company',
          'Zero tiered lock-ins or company quotas',
          'Unlimited secure encrypted storage',
          'Unlimited staff & licensed secretary user accounts',
          'Full SSM MBRS & Section 68 statutory filing tracking',
          'Full client document review & statutory processing',
          'Direct client sync via MySect Mobile App',
        ],
        isPopular: true,
      ),
    ];
  }
}
