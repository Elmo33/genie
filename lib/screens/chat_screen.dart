import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widgets/message_widget.dart';
import '../utils/session_manager.dart';
import '../widgets/hexagon_menu.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late String _sessionId;
  bool _showHexagonMenu = true;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    _sessionId = await SessionManager.getSessionId();
  }

  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': message});
      _showHexagonMenu = false; // Hide hexagon menu when conversation starts
    });
    _controller.clear();

    final response = await ChatService.sendMessage(message, _sessionId);
    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Genie', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Chat messages
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return MessageWidget(
                      message: _messages[index]['content']!,
                      isUser: _messages[index]['role'] == 'user',
                    );
                  },
                ),

                // Hexagon menu, visible when no messages
                if (_messages.isEmpty && _showHexagonMenu)
                  Align(
                    alignment: Alignment.center,
                    child: HexagonMenu(),
                  ),
              ],
            ),
          ),

          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100), // Input height limit
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                maxLines: null, // Allow multiline input
                expands: false,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Ask anything',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) _sendMessage(text);
            },
          ),
        ],
      ),
    );
  }


}
