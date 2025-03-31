import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:genie/core/config/constants.dart'; // Correct import
import 'package:genie/data/models/user.dart'; // Correct import

class UserService {
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.usersApiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        // Consider more specific error handling based on status code
        throw Exception('Failed to fetch users (${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching users: $e"); // Log error
      throw Exception('Network or parsing error fetching users: $e');
    }
  }

  static Future<User> fetchUser(int userId) async {
    final url = '${AppConstants.usersApiUrl}/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User not found (ID: $userId)');
      } else {
        throw Exception('Failed to fetch user $userId (${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching user $userId: $e");
      throw Exception('Network or parsing error fetching user $userId: $e');
    }
  }


  static Future<UserScore> fetchUserScore(int userId) async {
    final url = '${AppConstants.usersApiUrl}/$userId/score';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return UserScore.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User not found for score calculation (ID: $userId)');
      } else {
        throw Exception('Failed to fetch user score for $userId (${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching user score $userId: $e");
      throw Exception('Network or parsing error fetching score for $userId: $e');
    }
  }

  // Placeholder for creating a user if needed directly via API later
  // static Future<User> createUser(String username, {String? email}) async { ... }

  // --- Static User Handling (TEMPORARY) ---
  // In a real app, you'd get this from auth state
  static int getCurrentUserId() {
    return AppConstants.currentUserId;
  }
  static String getCurrentUsername() {
    return AppConstants.currentUsername;
  }
}