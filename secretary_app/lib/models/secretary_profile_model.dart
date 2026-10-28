class SecretaryProfile {
  final String id;
  final String name;
  final String title;
  final String professionalBody;
  final String licenseNo;
  final String firmName;
  final String firmRegistrationNo;
  final String email;
  final String phone;
  final String officeAddress;
  final int totalAssignedCompanies;
  final String avatarUrl;

  const SecretaryProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.professionalBody,
    required this.licenseNo,
    required this.firmName,
    required this.firmRegistrationNo,
    required this.email,
    required this.phone,
    required this.officeAddress,
    required this.totalAssignedCompanies,
    required this.avatarUrl,
  });

  static SecretaryProfile defaultProfile() {
    return const SecretaryProfile(
      id: 'SEC-01',
      name: 'Lim Mei Ling',
      title: 'Senior Licensed Company Secretary',
      professionalBody: 'Malaysian Institute of Accountants (MIA) & MAICSA',
      licenseNo: 'MIA CA 48192 / LS 0009214',
      firmName: 'SectPro Corporate Services Sdn Bhd',
      firmRegistrationNo: 'SSM/COSEC/2020/00481',
      email: 'meiling.lim@sectpro.com.my',
      phone: '+60 3-2240 8899',
      officeAddress: 'Level 18, Menara TM, Jalan Pantai Baharu, 50672 Kuala Lumpur',
      totalAssignedCompanies: 14,
      avatarUrl: '',
    );
  }
}
