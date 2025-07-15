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
    context.push('/chat/$chatId', extra: {
      'chatId': chatId,
      'otherUsername': other.username,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Search User", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter username",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900], // Чёрный с лёгкой тенью внутри поля
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator(color: Colors.white),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            if (_foundUser != null)
              ListTile(
                tileColor: Colors.grey[900],
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _foundUser!.username[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                title: Text(
                  _foundUser!.username,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _startChat(_foundUser!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}