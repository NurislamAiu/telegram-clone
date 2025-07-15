import 'package:flutter/material.dart';

class SwitchAuthText extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onTap;

  const SwitchAuthText({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          text: "$question ",
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          children: [
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: Color(0xFF272525),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}