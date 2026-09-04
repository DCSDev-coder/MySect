import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'add_file_menu.dart';
import 'document_file.dart';
import '../widgets/custom_bottom_nav_bar.dart';
class CorporatePage extends StatefulWidget {
  const CorporatePage({super.key});

  @override
  State<CorporatePage> createState() => _CorporatePageState();
}

class _CorporatePageState extends State<CorporatePage> {
  final int _selectedIndex = 2;

  final List<DocumentFile> _myFiles = [
    DocumentFile(
      title: 'Certificate of Incorporation',
      subtitle: 'ACRA Corporate Info • PDF',
      badgeText: 'Signed by all',
      requiredActions: 3,
      uploadedFiles: ['Cert_Incorp_1.pdf', 'Cert_Incorp_2.pdf', 'Cert_Incorp_3.pdf'],
    ),
    DocumentFile(
      title: 'Company BizFile 2024',
      subtitle: 'Corporate Structure • PDF',
      badgeText: 'Progress',
      requiredActions: 3,
      uploadedFiles: ['BizFile_1.pdf', 'BizFile_2.pdf'],
    ),
    DocumentFile(
      title: 'Director Resolution 2024',
      subtitle: 'Board & Meetings • PDF',
      badgeText: 'Pending',
      requiredActions: 3,
      uploadedFiles: [],
    ),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/YourSectComp.png',
                    width: 110,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Corporate',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 28,
                          ),
                          hintText: 'Search documents',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '21 NOV 2025',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._myFiles.map((file) {
                      return _buildDocumentCard(
                        title: file.title,
                        subtitle: file.subtitle,
                        badgeText: file.badgeText,
                        badgeBgColor: file.progressColor.withValues(alpha: 0.1),
                        badgeTextColor: file.progressColor == Colors.green 
                            ? Colors.green[800]! 
                            : (file.progressColor == Colors.blue 
                                ? Colors.blue[800]! 
                                : Colors.red[800]!),
                        timeText: 'Today, 10:24 AM', // Hardcoded time for now
                        progressText: file.progressText,
                        progressColor: file.progressColor,
                        onTap: () {
                          setState(() {
                            file.isExpanded = !file.isExpanded;
                          });
                        },
                        isExpanded: file.isExpanded,
                        uploadedFiles: file.uploadedFiles,
                        onUpload: () async {
                          if (file.uploadedFiles.length < file.requiredActions) {
                            var result = await FilePicker.pickFile();
                            if (result != null) {
                              setState(() {
                                file.uploadedFiles.add(result.name);
                              });
                            }
                          }
                        },
                        onRemoveFile: (index) {
                          setState(() {
                            file.uploadedFiles.removeAt(index);
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => showAddMenu(context),
        backgroundColor: const Color(0xFF062AAE),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required String timeText,
    required String progressText,
    required Color progressColor,
    required bool isExpanded,
    required List<String> uploadedFiles,
    VoidCallback? onTap,
    VoidCallback? onUpload,
    Function(int)? onRemoveFile,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
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
              Text(
                timeText,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/PDF.png', width: 48, height: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              progressText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: progressColor,
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 32),
            Text('Uploaded Files', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            if (uploadedFiles.isEmpty)
              Text('No files uploaded yet.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ...uploadedFiles.asMap().entries.map((entry) {
              int idx = entry.key;
              String f = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: GoogleFonts.poppins(fontSize: 12))),
                    if (onRemoveFile != null)
                      GestureDetector(
                        onTap: () => onRemoveFile(idx),
                        child: const Icon(Icons.close, size: 16, color: Colors.grey),
                      ),
                  ],
                ),
              );
            }),
            if (progressColor != Colors.green)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload File'),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}
}
