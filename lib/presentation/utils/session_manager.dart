import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionManager {
  static const _sessionIdKey = 'session_id';

  static Future<String> getSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedSessionId = prefs.getString(_sessionIdKey);

      if (storedSessionId == null || storedSessionId.isEmpty) {
        storedSessionId = const Uuid().v4();
        await prefs.setString(_sessionIdKey, storedSessionId);
      }
      return storedSessionId;
    } catch (e) {
      // Handle potential SharedPreferences errors
      print("Error accessing SharedPreferences: $e");
      // Fallback to a temporary session ID for this run?
      return const Uuid().v4();
    }
  }

  // Optional: Method to clear session ID (e.g., on logout)
  static Future<void> clearSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionIdKey);
    } catch (e) {
      print("Error clearing session ID from SharedPreferences: $e");
    }
  }
}