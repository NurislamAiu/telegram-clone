import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../auth/widgets/custom_text_field.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUsername;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final currentUsername = context.watch<AuthProvider>().user!.username;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home')
        ),
        title: Text(
          widget.otherUsername,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUsername;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.deepPurpleAccent
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.only(
                            topLeft:
                            Radius.circular(isMe ? 16 : 4),
                            topRight:
                            Radius.circular(isMe ? 4 : 16),
                            bottomLeft: const Radius.circular(16),
                            bottomRight: const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.decryptedText ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          _buildInput(currentUsername),
        ],
      ),
    );
  }

  Widget _buildInput(String senderUsername) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.only(right: 12, top: 12, left: 12, bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: 'Type your message...',
              icon: Icons.message,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.deepPurpleAccent,
            onPressed: () => _sendMessage(senderUsername),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String senderUsername) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final receiverUsername = widget.chatId
        .split('_')
        .firstWhere((name) => name != senderUsername);

    await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: senderUsername,
      receiverId: receiverUsername,
      plainText: text,
    );

    _messageController.clear();
  }
}