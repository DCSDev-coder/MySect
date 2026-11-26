import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../services/secretary_document_service.dart';
import '../services/company_service.dart';
import 'unsorted_page.dart';

void _handleUploadedFile(
  BuildContext context, {
  required String fileName,
  required String category,
  required String fileSize,
  required String notes,
  String? targetFolder,
}) {
  if (!context.mounted) return;
  final activeComp = CompanyService.instance.selectedCompany;
  final destinationFolder = targetFolder ?? 'Unsorted';

  SecretaryDocumentService.instance.addClientDocument(
    title: fileName,
    category: category,
    fileSize: fileSize,
    companyId: activeComp?.id ?? 'comp-01',
    companyName: activeComp?.name ?? 'Data Center Specialists Sdn Bhd (M)',
    companySsmNo: activeComp?.ssmNo ?? '202101039281 (1429581-X)',
    uploadedBy: 'Adam Bin Hamzah',
    uploadedByRole: 'Managing Director (Client)',
    notes: notes,
    folder: destinationFolder,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        targetFolder != null
            ? '$fileName uploaded to $targetFolder'
            : '$fileName uploaded to Unsorted',
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: const Color(0xFF062AAE),
      action: targetFolder == null
          ? SnackBarAction(
              label: 'Sort Now',
              textColor: Colors.white,
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UnsortedPage()),
                  );
                }
              },
            )
          : null,
    ),
  );
}

void showAddMenu(
  BuildContext context, {
  bool showFolderOption = false,
  bool showFileOptions = true,
  String? targetFolder,
  void Function(String fileName, String sourceLabel)? onFilePicked,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) {
      return Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF062AAE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUploadOption(
                  sheetContext,
                  icon: Icons.image,
                  label: 'Library',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    String? fileName;
                    try {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        fileName = image.name.isNotEmpty
                            ? image.name
                            : 'Image_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg';
                      }
                    } catch (_) {
                      if (onFilePicked != null) {
                        fileName = 'Library_Image_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg';
                      }
                    }
                    if (fileName == null) return;
                    if (onFilePicked != null) {
                      onFilePicked(fileName, 'Photo Library');
                      return;
                    }
                    if (!context.mounted) return;
                    _handleUploadedFile(
                      context,
                      fileName: fileName,
                      category: targetFolder != null ? '$targetFolder Document' : 'Supporting Document',
                      fileSize: '1.8 MB',
                      notes: 'Uploaded from photo library for secretary review.',
                      targetFolder: targetFolder,
                    );
                  },
                ),
                _buildUploadOption(
                  sheetContext,
                  icon: Icons.insert_drive_file,
                  label: 'File',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    String? fileName;
                    try {
                      PlatformFile? result = await FilePicker.pickFile();
                      if (result != null) {
                        fileName = result.name;
                      }
                    } catch (_) {
                      if (onFilePicked != null) {
                        fileName = 'Uploaded_Document_${DateTime.now().millisecondsSinceEpoch % 10000}.pdf';
                      }
                    }
                    if (fileName == null) return;
                    if (onFilePicked != null) {
                      onFilePicked(fileName, 'Uploaded Document');
                      return;
                    }
                    if (!context.mounted) return;
                    _handleUploadedFile(
                      context,
                      fileName: fileName,
                      category: targetFolder != null ? '$targetFolder Document' : 'Corporate Document',
                      fileSize: '1.4 MB',
                      notes: 'Uploaded by client via MySect Mobile App.',
                      targetFolder: targetFolder,
                    );
                  },
                ),
                _buildUploadOption(
                  sheetContext,
                  icon: Icons.document_scanner,
                  label: 'Scan',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    final scannedName = 'Scanned_Doc_${DateTime.now().millisecondsSinceEpoch % 10000}.pdf';
                    if (onFilePicked != null) {
                      onFilePicked(scannedName, 'Scanned Document');
                      return;
                    }
                    _handleUploadedFile(
                      context,
                      fileName: scannedName,
                      category: targetFolder != null ? '$targetFolder Document' : 'Scanned Document',
                      fileSize: '1.2 MB',
                      notes: 'Scanned via MySect Mobile App.',
                      targetFolder: targetFolder,
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(sheetContext),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget _buildUploadOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.black87,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
