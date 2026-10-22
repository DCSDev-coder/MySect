class Company {
  final String id;
  final String name;
  final String ssmNo;
  final String type;
  final String incorporationDate;
  final String paidUpCapital;
  final String registeredAddress;
  final String businessAddress;
  final String officialEmail;
  final String status;
  final String assignedFirmId;
  final String assignedFirmName;
  final String assignedSecretary;
  final String assignedSecretaryLicense;
  final String assignedFirmContact;
  final String assignedFirmEmail;
  final String annualReturnDeadline;
  final String financialStatementsDeadline;
  final String subscriptionExpiresAt;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final String billingCycle;
  final String clientContact;
  final String clientEmail;
  final bool mobileAppConnected;
  final String lastMobileSync;
  final bool isLocked;
  final List<Map<String, dynamic>> directors;
  final List<Map<String, dynamic>> shareholders;
  final List<Map<String, dynamic>> statutoryDocuments;

  const Company({
    required this.id,
    required this.name,
    required this.ssmNo,
    required this.type,
    required this.incorporationDate,
    required this.paidUpCapital,
    required this.registeredAddress,
    this.businessAddress = '',
    required this.officialEmail,
    required this.status,
    required this.assignedFirmId,
    required this.assignedFirmName,
    required this.assignedSecretary,
    required this.assignedSecretaryLicense,
    required this.assignedFirmContact,
    required this.assignedFirmEmail,
    required this.annualReturnDeadline,
    required this.financialStatementsDeadline,
    this.subscriptionExpiresAt = '2027-06-14',
    this.subscriptionPlan = 'Growth Plan',
    this.subscriptionStatus = 'Active',
    this.billingCycle = 'Annual Prepaid',
    required this.clientContact,
    required this.clientEmail,
    this.mobileAppConnected = true,
    this.lastMobileSync = '',
    this.isLocked = false,
    this.directors = const [],
    this.shareholders = const [],
    this.statutoryDocuments = const [],
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ssmNo: json['ssmNo']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Sdn Bhd',
      incorporationDate: json['incorporationDate']?.toString() ?? '',
      paidUpCapital: json['paidUpCapital']?.toString() ?? 'MYR 100,000',
      registeredAddress: json['registeredAddress']?.toString() ?? 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur',
      businessAddress: json['businessAddress']?.toString() ?? '',
      officialEmail: json['officialEmail']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      assignedFirmId: json['assignedFirmId']?.toString() ?? 'firm-01',
      assignedFirmName: json['assignedFirmName']?.toString() ?? 'SectPro Corporate Services Sdn Bhd',
      assignedSecretary: json['assignedSecretary']?.toString() ?? 'Lim Mei Ling (MIA)',
      assignedSecretaryLicense: json['assignedSecretaryLicense']?.toString() ?? 'MIA CA 48192',
      assignedFirmContact: json['assignedFirmContact']?.toString() ?? '+60 3-2148 9920',
      assignedFirmEmail: json['assignedFirmEmail']?.toString() ?? 'azman@sectpro.com.my',
      annualReturnDeadline: json['annualReturnDeadline']?.toString() ?? '',
      financialStatementsDeadline: json['financialStatementsDeadline']?.toString() ?? '',
      subscriptionExpiresAt: json['subscriptionExpiresAt']?.toString() ?? '2027-06-14',
      subscriptionPlan: json['subscriptionPlan']?.toString() ?? 'Growth Plan',
      subscriptionStatus: json['subscriptionStatus']?.toString() ?? 'Active',
      billingCycle: json['billingCycle']?.toString() ?? 'Annual Prepaid',
      clientContact: json['clientContact']?.toString() ?? '',
      clientEmail: json['clientEmail']?.toString() ?? '',
      mobileAppConnected: json['mobileAppConnected'] == true,
      lastMobileSync: json['lastMobileSync']?.toString() ?? '',
      isLocked: json['isLocked'] == true || json['name'] == 'Test Enterprise',
      directors: (json['directors'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      shareholders: (json['shareholders'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      statutoryDocuments: (json['statutoryDocuments'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ssmNo': ssmNo,
      'type': type,
      'incorporationDate': incorporationDate,
      'paidUpCapital': paidUpCapital,
      'registeredAddress': registeredAddress,
      'businessAddress': businessAddress,
      'officialEmail': officialEmail,
      'status': status,
      'assignedFirmId': assignedFirmId,
      'assignedFirmName': assignedFirmName,
      'assignedSecretary': assignedSecretary,
      'assignedSecretaryLicense': assignedSecretaryLicense,
      'assignedFirmContact': assignedFirmContact,
      'assignedFirmEmail': assignedFirmEmail,
      'annualReturnDeadline': annualReturnDeadline,
      'financialStatementsDeadline': financialStatementsDeadline,
      'subscriptionExpiresAt': subscriptionExpiresAt,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'billingCycle': billingCycle,
      'clientContact': clientContact,
      'clientEmail': clientEmail,
      'mobileAppConnected': mobileAppConnected,
      'lastMobileSync': lastMobileSync,
      'isLocked': isLocked,
      'directors': directors,
      'shareholders': shareholders,
      'statutoryDocuments': statutoryDocuments,
    };
  }
}
