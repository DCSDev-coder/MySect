import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';

class CompanyService extends ChangeNotifier {
  static final CompanyService _instance = CompanyService._internal();
  static CompanyService get instance => _instance;

  CompanyService._internal() {
    _initializeDefaultCompanies();
    syncFromAdmin();
  }

  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _isConnectedToAdmin = false;
  bool _isSyncing = false;
  String _statusMessage = 'Connecting to MySect Admin...';
  DateTime? _lastSyncTimestamp;

  List<Company> get companies => _companies;
  Company? get selectedCompany => _selectedCompany ?? (_companies.isNotEmpty ? _companies.first : null);
  bool get isConnectedToAdmin => _isConnectedToAdmin;
  bool get isSyncing => _isSyncing;
  String get statusMessage => _statusMessage;
  DateTime? get lastSyncTimestamp => _lastSyncTimestamp;

  // List of company names for dropdowns
  List<String> get companyNames => _companies.map((c) => c.name).toList();

  void _initializeDefaultCompanies() {
    _companies = [
      const Company(
        id: 'comp-01',
        name: 'Data Center Specialists Sdn Bhd (M)',
        ssmNo: '202101039281 (1429581-X)',
        type: 'Sdn Bhd (Sendirian Berhad)',
        incorporationDate: '2021-06-14',
        paidUpCapital: 'MYR 250,000',
        registeredAddress: 'No. 42-2, Jalan Eco Forest 6/1C, Eco Forest, 43500 Semenyih, Selangor',
        businessAddress: 'No. 42-2, Jalan Eco Forest 6/1C, Eco Forest, 43500 Semenyih, Selangor',
        officialEmail: 'contact@dcs.com.my',
        status: 'Active',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Lim Mei Ling (MIA)',
        assignedSecretaryLicense: 'MIA CA 48192',
        assignedFirmContact: '+60 3-2148 9920',
        assignedFirmEmail: 'azman@sectpro.com.my',
        annualReturnDeadline: '2026-11-14',
        financialStatementsDeadline: '2026-12-31',
        subscriptionExpiresAt: '2027-06-14',
        subscriptionPlan: 'Growth Plan',
        subscriptionStatus: 'Active',
        clientContact: 'Adam Bin Hamzah (Director)',
        clientEmail: 'adam@dcs.com.my',
        mobileAppConnected: true,
        lastMobileSync: 'Active Now',
        directors: [
          {'name': 'Adam Bin Hamzah', 'identification': '880512-14-5521', 'role': 'Managing Director', 'appointedDate': '2021-06-14'},
          {'name': 'Eidza Binti Jumanis', 'identification': '910304-10-5842', 'role': 'Executive Director', 'appointedDate': '2021-06-14'}
        ],
        shareholders: [
          {'shareholder': 'Adam Bin Hamzah', 'type': 'Ordinary', 'numberOfShares': '125,000', 'totalShares': '250,000', 'percentage': '50%'},
          {'shareholder': 'Eidza Binti Jumanis', 'type': 'Ordinary', 'numberOfShares': '125,000', 'totalShares': '250,000', 'percentage': '50%'}
        ],
        statutoryDocuments: [
          {'id': 'doc-01', 'title': 'Company Constitution (M&AA)', 'category': 'Statutory', 'date': '2021-06-14', 'size': '2.4 MB'},
          {'id': 'doc-02', 'title': 'SSM Section 14 Certificate of Incorporation', 'category': 'SSM Filing', 'date': '2021-06-14', 'size': '850 KB'},
          {'id': 'doc-03', 'title': 'SSM Corporate Profile (e-Info)', 'category': 'Statutory', 'date': '2026-09-01', 'size': '1.1 MB'},
          {'id': 'doc-04', 'title': 'Section 58 Notice of Appointment of Secretary', 'category': 'CoSec Lodgement', 'date': '2024-03-15', 'size': '420 KB'},
          {'id': 'doc-05', 'title': 'Section 68 Annual Return 2025', 'category': 'Annual Compliance', 'date': '2025-11-10', 'size': '3.6 MB'}
        ],
      ),
      const Company(
        id: 'comp-02',
        name: 'C2 Coffee + Candle',
        ssmNo: '202001019482 (1382941-T)',
        type: 'Sdn Bhd',
        incorporationDate: '2020-04-20',
        paidUpCapital: 'MYR 100,000',
        registeredAddress: 'Level 18, Menara Binjai, No. 2 Jalan Binjai, 50450 Kuala Lumpur',
        businessAddress: 'No. 15, Jalan Telawi 3, Bangsar Baru, 59100 Kuala Lumpur',
        officialEmail: 'hello@c2coffee.com.my',
        status: 'Active',
        assignedFirmId: 'firm-01',
        assignedFirmName: 'SectPro Corporate Services Sdn Bhd',
        assignedSecretary: 'Azman bin Ibrahim (MAICSA)',
        assignedSecretaryLicense: 'MAICSA 7019284',
        assignedFirmContact: '+60 3-2148 9920',
        assignedFirmEmail: 'azman@sectpro.com.my',
        annualReturnDeadline: '2026-10-25',
        financialStatementsDeadline: '2026-11-30',
        subscriptionExpiresAt: '2027-04-20',
        subscriptionPlan: 'Growth Plan',
        subscriptionStatus: 'Active',
        clientContact: 'Adam Bin Hamzah (Director)',
        clientEmail: 'adam@c2coffee.com.my',
        mobileAppConnected: true,
        lastMobileSync: 'Active Now',
        directors: [
          {'name': 'Adam Bin Hamzah', 'identification': '880512-14-5521', 'role': 'Managing Director', 'appointedDate': '2020-04-20'},
          {'name': 'Eidza Binti Jumanis', 'identification': '910304-10-5842', 'role': 'Director', 'appointedDate': '2020-04-20'}
        ],
        shareholders: [
          {'shareholder': 'Adam Bin Hamzah', 'type': 'Ordinary', 'numberOfShares': '60,000', 'totalShares': '100,000', 'percentage': '60%'},
          {'shareholder': 'Eidza Binti Jumanis', 'type': 'Ordinary', 'numberOfShares': '40,000', 'totalShares': '100,000', 'percentage': '40%'}
        ],
        statutoryDocuments: [
          {'id': 'doc-06', 'title': 'Company Constitution (M&AA)', 'category': 'Statutory', 'date': '2020-04-20', 'size': '2.1 MB'},
          {'id': 'doc-07', 'title': 'SSM Section 14 Certificate of Incorporation', 'category': 'SSM Filing', 'date': '2020-04-20', 'size': '780 KB'},
          {'id': 'doc-08', 'title': 'SSM Corporate Profile (e-Info)', 'category': 'Statutory', 'date': '2026-08-15', 'size': '950 KB'}
        ],
      ),
      const Company(
        id: 'comp-03',
        name: '5Luxe Scents Co.',
        ssmNo: '202201082918 (1482910-P)',
        type: 'Sdn Bhd',
        incorporationDate: '2022-08-12',
        paidUpCapital: 'MYR 50,000',
        registeredAddress: 'Unit 9-02, Block B, Phileo Damansara II, 46350 Petaling Jaya, Selangor',
        businessAddress: 'No. 42-2, Jalan Eco Forest 6/1C, Eco Forest, 43500 Semenyih, Selangor',
        officialEmail: 'admin@5luxescents.my',
        status: 'Active',
        assignedFirmId: 'firm-02',
        assignedFirmName: 'Apex Corporate Secretarial Partners',
        assignedSecretary: 'Sarah binti Ahmad (MAICSA)',
        assignedSecretaryLicense: 'MAICSA 6028192',
        assignedFirmContact: '+60 3-7955 8812',
        assignedFirmEmail: 'sarah@apexcorp.com.my',
        annualReturnDeadline: '2026-11-12',
        financialStatementsDeadline: '2026-12-15',
        subscriptionExpiresAt: '2027-08-12',
        subscriptionPlan: 'Starter Plan',
        subscriptionStatus: 'Active',
        clientContact: 'Eidza Binti Jumanis (Director)',
        clientEmail: 'eidza@5luxescents.my',
        mobileAppConnected: true,
        lastMobileSync: 'Active Now',
        directors: [
          {'name': 'Eidza Binti Jumanis', 'identification': '910304-10-5842', 'role': 'Managing Director', 'appointedDate': '2022-08-12'}
        ],
        shareholders: [
          {'shareholder': 'Eidza Binti Jumanis', 'type': 'Ordinary', 'numberOfShares': '50,000', 'totalShares': '50,000', 'percentage': '100%'}
        ],
        statutoryDocuments: [
          {'id': 'doc-10', 'title': 'Company Constitution (M&AA)', 'category': 'Statutory', 'date': '2022-08-12', 'size': '1.9 MB'},
          {'id': 'doc-11', 'title': 'SSM Section 14 Certificate of Incorporation', 'category': 'SSM Filing', 'date': '2022-08-12', 'size': '820 KB'}
        ],
      ),
      const Company(
        id: 'comp-locked',
        name: 'Test Enterprise',
        ssmNo: '202401999999 (999999-T)',
        type: 'Enterprise',
        incorporationDate: '2024-01-01',
        paidUpCapital: 'MYR 0',
        registeredAddress: 'Restricted Access',
        businessAddress: 'Restricted Access',
        officialEmail: 'locked@test.my',
        status: 'Locked',
        assignedFirmId: 'none',
        assignedFirmName: 'Unassigned',
        assignedSecretary: 'None',
        assignedSecretaryLicense: 'N/A',
        assignedFirmContact: 'N/A',
        assignedFirmEmail: 'N/A',
        annualReturnDeadline: 'N/A',
        financialStatementsDeadline: 'N/A',
        clientContact: 'Unauthorized User',
        clientEmail: 'unauthorized@test.my',
        mobileAppConnected: false,
        lastMobileSync: 'Restricted',
        isLocked: true,
      )
    ];

    _selectedCompany = _companies.first;
  }

