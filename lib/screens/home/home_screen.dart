import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/chat_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ChatModel>> _chatsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final username = context.read<AuthProvider>().user?.username ?? '';
    print("🔍 didChangeDependencies — username: $username");
    _chatsFuture = ChatService().getUserChats(username);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildAvatar(user.username),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ChatModel>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No chats found.", style: TextStyle(color: Colors.white70)),
            );
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUsername = chat.participants.firstWhere(
                    (name) => name != user.username,
                orElse: () => 'Unknown',
              );

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: _buildAvatar(otherUsername),
                  title: Text(
                    otherUsername,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    TimeOfDay.fromDateTime(chat.updatedAt).format(context),
                    style: const TextStyle(color: Colors.white38),
                  ),
                  onTap: () {
                    context.go(
                      '/chat/${chat.id}',
                      extra: {'otherUsername': otherUsername, 'chatId': chat.id},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/search');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildAvatar(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.deepPurple,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}