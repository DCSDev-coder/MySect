import 'package:flutter/material.dart';
import '../widgets/app_top_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_file_menu.dart';
import 'accounting_page.dart';
import 'attention_page.dart';
import 'unsorted_page.dart';
import 'corporate_page.dart';
import 'personal_page.dart';
import 'other_page.dart';
import '../services/secretary_document_service.dart';
import '../services/ssm_filing_service.dart';
import '../services/company_service.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SecretaryDocumentService.instance,
        SsmFilingService.instance,
        CompanyService.instance,
      ]),
      builder: (context, _) {
        final secService = SecretaryDocumentService.instance;
        final ssmService = SsmFilingService.instance;

        // Dynamic counts from services
        final attentionCount = secService.moreDetailsCount +
            secService.rejectedCount +
            ssmService.secretaryRepliesNeededCount;

        final unsortedCount = secService.unsortedCount;

        final accountingCount = 3 + secService.getDocumentsForFolder('Accounting').length;
        final corporateCount = 4 + secService.getDocumentsForFolder('Corporate').length;
        final personalCount = 3 + secService.getDocumentsForFolder('Personal').length;
        final otherCount = 3 + secService.getDocumentsForFolder('Other').length;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const AppTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Files',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 28,
                              ),
                              hintText: 'Search files or folders',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/tm_cloud.png',
                                width: 48,
                                height: 48,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Powered by TM Cloud',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Sync your files automatically with secure cloud storage.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'QUICK ACCESS',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            if ('Attention'.toLowerCase().contains(_searchQuery))
                              Expanded(
                                child: _buildQuickAccessCard(
                                  icon: Icons.warning_amber_rounded,
                                  iconBgColor: Colors.red[100]!,
                                  iconColor: Colors.red,
                                  badgeText: '$attentionCount ${attentionCount == 1 ? 'file' : 'files'}',
                                  badgeColor: Colors.red,
                                  badgeTextColor: Colors.white,
                                  title: 'Attention',
                                  subtitle: 'Action needed',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AttentionPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if ('Attention'.toLowerCase().contains(_searchQuery) &&
                                'Unsorted'.toLowerCase().contains(_searchQuery))
                              const SizedBox(width: 16),
                            if ('Unsorted'.toLowerCase().contains(_searchQuery))
                              Expanded(
                                child: _buildQuickAccessCard(
                                  icon: Icons.folder_outlined,
                                  iconBgColor: Colors.blue[100]!,
                                  iconColor: Colors.blue[800]!,
                                  badgeText: '$unsortedCount ${unsortedCount == 1 ? 'file' : 'files'}',
                                  badgeColor: Colors.blue[100]!,
                                  badgeTextColor: Colors.blue[800]!,
                                  title: 'Unsorted',
                                  subtitle: 'Pending review',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const UnsortedPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'FOLDERS',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if ('Accounting'.toLowerCase().contains(_searchQuery))
                          _buildFolderItem(
                            icon: Icons.folder,
                            iconColor: Colors.teal[300]!,
                            title: 'Accounting',
                            subtitle: '$accountingCount files',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AccountingPage(),
                                ),
                              );
                            },
                          ),
                        if ('Corporate'.toLowerCase().contains(_searchQuery))
                          _buildFolderItem(
                            icon: Icons.folder,
                            iconColor: Colors.orange[300]!,
                            title: 'Corporate',
                            subtitle: '$corporateCount files',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CorporatePage(),
                                ),
                              );
                            },
                          ),
                        if ('Personal'.toLowerCase().contains(_searchQuery))
                          _buildFolderItem(
                            icon: Icons.folder,
                            iconColor: Colors.green[300]!,
                            title: 'Personal',
                            subtitle: '$personalCount files',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PersonalPage(),
                                ),
                              );
                            },
                          ),
                        if ('Other'.toLowerCase().contains(_searchQuery))
                          _buildFolderItem(
                            icon: Icons.folder,
                            iconColor: Colors.blue[300]!,
                            title: 'Other',
                            subtitle: '$otherCount files',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OtherPage(),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'files_fab',
            onPressed: () => showAddMenu(
              context,
              showFileOptions: true,
              showFolderOption: false,
            ),
            backgroundColor: const Color(0xFF062AAE),
            shape: const CircleBorder(),
            child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
