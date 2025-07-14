import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/encryption_helper.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUsername;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _chatService = ChatService();
  final _encryption = EncryptionService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(currentUser.id, widget.otherUserId),
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
                    final isMe = message.senderId == currentUser.id;
                    final decrypted = _encryption.decrypt(message.encryptedText);

                    return ChatBubble(
                      text: decrypted,
                      isMe: isMe,
                      timestamp: message.timestamp,
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(currentUser.id),
        ],
      ),
    );
  }

  Widget _buildInput(String senderId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                _chatService.sendMessage(
                  senderId: senderId,
                  receiverId: widget.otherUserId,
                  plainText: text,
                );
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}