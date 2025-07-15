import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/chat_service.dart';
import '../../../services/user_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  UserModel? _foundUser;
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _foundUser = null;
    });

    final currentUsername = context.read<AuthProvider>().user?.username;
    if (username == currentUsername) {
      setState(() {
        _loading = false;
        _error = "You can't chat with yourself";
      });
      return;
    }

    final user = await UserService().searchByUsername(username);
    setState(() {
      _loading = false;
      if (user != null) {
        _foundUser = user;
      } else {
        _error = "User not found";
      }
    });
  }

  void _startChat(UserModel other) async {
    final current = context.read<AuthProvider>().user!;
    final chatId = ChatService.generateChatId(current.username, other.username);
    await ChatService().createChatIfNotExists(current.username, other.username);
    if (!mounted) return;
    context.go('/chat/$chatId', extra: {
      'chatId': chatId,
      'otherUsername': other.username,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Enter username",
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_foundUser != null)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(_foundUser!.username),
                trailing: ElevatedButton(
                  child: const Text("Chat"),
                  onPressed: () => _startChat(_foundUser!),
                ),
              )
          ],
        ),
      ),
    );
  }
}