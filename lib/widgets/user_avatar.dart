import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String username;
  final double radius;

  const UserAvatar({
    super.key,
    required this.username,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueAccent.shade100,
      foregroundColor: Colors.white,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}