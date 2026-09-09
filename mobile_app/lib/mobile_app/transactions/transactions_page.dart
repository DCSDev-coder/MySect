import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../files/document_viewer_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime? _selectedDate;
  bool _isDocumentsNeededFilterActive = false;
  bool _isReplyNeededFilterActive = false;
  bool _isMatchingFile = false;

  String _getMonthString(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isMatchingFile = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File ${image.name} selected.', style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF1E3A8A),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      PlatformFile? file = await FilePicker.pickFile();
      if (file != null) {
        setState(() {
          _isMatchingFile = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File ${file.name} selected.', style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF1E3A8A),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _showUploadOptions(BuildContext context) {
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
                  color: const Color(0xFF1E3A8A),
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
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildUploadOption(
                    context,
                    icon: Icons.image,
                    label: 'Library',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _buildUploadOption(
                    context,
                    icon: Icons.insert_drive_file,
                    label: 'File',
                    onTap: () => _pickFile(),
                  ),
                  _buildUploadOption(
                    context,
                    icon: Icons.document_scanner,
                    label: 'Scan',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
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

  Widget _buildExampleTransaction(String title, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerPage(fileName: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF062AAE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.insert_drive_file,
              color: Color(0xFF062AAE),
              size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'rename') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rename $title coming soon', style: GoogleFonts.poppins()),
                    backgroundColor: const Color(0xFF1E3A8A),
                  ),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete $title coming soon', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rename',
                child: Text('Rename', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/mysect_logo.png',
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

            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_back, color: Colors.black),
                              const SizedBox(width: 16),
                                Text(
                                  'Transactions',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isMatchingFile) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_outlined,
                                          color: Color(0xFF1E3A8A),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Matching 1 file with transactions...',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'This can take up to 24 hours. You can add more files in the meantime.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDocumentsNeededFilterActive = !_isDocumentsNeededFilterActive;
                                      if (_isDocumentsNeededFilterActive) _isReplyNeededFilterActive = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isDocumentsNeededFilterActive ? const Color(0xFF062AAE) : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: _isDocumentsNeededFilterActive ? null : Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _isDocumentsNeededFilterActive ? Colors.white : const Color(0xFF062AAE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '0',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: _isDocumentsNeededFilterActive ? const Color(0xFF062AAE) : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Documents needed',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _isDocumentsNeededFilterActive ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isReplyNeededFilterActive = !_isReplyNeededFilterActive;
                                      if (_isReplyNeededFilterActive) _isDocumentsNeededFilterActive = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isReplyNeededFilterActive ? const Color(0xFF062AAE) : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: _isReplyNeededFilterActive ? null : Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _isReplyNeededFilterActive ? Colors.white : const Color(0xFF062AAE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '0',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: _isReplyNeededFilterActive ? const Color(0xFF062AAE) : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Reply needed',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _isReplyNeededFilterActive ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: Color(0xFF062AAE),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedDate != null ? const Color(0xFF062AAE) : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: _selectedDate != null ? const Color(0xFF062AAE) : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: _selectedDate != null ? Colors.white : Colors.black87,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedDate != null
                                              ? '${_selectedDate!.day} ${_getMonthString(_selectedDate!.month)} ${_selectedDate!.year}'
                                              : 'Select Date',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedDate != null ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        if (_selectedDate != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedDate = null;
                                              });
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(left: 4.0),
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 14,
                                            color: Colors.black87,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Align(
                        alignment: (!_isDocumentsNeededFilterActive && !_isReplyNeededFilterActive)
                            ? Alignment.topCenter
                            : const Alignment(0.0, -0.2),
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: (!_isDocumentsNeededFilterActive && !_isReplyNeededFilterActive) ? 0 : 24,
                              bottom: 24,
                              left: 24,
                              right: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: (!_isDocumentsNeededFilterActive && !_isReplyNeededFilterActive)
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                if (!_isDocumentsNeededFilterActive && !_isReplyNeededFilterActive) ...[
                                  _buildExampleTransaction('Transaction_Doc_A.pdf', 'Mar 15, 2024'),
                                  const SizedBox(height: 12),
                                  _buildExampleTransaction('Transaction_Doc_B.pdf', 'Mar 12, 2024'),
                                ] else ...[
                                  Image.asset(
                                    'assets/transation_money.png',
                                    height: 170,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.check_circle_outline,
                                        size: 120,
                                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No Pending Actions',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isDocumentsNeededFilterActive
                                        ? 'There are currently no transactions\nrequiring documents.'
                                        : 'There are currently no transactions\nrequiring a reply.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUploadOptions(context);
        },
        backgroundColor: const Color(0xFF062AAE),
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.upload_file, color: Colors.white, size: 32),
      ),
    );
  }
}
