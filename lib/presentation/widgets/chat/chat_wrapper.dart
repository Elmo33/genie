import 'package:flutter/material.dart';
import 'package:genie/data/services/chat_service.dart'; // Corrected import
import 'package:genie/presentation/utils/session_manager.dart'; // Corrected import
import 'package:genie/presentation/widgets/chat/chat_input_bar.dart'; // Corrected import
import 'package:genie/presentation/widgets/chat/message_widget.dart'; // Corrected import
import 'package:genie/presentation/widgets/shared/hexagon_menu.dart'; // Corrected import

class ChatWrapper extends StatefulWidget {
  final Widget? initialContent; // Optional content to show *behind* the chat
  final bool showHexMenuInitially;

  const ChatWrapper({
    super.key,
    this.initialContent,
    this.showHexMenuInitially = true, // Default to showing menu if no messages
  });

  @override
  State<ChatWrapper> createState() => _ChatWrapperState();
}

class _ChatWrapperState extends State<ChatWrapper> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Store message history more structuredly
  final List<Map<String, dynamic>> _messages = []; // Store full history dicts
  bool _isLoading = false;
  bool _showHexagonMenu = true; // Controlled by state
  String? _sessionId; // Initialize later
  String? _chatError;

  @override
  void initState() {
    super.initState();
    _showHexagonMenu = widget.showHexMenuInitially;
    _initializeSessionAndLoadHistory();
  }

  Future<void> _initializeSessionAndLoadHistory() async {
    _sessionId = await SessionManager.getSessionId();
    // Optional: Fetch initial history from backend if API supports it?
    // For now, we start with an empty local list. Backend manages full history.
    if (mounted) {
      setState(() {}); // Update state after session ID is available
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (_sessionId == null || _isLoading) return; // Don't send if no session or already loading

    final userMessage = {'role': 'user', 'content': message};

    setState(() {
      _isLoading = true;
      _messages.add(userMessage); // Add user message locally immediately
      _showHexagonMenu = false; // Hide menu once interaction starts
      _chatError = null; // Clear previous errors
    });
    _controller.clear();
    _scrollToBottom(); // Scroll after adding user message

    try {
      final response = await ChatService.sendMessage(message, _sessionId!);

      // **Decision Point: How to handle conversation history?**
      // Option 1 (Simpler): Only add the assistant's latest response. Local list might diverge from backend state.
      // Option 2 (More Robust): Replace local list with the history from the backend response.
      // Let's implement Option 1 for now, but Option 2 is better for true state sync.

      // Option 1 Implementation:
      final assistantMessage = {'role': 'assistant', 'content': response.response};
      if (mounted) {
        setState(() {
          _messages.add(assistantMessage);
          // _messages = response.conversationHistory; // Option 2 would look like this
          _isLoading = false;
        });
      }
      _scrollToBottom(); // Scroll after adding assistant message

    } catch (e) {
      if (mounted) {
        setState(() {
          _chatError = "Error: ${e.toString()}";
          // Optionally add an error message to the chat list
          _messages.add({'role': 'system', 'content': "Error communicating with Genie."});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    // Needs a slight delay to allow the ListView to update its layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show the chat history list
    final bool hasMessages = _messages.isNotEmpty;

    return Column(
      children: [
        Expanded(
          // Use Stack to overlay chat/menu on top of potential initialContent
          child: Stack(
            children: [
              // 1. Background Content (if provided)
              if (widget.initialContent != null) widget.initialContent!,

              // 2. Hexagon Menu (if applicable)
              if (!hasMessages && _showHexagonMenu)
                Align(
                  alignment: Alignment.center,
                  child: HexagonMenu(
                    // Pass callback to hide menu when an item is tapped (optional)
                    onItemTap: () => setState(() => _showHexagonMenu = false),
                  ),
                ),

              // 3. Chat History (if applicable)
              if (hasMessages)
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final messageData = _messages[index];
                    // Handle potential 'system' role for errors etc.
                    final isUser = messageData['role'] == 'user';
                    final isSystem = messageData['role'] == 'system';
                    return MessageWidget(
                      message: messageData['content'] ?? '',
                      // Adjust styling for system messages if needed
                      isUser: isUser,
                    );
                  },
                ),
            ],
          ),
        ),

        // 4. Loading/Error Indicator (Optional, subtle)
        if (_chatError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(_chatError!, style: TextStyle(color: Colors.red[300], fontSize: 12)),
          ),

        // 5. Input Bar
        ChatInputBar(
          controller: _controller,
          isLoading: _isLoading,
          onSend: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) _sendMessage(text);
          },
        ),
      ],
    );
  }
}