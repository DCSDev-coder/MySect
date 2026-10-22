import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ssm_filing_model.dart';
import '../services/ssm_filing_service.dart';

class SsmFilingDetailPage extends StatefulWidget {
  final String filingId;

  const SsmFilingDetailPage({super.key, required this.filingId});

  @override
  State<SsmFilingDetailPage> createState() => _SsmFilingDetailPageState();
}

class _SsmFilingDetailPageState extends State<SsmFilingDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _pendingAttachments = [];
  bool _isSending = false;
  bool _showSimToolbar = true;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _attachFile() async {
    try {
      final file = await FilePicker.pickFile();
      if (file != null) {
        setState(() {
          _pendingAttachments.add('${file.name} (Uploaded Document)');
        });
      }
    } catch (e) {
      setState(() {
        _pendingAttachments.add('Director_Signed_Addendum.pdf (640 KB)');
      });
    }
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    SsmFilingService.instance.sendClientReply(
      widget.filingId,
      text.isNotEmpty ? text : 'Uploaded requested documents for secretary review.',
      attachments: List.from(_pendingAttachments),
    );

    _replyController.clear();
    setState(() {
      _pendingAttachments.clear();
      _isSending = false;
    });

    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reply sent to secretary. Status updated to "Waiting for Secretary Review".',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        backgroundColor: const Color(0xFF062AAE),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SsmFilingService.instance,
      builder: (context, _) {
        final filings = SsmFilingService.instance.filings;
        final filingIndex = filings.indexWhere((f) => f.id == widget.filingId);

        if (filingIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Filing Not Found')),
            body: const Center(child: Text('This filing could not be found.')),
          );
        }

        final filing = filings[filingIndex];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filing.referenceNo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF062AAE),
                  ),
                ),
                Text(
                  filing.companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Toggle Simulation Toolbar',
                icon: Icon(
                  _showSimToolbar ? Icons.smart_toy_rounded : Icons.smart_toy_outlined,
                  color: const Color(0xFF062AAE),
                ),
                onPressed: () {
                  setState(() {
                    _showSimToolbar = !_showSimToolbar;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Interactive Secretary Demo Simulation Bar (forPair programming testing)
              if (_showSimToolbar)
                Container(
                  color: const Color(0xFFEFF6FF),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF1D4ED8), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Secretary Demo Triggers:',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          _buildSimButton(
                            label: 'Secretary Reply',
                            color: const Color(0xFFDC2626),
                            bgColor: const Color(0xFFFEE2E2),
                            onTap: () {
                              SsmFilingService.instance.simulateSecretaryClarification(
                                filing.id,
                                'Hi Adam, please provide the signed Form 48A Consent to Act and clear director NRIC copy so we can finalize the SSM lodgement.',
                              );
                              _scrollToBottom();
                            },
                          ),
                          _buildSimButton(
                            label: 'Lodge to SSM',
                            color: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF5F3FF),
                            onTap: () {
                              SsmFilingService.instance.simulateSecretaryApproval(filing.id);
                              _scrollToBottom();
                            },
                          ),
                          _buildSimButton(
                            label: 'SSM Approved',
                            color: const Color(0xFF059669),
                            bgColor: const Color(0xFFECFDF5),
                            onTap: () {
                              SsmFilingService.instance.simulateSsmCompletion(filing.id);
                              _scrollToBottom();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Main Scrollable Content
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status Hero Card
                    _buildStatusHeroCard(filing),
                    const SizedBox(height: 16),

                    // Licensed Secretary Card
                    _buildSecretaryCard(filing),
                    const SizedBox(height: 16),

                    // Visual Progress Tracker
                    _buildProgressStepper(filing),
                    const SizedBox(height: 16),

                    // Attached Files Section
                    _buildAttachedFilesSection(filing),
                    const SizedBox(height: 20),

                    // Secretary & Client Conversation Header
                    Row(
                      children: [
                        const Icon(Icons.question_answer_outlined, size: 18, color: Color(0xFF062AAE)),
                        const SizedBox(width: 8),
                        Text(
                          'SECRETARY QUERY & DISCUSSION THREAD',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Chat messages
                    if (filing.messages.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            'No conversation messages yet. Secretary is reviewing your submission.',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...filing.messages.map((msg) => _buildMessageBubble(msg)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Pending Attachments Bar
              if (_pendingAttachments.isNotEmpty)
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 16, color: Color(0xFF062AAE)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_pendingAttachments.length} file(s) ready to send: ${_pendingAttachments.join(', ')}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          setState(() {
                            _pendingAttachments.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Reply Input Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Color(0xFF062AAE)),
                        onPressed: _attachFile,
                        tooltip: 'Attach Document',
                      ),
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendReply(),
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: filing.status == SsmFilingStatus.secretaryReplied
                                ? 'Reply to secretary & attach clarification...'
                                : 'Send inquiry or note to secretary...',
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFF062AAE)),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF062AAE),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: _isSending ? null : _sendReply,
                          tooltip: 'Send',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimButton({
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeroCard(SsmFiling filing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filing.filingType,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF062AAE),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filing.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            filing.description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),

          // Status Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: filing.status.bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: filing.status.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(filing.status.icon, size: 15, color: filing.status.color),
                    const SizedBox(width: 6),
                    Text(
                      filing.status.label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: filing.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${filing.deadline}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecretaryCard(SsmFiling filing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_pin_rounded, color: Color(0xFF062AAE), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        filing.assignedSecretary,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Licensed',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  filing.assignedFirmName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  filing.status == SsmFilingStatus.secretaryReplied
                      ? 'Action needed from you to proceed'
                      : 'Reviewing statutory compliance & schedule',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: filing.status == SsmFilingStatus.secretaryReplied
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(SsmFiling filing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUTORY FILING PROGRESS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${filing.timeline.length} Steps',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...filing.timeline.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isLast = idx == filing.timeline.length - 1;

            Color iconColor;
            IconData iconData;
            if (step.isCompleted) {
              iconColor = const Color(0xFF059669);
              iconData = Icons.check_circle_rounded;
            } else if (step.isCurrent) {
              iconColor = const Color(0xFFD97706);
              iconData = Icons.timelapse_rounded;
            } else {
              iconColor = Colors.grey.shade400;
              iconData = Icons.radio_button_unchecked;
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(iconData, size: 20, color: iconColor),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: step.isCompleted ? const Color(0xFF059669) : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  step.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: step.isCurrent ? const Color(0xFF062AAE) : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                step.timestamp,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.description,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttachedFilesSection(SsmFiling filing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATTACHED FILING DOCUMENTS (${filing.attachedFiles.length})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.black87,
                ),
              ),
              InkWell(
                onTap: _attachFile,
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 14, color: Color(0xFF062AAE)),
                    Text(
                      'Add',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF062AAE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filing.attachedFiles.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: Color(0xFF062AAE), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      file,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.cloud_download_outlined, color: Colors.grey, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SsmMessage msg) {
    final isSec = msg.isFromSecretary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSec ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isSec) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 18, color: Color(0xFF062AAE)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSec ? Colors.white : const Color(0xFF062AAE),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isSec ? 2 : 12),
                  bottomRight: Radius.circular(isSec ? 12 : 2),
                ),
                border: isSec ? Border.all(color: const Color(0xFFE2E8F0)) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isSec ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSec ? const Color(0xFF062AAE) : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        msg.time,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: isSec ? Colors.grey.shade500 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.text,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSec ? Colors.black87 : Colors.white,
                    ),
                  ),
                  if (msg.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...msg.attachments.map(
                      (att) => Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSec ? const Color(0xFFF1F5F9) : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attachment,
                              size: 12,
                              color: isSec ? const Color(0xFF062AAE) : Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                att,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: isSec ? Colors.black87 : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isSec) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF062AAE).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF062AAE)),
            ),
          ],
        ],
      ),
    );
  }
}
