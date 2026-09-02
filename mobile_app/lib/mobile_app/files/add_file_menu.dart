import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void showAddMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file, color: Color(0xFF062AAE)),
                title: Text('Upload Document', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF062AAE)),
                title: Text('Scan Document', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
              ListTile(
                leading: const Icon(Icons.create_new_folder, color: Color(0xFF062AAE)),
                title: Text('Create Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
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
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
