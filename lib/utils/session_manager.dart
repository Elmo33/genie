import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionManager {
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedSessionId = prefs.getString('session_id');

    if (storedSessionId == null) {
      storedSessionId = const Uuid().v4();
      await prefs.setString('session_id', storedSessionId);
    }

    return storedSessionId;
  }
}
