import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:genie/core/config/constants.dart'; // Correct import

// Class to hold the structured response from the chat service
class ChatServiceResponse {
  final String response;
  final List<Map<String, dynamic>> conversationHistory; // Use Map<String, dynamic> for flexibility

  ChatServiceResponse({required this.response, required this.conversationHistory});

  factory ChatServiceResponse.fromJson(Map<String, dynamic> json) {
    if (json['response'] == null || json['conversation_history'] == null) {
      throw FormatException("Missing required fields in ChatServiceResponse JSON: $json");
    }
    // Ensure history is parsed as a List of Maps
    final history = (json['conversation_history'] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return ChatServiceResponse(
      response: json['response'] as String,
      conversationHistory: history,
    );
  }
}

class ChatService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Future<ChatServiceResponse> sendMessage(String message, String sessionId) async {
    final body = jsonEncode({'message': message});
    final headersWithSession = {..._headers, 'X-Session-ID': sessionId};

    try {
      final response = await http.post(
        Uri.parse(AppConstants.chatApiUrl), // Use constant
        headers: headersWithSession,
        body: body,
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return ChatServiceResponse.fromJson(data); // Return structured response
      } else {
        String errorDetail = response.body;
        try {
          errorDetail = jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? response.body;
        } catch(_){}
        // Consider returning a specific error structure or throwing
        throw Exception('Failed to get chat response (${response.statusCode}): $errorDetail');
      }
    } catch (e) {
      print("Error sending chat message: $e");
      throw Exception('Network or parsing error sending message: $e');
    }
  }
}