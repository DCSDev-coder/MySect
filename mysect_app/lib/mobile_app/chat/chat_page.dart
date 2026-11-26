import 'package:flutter/material.dart';
import '../widgets/app_top_header.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ssm_filing_model.dart';
import '../services/ssm_filing_service.dart';
import 'resolved_chats_page.dart';
import 'active_chat_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatConversation {
  final String id;
  final String title;
  final String time;
  final String lastMessage;
  final List<ChatMessage> messages;
  final int unreadCount;
  final bool isAssistant;

  const _ChatConversation({
    required this.id,
    required this.title,
    required this.time,
    required this.lastMessage,
    required this.messages,
    this.unreadCount = 0,
    this.isAssistant = false,
  });
}

class _ChatPageState extends State<ChatPage> {
  String _searchQuery = '';
  final Set<String> _pinnedConversationIds = {};
  final List<_ChatConversation> _conversations = [
    _ChatConversation(
      id: 'general-support',
      title: 'General Support',
      time: '10:05 AM',
      lastMessage: 'Sure, I can help with that. What seems to be the issue?',
      unreadCount: 1,
      isAssistant: true,
      messages: [
        ChatMessage(
          text: 'Hi there! How can I help you today?',
          isMe: false,
          time: '10:00 AM',
        ),
        ChatMessage(
          text: 'I have a question about my recent document upload.',
          isMe: true,
          time: '10:02 AM',
        ),
        ChatMessage(
          text: 'Sure, I can help with that. What seems to be the issue?',
          isMe: false,
          time: '10:05 AM',
        ),
      ],
    ),
  ];

  void _startNewConversationSheet() {
    final topicController = TextEditingController();
    final topics = [
      ('Ask About My Files', 'Ask AI about your uploaded MySect documents', Icons.folder_outlined),
      ('SSM Deadlines & Rules', 'Get instant answers on statutory compliance', Icons.event_note_rounded),
      ('Document Checklist', 'Check what forms or documents are required', Icons.checklist_rounded),
      ('General AI Help', 'Ask any general question to MySect AI Assistant', Icons.auto_awesome),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF062AAE), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ask MySect AI Assistant',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Start a new AI chat. Secretary chats appear automatically when your secretary messages you.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),
              ...topics.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openNewConversation(t.$1);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(t.$3, color: const Color(0xFF062AAE), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.$1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  t.$2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF062AAE)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: topicController,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Or type a custom topic...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final custom = topicController.text.trim();
                      Navigator.pop(sheetContext);
                      _openNewConversation(custom.isNotEmpty ? custom : 'New Conversation');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062AAE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Start',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNewConversation(String title) {
    final now = TimeOfDay.now().format(context);
    final id = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    final newConv = _ChatConversation(
      id: id,
      title: title,
      time: now,
      lastMessage: 'Hi! Ask me anything about your files or compliance.',
      messages: [
        ChatMessage(
          text: 'Hi! I am MySect AI Assistant. How can I help you with $title?',
          isMe: false,
          time: now,
        ),
      ],
      unreadCount: 0,
      isAssistant: true,
    );
    setState(() {
      _conversations.insert(0, newConv);
    });
    SsmFilingService.instance.markChatRead(id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveChatPage(
          title: title,
          initialMessages: newConv.messages,
          isResolved: false,
          isAssistant: true,
        ),
      ),
    );
  }

  List<_ChatConversation> _allConversations() {
    final List<_ChatConversation> list = [];

    for (final filing in SsmFilingService.instance.filings) {
      if (filing.status == SsmFilingStatus.completed) continue;
      // Only show secretary conversations where the secretary has messaged the client
      if (!filing.messages.any((m) => m.isFromSecretary)) {
        continue;
      }
      final msgs = filing.messages
          .map(
            (m) => ChatMessage(
              text: m.text,
              fileName: m.attachments.isNotEmpty ? m.attachments.first : null,
              isMe: !m.isFromSecretary,
              time: m.time,
            ),
          )
          .toList();

      final int unread = SsmFilingService.instance.unreadCountForFiling(filing);

      final lastMsg = filing.messages.isNotEmpty
          ? filing.messages.last.text
          : 'Tap to message secretary';
      final String lastTime = filing.messages.isNotEmpty
          ? filing.messages.last.time
          : '${filing.submittedDate.day}/${filing.submittedDate.month}/${filing.submittedDate.year}';

      list.add(
        _ChatConversation(
          id: filing.id,
          title: filing.title,
          time: lastTime,
          lastMessage: lastMsg,
          messages: msgs,
          unreadCount: unread,
        ),
      );
    }

    for (final c in _conversations) {
      final service = SsmFilingService.instance;
      final unread = service.isChatRead(c.id)
          ? 0
          : (service.isChatManuallyUnread(c.id) && c.unreadCount == 0
              ? 1
              : c.unreadCount);
      list.add(
        _ChatConversation(
          id: c.id,
          title: c.title,
          time: c.time,
          lastMessage: c.lastMessage,
          messages: c.messages,
          unreadCount: unread,
          isAssistant: c.isAssistant,
        ),
      );
    }

    final pinned = list.where((c) => _pinnedConversationIds.contains(c.id)).toList();
    final unpinned = list.where((c) => !_pinnedConversationIds.contains(c.id)).toList();
    return [...pinned, ...unpinned];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Chats',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResolvedChatsPage(),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF062AAE),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFF062AAE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Resolve',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                          hintText: 'Search message',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: SsmFilingService.instance,
                      builder: (context, _) {
                        final all = _allConversations();
                        final filtered = all.where((c) {
                          if (_searchQuery.isEmpty) return true;
                          return c.title.toLowerCase().contains(_searchQuery) ||
                              c.lastMessage.toLowerCase().contains(_searchQuery);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Center(
                              child: Text(
                                'No results found for "$_searchQuery"',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: filtered.map(_buildChatCard).toList(),
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
        heroTag: 'chat_fab',
        onPressed: _startNewConversationSheet,
        backgroundColor: const Color(0xFF062AAE),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildChatCard(_ChatConversation conv) {
    final isPinned = _pinnedConversationIds.contains(conv.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPinned
            ? Border.all(color: const Color(0xFFBFDBFE), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () {
            setState(() {
              if (isPinned) {
                _pinnedConversationIds.remove(conv.id);
              } else {
                _pinnedConversationIds.add(conv.id);
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isPinned
                      ? 'Unpinned "${conv.title}"'
                      : 'Pinned "${conv.title}" to top',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: const Color(0xFF062AAE),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onTap: () async {
            SsmFilingService.instance.markChatRead(conv.id);
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveChatPage(
                  title: conv.title,
                  initialMessages: conv.messages,
                  isResolved: false,
                  isAssistant: conv.isAssistant,
                ),
              ),
            );
            if (result == 'mark_unread' && mounted) {
              SsmFilingService.instance.markChatUnread(conv.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: conv.isAssistant
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: conv.isAssistant
                          ? const Color(0xFFBAE6FD)
                          : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: Icon(
                    conv.isAssistant
                        ? Icons.auto_awesome
                        : Icons.person_rounded,
                    color: conv.isAssistant
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF062AAE),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isPinned) ...[
                            Icon(
                              Icons.push_pin_rounded,
                              size: 13,
                              color: conv.isAssistant
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF062AAE),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            conv.time,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: conv.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: conv.unreadCount > 0
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          if (conv.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '${conv.unreadCount}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
