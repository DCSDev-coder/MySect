import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../notifications/notifications_page.dart';
import 'resolved_chats_page.dart';

class ChatMessage {
  final String? text;
  final String? fileName;
  final bool isMe;
  final String time;

  ChatMessage({this.text, this.fileName, required this.isMe, required this.time});
}

class ActiveChatPage extends StatefulWidget {
  final String title;
  final List<ChatMessage>? initialMessages;
  final bool isResolved;

  const ActiveChatPage({
    super.key,
    this.title = 'Support Agent',
    this.initialMessages,
    this.isResolved = false,
  });

  @override
  State<ActiveChatPage> createState() => _ActiveChatPageState();
}

class _ActiveChatPageState extends State<ActiveChatPage> {
  final TextEditingController _textController = TextEditingController();
  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages != null 
        ? List.from(widget.initialMessages!)
        : [
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
          ];
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _textController.text.trim(),
        isMe: true,
        time: _getCurrentTime(),
      ));
      _textController.clear();
    });
  }

  Future<void> _pickFile() async {
    PlatformFile? file = await FilePicker.pickFile();

    if (file != null) {
      setState(() {
        _messages.add(ChatMessage(
          fileName: file.name,
          isMe: true,
          time: _getCurrentTime(),
        ));
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Standard App Header (Logo + Notification)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/YourSectComp.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 28,
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
            // Header Row: Back Button, Title, Resolve
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!widget.isResolved)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResolvedChatsPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Resolve',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF062AAE),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe ? const Color(0xFF062AAE) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomLeft: message.isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.fileName != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file, color: message.isMe ? Colors.white : Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    message.fileName!,
                    style: GoogleFonts.poppins(
                      color: message.isMe ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            if (message.text != null)
              Text(
                message.text!,
                style: GoogleFonts.poppins(
                  color: message.isMe ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: GoogleFonts.poppins(
                color: message.isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    if (widget.isResolved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Center(
          child: Text(
            'This chat has been resolved.',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: _pickFile,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF062AAE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
