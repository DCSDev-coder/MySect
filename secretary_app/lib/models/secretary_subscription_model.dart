class SubscriptionTier {
  final String id;
  final String name;
  final String tierCode;
  final String targetAudience;
  final double monthlyPrice;
  final double annualPrice;
  final int companyLimit;
  final int staffSeats;
  final int tmCloudStorageGB;
  final String aiIntakeTokenLimit;
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
    required this.tmCloudStorageGB,
    required this.aiIntakeTokenLimit,
    required this.features,
    this.isPopular = false,
  });

  static List<SubscriptionTier> defaultTiers() {
    return const [
      SubscriptionTier(
        id: 'starter',
        name: 'Starter Plan',
        tierCode: 'PLAN-STR-01',
        targetAudience: 'Boutique firms and solo licensed practitioners',
        monthlyPrice: 249.00,
        annualPrice: 2490.00,
        companyLimit: 25,
        staffSeats: 2,
        tmCloudStorageGB: 50,
        aiIntakeTokenLimit: '500,000 tokens/mo',
        features: [
          'Manage up to 25 companies',
          '2 staff user accounts',
          'AI-first client intake workflow',
          '50 GB TM Cloud secure storage',
          'Statutory compliance calendar & alerts',
          'Standard email support',
        ],
      ),
      SubscriptionTier(
        id: 'growth',
        name: 'Growth Plan',
        tierCode: 'PLAN-GRO-02',
        targetAudience: 'Mid-sized secretarial practices with expanding client base',
        monthlyPrice: 599.00,
        annualPrice: 5990.00,
        companyLimit: 100,
        staffSeats: 6,
        tmCloudStorageGB: 200,
        aiIntakeTokenLimit: '2,500,000 tokens/mo',
        features: [
          'Manage up to 100 companies',
          '6 staff user accounts with role permissions',
          'Advanced AI draft suggestions & resolution builder',
          '200 GB TM Cloud high-performance storage',
          'Maker-checker approval workflows',
          'Automated SSM submission tracking',
          'Priority support & firm onboarding assistance',
        ],
        isPopular: true,
      ),
      SubscriptionTier(
        id: 'professional',
        name: 'Professional Plan',
        tierCode: 'PLAN-PRO-03',
        targetAudience: 'Established multi-partner firms and corporate groups',
        monthlyPrice: 1299.00,
        annualPrice: 12990.00,
        companyLimit: 250,
        staffSeats: 15,
        tmCloudStorageGB: 500,
        aiIntakeTokenLimit: '10,000,000 tokens/mo',
        features: [
          'Manage up to 250 companies',
          '15 staff user accounts with team hierarchies',
          'Dedicated secretary AI drafting engine',
          '500 GB TM Cloud secure vault with backup redundancy',
          'Full statutory register suite & MBRS export readiness',
          'Custom firm branding & client portal themes',
          'Dedicated account manager & 4-hour SLA response',
        ],
      ),
      SubscriptionTier(
        id: 'enterprise',
        name: 'Enterprise / Network Plan',
        tierCode: 'PLAN-ENT-04',
        targetAudience: 'Large audit/corporate firms, holding groups & franchise networks',
        monthlyPrice: 2899.00,
        annualPrice: 28990.00,
        companyLimit: 1000,
        staffSeats: 50,
        tmCloudStorageGB: 2000,
        aiIntakeTokenLimit: 'Unlimited / Custom allocation',
        features: [
          'Up to 1,000 companies (custom scalable buffer)',
          'Unlimited staff seats & granular access control',
          'Private dedicated TM Cloud instance & self-hosted AI option',
          'Custom API access & legacy CRM/ERP integration',
          '99.9% uptime SLA guarantee with 24/7 hotline',
        ],
      ),
    ];
  }
}