  void selectCompany(Company company) {
    _selectedCompany = company;
    notifyListeners();
    _pingAdminSync(company.id);
  }

  void selectCompanyByName(String companyName) {
    try {
      final comp = _companies.firstWhere((c) => c.name == companyName);
      selectCompany(comp);
    } catch (_) {
      // If not found, keep current
    }
  }

  Future<void> syncFromAdmin() async {
    _isSyncing = true;
    notifyListeners();

    // Endpoints to try (localhost for desktop/web, 10.0.2.2 for Android emulator)
    final candidateUrls = [
      'http://127.0.0.1:5173/api/companies',
      'http://localhost:5173/api/companies',
      'http://10.0.2.2:5173/api/companies',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final response = await http
            .get(uri)
            .timeout(const Duration(milliseconds: 1500));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            final fetchedCompanies = data.map((item) => Company.fromJson(Map<String, dynamic>.from(item as Map))).toList();
            
            // Add Test Enterprise to list for permission boundary demo
            if (!fetchedCompanies.any((c) => c.name == 'Test Enterprise')) {
              fetchedCompanies.add(
                const Company(
                  id: 'comp-locked',
                  name: 'Test Enterprise',
                  ssmNo: '202401999999 (999999-T)',
                  type: 'Enterprise',
                  incorporationDate: '2024-01-01',
                  paidUpCapital: 'MYR 0',
                  registeredAddress: 'Restricted Access',
                  officialEmail: 'locked@test.my',
                  status: 'Locked',
                  assignedFirmId: 'none',
                  assignedFirmName: 'Unassigned',
                  assignedSecretary: 'None',
                  assignedSecretaryLicense: 'N/A',
                  assignedFirmContact: 'N/A',
                  assignedFirmEmail: 'N/A',
                  annualReturnDeadline: 'N/A',
                  financialStatementsDeadline: 'N/A',
                  clientContact: 'Unauthorized User',
                  clientEmail: 'unauthorized@test.my',
                  isLocked: true,
                ),
              );
            }

            _companies = fetchedCompanies;
            _isConnectedToAdmin = true;
            _lastSyncTimestamp = DateTime.now();
            _statusMessage = 'Connected to MySect Admin Console';

            // Preserve selected company if exists in new list
            if (_selectedCompany != null) {
              final match = _companies.firstWhere(
                (c) => c.id == _selectedCompany!.id || c.name == _selectedCompany!.name,
                orElse: () => _companies.first,
              );
              _selectedCompany = match;
            } else {
              _selectedCompany = _companies.first;
            }

            _isSyncing = false;
            notifyListeners();

            // Ping active company
            _pingAdminSync(_selectedCompany!.id);
            return;
          }
        }
      } catch (_) {
        // Continue to try next candidate endpoint
      }
    }

    // If server not reachable, retain initialized defaults and flag offline state
    _isConnectedToAdmin = false;
    _isSyncing = false;
    _statusMessage = 'Operating in Local Synchronized Mode';
    notifyListeners();
  }

  Future<void> _pingAdminSync(String companyId) async {
    final candidateUrls = [
      'http://127.0.0.1:5173/api/companies/$companyId/sync',
      'http://localhost:5173/api/companies/$companyId/sync',
      'http://10.0.2.2:5173/api/companies/$companyId/sync',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse(url);
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'clientUser': selectedCompany?.clientContact ?? 'Mobile Client',
            'device': 'MySect Mobile App',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        ).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          _isConnectedToAdmin = true;
          return;
        }
      } catch (_) {}
    }
  }
}
