import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../models/ssm_filing_model.dart';
import '../services/ssm_filing_service.dart';
import '../transactions/ssm_filing_detail_page.dart';
import '../widgets/app_top_header.dart';

class RepliesNeededPage extends StatelessWidget {
  const RepliesNeededPage({super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SsmFilingService.instance,
      builder: (context, _) {
        final filingsNeedingReply = SsmFilingService.instance.filings
            .where((f) => f.status == SsmFilingStatus.secretaryReplied)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const AppTopHeader(),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 16.0,
                          bottom: 12.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black87,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secretary Replies Needed',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Action required from you to proceed with SSM lodgement',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filingsNeedingReply.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFECFDF5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 48),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'All Caught Up!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No queries or clarifications currently requested by your licensed secretary.',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: filingsNeedingReply.length,
                                itemBuilder: (context, index) {
                                  final filing = filingsNeedingReply[index];
                                  final lastSecMsg = filing.messages.lastWhere(
                                    (m) => m.isFromSecretary,
                                    orElse: () => filing.messages.last,
                                  );

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.mark_chat_unread, size: 12, color: Color(0xFFDC2626)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Secretary Action Needed',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFFDC2626),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                filing.referenceNo,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF062AAE),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            filing.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Company: ${filing.companyName} • Sec: ${filing.assignedSecretary}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1F2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFFFE4E6)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFFDC2626)),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${lastSecMsg.senderName} (${lastSecMsg.time}):',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF991B1B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  lastSecMsg.text,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF062AAE),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SsmFilingDetailPage(filingId: filing.id),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.reply_rounded, size: 16),
                                              label: Text(
                                                'Open Thread & Reply to Secretary',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) => _onItemTapped(context, index),
          ),
        );
      },
    );
  }
}
