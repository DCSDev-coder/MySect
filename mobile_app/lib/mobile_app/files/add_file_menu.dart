import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void showAddMenu(BuildContext context, {bool showFolderOption = false, bool showFileOptions = true}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
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
                  context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scanned document saved', style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFF062AAE),
                        ),
                      );
                    }
                  },
                ),
                _buildUploadOption(
                  context,
                  icon: Icons.image,
                  label: 'Library',
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image selected', style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFF062AAE),
                        ),
                      );
                    }
                  },
                ),
                _buildUploadOption(
                  context,
                  icon: Icons.insert_drive_file,
                  label: 'File',
                  onTap: () async {
                    Navigator.pop(context);
                    PlatformFile? result = await FilePicker.pickFile();
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Uploaded ${result.name}', style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFF062AAE),
                        ),
                      );
                    }
                  },
                ),
                _buildUploadOption(
                  context,
                  icon: Icons.document_scanner,
                  label: 'Scan',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening scanner...', style: GoogleFonts.poppins()),
                        backgroundColor: const Color(0xFF062AAE),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
