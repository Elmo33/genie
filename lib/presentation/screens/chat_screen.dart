import 'package:flutter/material.dart';
import 'package:genie/presentation/widgets/shared/base_screen.dart'; // Adjust import

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BaseScreen now handles the main layout including the ChatWrapper
    return const BaseScreen(
      withChat: true, // This will include ChatWrapper via BaseScreen
      body: null, // Body is managed by ChatWrapper's initial state (HexMenu or Content)
    );
  }
}