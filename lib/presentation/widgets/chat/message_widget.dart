import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageWidget({required this.message, required this.isUser, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      // Align user messages to right, assistant to left
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Add horizontal margin to prevent messages touching screen edge
        margin: EdgeInsets.only(
            top: 4, bottom: 4, left: isUser ? 48 : 8, right: isUser ? 8 : 48),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          // Use distinct colors
            color: isUser ? Colors.amber[800] : Colors.grey.shade800,
            // Use slightly different border radius for visual cue
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16),
            )
        ),
        child: Text(
          message,
          // Use theme for text style consistency
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}