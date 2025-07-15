import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text(widget.otherUsername),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUsername;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message.decryptedText ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildInput(currentUsername),
        ],
      ),
    );
  }

  Widget _buildInput(String senderUsername) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () => _sendMessage(senderUsername),
          )
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