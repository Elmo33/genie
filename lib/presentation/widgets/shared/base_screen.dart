import 'package:flutter/material.dart';
import 'package:genie/presentation/widgets/chat/chat_wrapper.dart'; // Adjust import
import 'package:genie/presentation/widgets/shared/genie_app_bar.dart'; // Adjust import

class BaseScreen extends StatelessWidget {
  final Widget? body; // Content for screens *not* using the chat wrapper directly
  final bool withChat; // Whether to embed the ChatWrapper

  const BaseScreen({
    super.key,
    this.body,
    this.withChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color set globally in main.dart theme
      appBar: const GenieAppBar(),
      body: withChat
          ? const ChatWrapper(showHexMenuInitially: true) // Embed ChatWrapper directly
          : body ?? const SizedBox.shrink(), // Show provided body or empty space
      // Consider adding a FloatingActionButton for common actions?
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      // ),
    );
  }
}