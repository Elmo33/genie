import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const ChatInputBar({
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // Added Material for elevation/shadow potentially
      elevation: 4.0,
      color: Theme.of(context).scaffoldBackgroundColor, // Match background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column( // Column to hold indicator above input row
          mainAxisSize: MainAxisSize.min, // Take minimum space
          children: [
            // Show loading indicator *above* the input bar when loading
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent, // Or subtle grey
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Align button nicely with multiline text
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120), // Increased max height slightly
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      maxLines: null, // Allows multiline input
                      textInputAction: TextInputAction.send, // Show send action on keyboard
                      onSubmitted: (_) => onSend(), // Allow sending via keyboard action
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Ask Genie anything...', // Updated hint text
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      enabled: !isLoading, // Disable input while loading
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Spacing
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber), // Changed color
                  // Disable button while loading, enable otherwise
                  onPressed: isLoading ? null : onSend,
                  tooltip: 'Send message',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}