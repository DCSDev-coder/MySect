import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void showAddMenu(BuildContext context, {bool showFolderOption = true, bool showFileOptions = true}) {
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
            if (showFileOptions || showFolderOption)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showFileOptions) ...[
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
                  ],
                  if (showFolderOption && !showFileOptions)
                    _buildUploadOption(
                      context,
                      icon: Icons.create_new_folder,
                      label: 'Folder',
                      onTap: () {
                        Navigator.pop(context);
                        _showCreateFolderDialog(context);
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
            if (showFolderOption && showFileOptions) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildUploadOption(
                    context,
                    icon: Icons.create_new_folder,
                    label: 'Folder',
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateFolderDialog(context);
                    },
                  ),
                ],
              ),
            ],
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

void _showCreateFolderDialog(BuildContext context) {
  TextEditingController folderController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: folderController,
          decoration: InputDecoration(
            hintText: 'Folder Name',
            hintStyle: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (folderController.text.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Folder "${folderController.text}" created', style: GoogleFonts.poppins()),
                    backgroundColor: const Color(0xFF062AAE),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062AAE)),
            child: Text('Create', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
