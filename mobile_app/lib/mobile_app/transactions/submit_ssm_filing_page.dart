import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/ssm_filing_service.dart';
import '../services/company_service.dart';
import '../services/secretary_document_service.dart';
import 'ssm_filing_detail_page.dart';
import '../widgets/app_top_header.dart';

class SubmitSsmFilingPage extends StatefulWidget {
  final String? initialFilingType;
  final String? initialTitle;
  final String? initialDescription;

  const SubmitSsmFilingPage({
    super.key,
    this.initialFilingType,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<SubmitSsmFilingPage> createState() => _SubmitSsmFilingPageState();
}

class _SubmitSsmFilingPageState extends State<SubmitSsmFilingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _noteController;

  late String _selectedCompany;
  late String _companySsmNo;
  late String _selectedFilingType;
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 30));

  final List<String> _attachedFiles = [];
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _filingTypes = [
    {
      'type': 'Section 68 Annual Return',
      'title': 'Section 68 Annual Return Lodgement 2026',
      'desc': 'Annual return filing along with management accounts and statutory director statements.',
      'requiredDocs': ['Unaudited/Audited Accounts (PDF)', 'Director Declaration Statement'],
    },
    {
      'type': 'Section 58 Notice of Director Change',
      'title': 'Section 58 Notice of Appointment / Resignation of Director',
      'desc': 'Statutory notice of change in directors, managers, or company secretaries under Companies Act 2016.',
      'requiredDocs': ['Form 48A / Section 201 Consent to Act', 'Director NRIC front & back', 'Signed Board Resolution'],
    },
    {
      'type': 'Section 46 Change of Registered Address',
      'title': 'Section 46 Notice of Situation of Registered Office',
      'desc': 'Update the registered office address and operating hours on the official SSM registry.',
      'requiredDocs': ['Tenancy Agreement / Title Deed', 'Board Resolution for Address Change'],
    },
    {
      'type': 'Section 78 Return of Allotment of Shares',
      'title': 'Section 78 Return of Share Allotment (Capital Increase)',
      'desc': 'Lodgement for newly issued shares and paid-up capital alteration.',
      'requiredDocs': ['Bank-in slip / capital receipt confirmation', 'Members Resolution (S78)'],
    },
    {
      'type': 'Section 32 Alteration of Constitution',
      'title': 'Section 32 Adoption or Alteration of Company Constitution',
      'desc': 'Special resolution lodgement for amending company constitution.',
      'requiredDocs': ['Special Resolution', 'Copy of Altered Constitution'],
    },
    {
      'type': 'General Statutory Filing & Inquiry',
      'title': 'Custom Statutory Filing / Secretary Query',
      'desc': 'Submit custom documents for corporate secretary verification and SSM submission advice.',
      'requiredDocs': ['Relevant Statutory Draft Documents', 'Supporting Correspondence'],
    },
  ];

  @override
  void initState() {
    super.initState();
    final activeComp = CompanyService.instance.selectedCompany;
    _selectedCompany = activeComp?.name ?? 'Data Center Specialists Sdn Bhd (M)';
    _companySsmNo = activeComp?.ssmNo ?? '202101039281 (1429581-X)';

    if (widget.initialFilingType != null) {
      _selectedFilingType = widget.initialFilingType!;
    } else {
      _selectedFilingType = _filingTypes.first['type'] as String;
    }

    final matched = _filingTypes.firstWhere(
      (item) => item['type'] == _selectedFilingType,
      orElse: () => _filingTypes.first,
    );

    _titleController = TextEditingController(
      text: widget.initialTitle ?? matched['title'] as String,
    );
    _descController = TextEditingController(
      text: widget.initialDescription ?? matched['desc'] as String,
    );
    _noteController = TextEditingController(
      text: 'Dear Secretary, please review the attached statutory files and prepare the lodgement draft for SSM.',
    );

    // Add 1 default sample file based on filing type for immediate convenience
    _attachedFiles.add('${_selectedFilingType.split(' ').take(2).join('_')}_Draft_Document.pdf (1.8 MB)');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFilingTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedFilingType = newType;
      final matched = _filingTypes.firstWhere(
        (item) => item['type'] == newType,
        orElse: () => _filingTypes.first,
      );
      _titleController.text = matched['title'] as String;
      _descController.text = matched['desc'] as String;
    });
  }

  Future<void> _pickFileFromDevice() async {
    try {
      final file = await FilePicker.pickFile();
      if (file != null) {
        setState(() {
          _attachedFiles.add('${file.name} (Uploaded Document)');
        });
      }
    } catch (e) {
      // Fallback: add sample document if desktop/web picker fails or permissions denied
      _addSampleFile('Scanned_Statutory_Declaration.pdf (1.2 MB)');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _attachedFiles.add('${photo.name} (Image Upload)');
        });
      }
    } catch (e) {
      _addSampleFile('Camera_Scan_NRIC_Document.jpg (850 KB)');
    }
  }

  void _addSampleFile(String fileName) {
    setState(() {
      if (!_attachedFiles.contains(fileName)) {
        _attachedFiles.add(fileName);
      }
    });
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF062AAE),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadlineDate = picked;
      });
    }
  }

  Future<void> _submitFiling() async {
    if (!_formKey.currentState!.validate()) return;
    if (_attachedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please attach at least one document for the secretary.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    final newFiling = SsmFilingService.instance.submitNewFiling(
      companyName: _selectedCompany,
      companySsmNo: _companySsmNo,
      filingType: _selectedFilingType,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: DateFormat('yyyy-MM-dd').format(_deadlineDate),
      files: List.from(_attachedFiles),
      initialNote: _noteController.text.trim(),
    );

    // Register each attached file into Secretary Document review queue
    final activeComp = CompanyService.instance.selectedCompany;
    for (final file in _attachedFiles) {
      final cleanName = file.split(' (').first;
      SecretaryDocumentService.instance.addClientDocument(
        title: cleanName,
        category: _selectedFilingType,
        fileSize: file.contains('(') ? file.split('(').last.replaceAll(')', '') : '1.5 MB',
        companyId: activeComp?.id ?? 'comp-01',
        companyName: _selectedCompany,
        companySsmNo: _companySsmNo,
        uploadedBy: 'Adam Bin Hamzah',
        uploadedByRole: 'Managing Director (Client)',
        linkedFilingRef: newFiling.referenceNo,
        notes: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : 'Submitted under $_selectedFilingType for Secretary Review.',
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog and navigate to filing detail
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Filing Submitted!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your statutory filing has been sent to your licensed secretary for review.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference: ${newFiling.referenceNo}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF062AAE),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Secretary: ${newFiling.assignedSecretary}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: Waiting for Secretary Review',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF062AAE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              // Replace with Detail page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SsmFilingDetailPage(filingId: newFiling.id),
                ),
              );
            },
            child: Text('View Filing Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFilingTypeConfig = _filingTypes.firstWhere(
      (f) => f['type'] == _selectedFilingType,
      orElse: () => _filingTypes.first,
    );
    final requiredDocs = (currentFilingTypeConfig['requiredDocs'] as List<String>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 6.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submit SSM Filing',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Company Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.business_rounded, color: Color(0xFF062AAE), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCompany,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SSM No: $_companySsmNo',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF059669)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Secretary: Lim Mei Ling (MIA)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 20),

                // Step 1: Select Filing Type
                Text(
                  '1. SELECT SSM STATUTORY FILING',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFilingType,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF062AAE)),
                      items: _filingTypes.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['type'] as String,
                          child: Text(
                            item['type'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _onFilingTypeChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Statutory Requirements Hint Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          Text(
                            'Required Documents for this Filing:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...requiredDocs.map(
                        (doc) => Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 3.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step 2: Filing Details
                Text(
                  '2. FILING DETAILS & DEADLINE',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Title',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter title for this SSM lodgement',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Target Statutory Deadline',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _selectDeadline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF062AAE)),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(_deadlineDate),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Change',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF062AAE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Filing Description / Scope',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Describe purpose or specific instructions',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step 3: Attach Files
                Text(
                  '3. ATTACH STATUTORY DOCUMENTS',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF062AAE)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _pickFileFromDevice,
                              icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF062AAE), size: 18),
                              label: Text(
                                'Upload File',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF062AAE),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade700, size: 18),
                              label: Text(
                                'Scan / Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick add document presets for user convenience
                      Text(
                        'Quick Document Templates:',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 14, color: Color(0xFF062AAE)),
                            label: Text('+ Form 48A Consent', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF062AAE))),
                            backgroundColor: const Color(0xFFEFF6FF),
                            onPressed: () => _addSampleFile('Form_48A_Consent_to_Act_Signed.pdf (620 KB)'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 14, color: Color(0xFF062AAE)),
                            label: Text('+ Board Resolution', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF062AAE))),
                            backgroundColor: const Color(0xFFEFF6FF),
                            onPressed: () => _addSampleFile('Board_Resolution_Approval.pdf (840 KB)'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 14, color: Color(0xFF062AAE)),
                            label: Text('+ Director NRIC Copy', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF062AAE))),
                            backgroundColor: const Color(0xFFEFF6FF),
                            onPressed: () => _addSampleFile('NRIC_Director_Identification.pdf (1.1 MB)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Attached Files List
                      Text(
                        'Attached Files (${_attachedFiles.length}):',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      if (_attachedFiles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No files attached yet. Please upload or add at least one document.',
                                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._attachedFiles.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final fileName = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Color(0xFFD71920)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _attachedFiles.removeAt(idx);
                                    });
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step 4: Note to Secretary
                Text(
                  '4. INITIAL NOTE TO SECRETARY',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Add instructions or special requests for your licensed secretary...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062AAE),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitFiling,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Submit to Secretary for Review',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
),
);
}
}
