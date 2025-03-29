import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const apiUrl = 'http://127.0.0.1:8000/chat';

  static Future<String> sendMessage(String message, String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-session-id': sessionId,
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        return 'Failed to get response (${response.statusCode})';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
