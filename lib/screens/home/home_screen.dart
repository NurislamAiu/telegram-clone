import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/chat_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/chat_service.dart';
import '../../widgets/user_avatar.dart';

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
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: UserAvatar(username: user.username),
          ),
        ],
      ),
      body: FutureBuilder<List<ChatModel>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No chats found."));
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
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(otherUsername),
                subtitle: Text(chat.lastMessage),
                trailing: Text(
                  TimeOfDay.fromDateTime(chat.updatedAt).format(context),
                ),
                onTap: () {
                  context.go(
                    '/chat/${chat.id}',
                    extra: {
                      'otherUsername': otherUsername,
                      'chatId': chat.id,
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/search');
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}