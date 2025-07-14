import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                // TODO: Перейти в профиль
              },
              child: UserAvatar(username: currentUser?.username ?? 'U'),
            ),
          ),
        ],
      ),

      // MOCK список чатов
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text("Chat with User ${index + 1}"),
            subtitle: const Text("Last message preview..."),
            trailing: const Text("10:24 AM"),
            onTap: () {
              // TODO: Переход в чат
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Открыть экран "Новый чат"
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.edit),
      ),
    );
  }
}