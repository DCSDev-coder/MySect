import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notifications/notifications_page.dart';
import 'package:file_picker/file_picker.dart';

class AttentionPage extends StatelessWidget {
  const AttentionPage({super.key});

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
                    'assets/YourSectComp.png',
                    width: 110,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attention',
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
                    _ExpandableDocumentCard(
                      badgeText: 'Action Required',
                      badgeBgColor: Colors.red[100]!,
                      badgeTextColor: Colors.red[800]!,
                      timeText: 'Today, 09:00 AM',
                      progressText: 'Pending Signature',
                      progressColor: Colors.red,
                      title: 'Director Resolution 2026',
                      completedItems: const ['Document Uploaded', 'Initial Review'],
                      pendingItems: const ['Awaiting Director Signature', 'Final Approval'],
                    ),
                    _ExpandableDocumentCard(
                      badgeText: 'Urgent',
                      badgeBgColor: Colors.orange[100]!,
                      badgeTextColor: Colors.orange[800]!,
                      timeText: 'Yesterday, 04:30 PM',
                      progressText: '',
                      progressColor: Colors.transparent,
                      title: 'Tax Invoice #1029',
                      completedItems: const ['Invoice Scanned'],
                      pendingItems: const ['Upload Missing ID', 'Verify Payment Details'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableDocumentCard extends StatefulWidget {
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String timeText;
  final String progressText;
  final Color progressColor;
  final String title;
  final List<String> completedItems;
  final List<String> pendingItems;

  const _ExpandableDocumentCard({
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.timeText,
    required this.progressText,
    required this.progressColor,
    required this.title,
    required this.completedItems,
    required this.pendingItems,
  });

  @override
  State<_ExpandableDocumentCard> createState() => _ExpandableDocumentCardState();
}

class _ExpandableDocumentCardState extends State<_ExpandableDocumentCard> {
  bool _isExpanded = false;
  final List<String> _uploadedFiles = [];



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: _isExpanded ? Border.all(color: Colors.grey.shade300) : null,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.badgeText,
                    style: GoogleFonts.poppins(
                      color: widget.badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.timeText,
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
                Image.asset(
                  'assets/PDF.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view checklist',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
            if (!_isExpanded)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  widget.progressText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: widget.progressColor,
                  ),
                ),
              ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Action Checklist',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Completed Items
              ...widget.completedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  )),
              // Pending Items
              ...widget.pendingItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'Uploaded Files',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (_uploadedFiles.isEmpty)
                Text(
                  'No files uploaded yet.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ..._uploadedFiles.asMap().entries.map((entry) {
                int idx = entry.key;
                String f = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: GoogleFonts.poppins(fontSize: 12))),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _uploadedFiles.removeAt(idx);
                          });
                        },
                        child: const Icon(Icons.close, size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () async {
                    var result = await FilePicker.pickFile();
                    if (result != null) {
                      setState(() {
                        _uploadedFiles.add(result.name);
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload File'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5B61A4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
