import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_top_header.dart';

import '../services/company_service.dart';

class CompanyDocumentsPage extends StatelessWidget {
  const CompanyDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final company = CompanyService.instance.selectedCompany;
    final docs = (company?.statutoryDocuments != null && company!.statutoryDocuments.isNotEmpty)
        ? company.statutoryDocuments.map((d) => d['title']?.toString() ?? 'Statutory Document').toList()
        : [
            'Company Constitution (M&AA)',
            'SSM Section 14 Certificate of Incorporation',
            'SSM Corporate Profile (e-Info)',
            'Section 58 Notice of Appointment of Secretary',
            'Share Certificates Register',
            'First Board Resolution',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppTopHeader(),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documents',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (company != null)
                          Text(
                            company.name,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ...docs.map((docTitle) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildDocumentItem(docTitle),
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.file_download_outlined,
                      color: Color(0xFF062AAE),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Download PDF',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF062AAE),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
