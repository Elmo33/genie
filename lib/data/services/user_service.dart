import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:genie/core/config/constants.dart';
import 'package:genie/data/models/user.dart';

class UserService {
  // --- Existing Methods ---

  static Future<List<User>> fetchUsers() async {
    // ... (keep existing implementation)
    try {
      final response = await http.get(Uri.parse(AppConstants.usersApiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users (${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching users: $e");
      throw Exception('Network or parsing error fetching users: $e');
    }
  }

  static Future<User> fetchUser(int userId) async {
    // ... (keep existing implementation)
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
    if (kDebugMode) {
      print("Fetching user score from: $url");
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        try {
          // Decode and parse using the updated UserScore.fromJson
          final data = jsonDecode(response.body);
          if (kDebugMode) {
            print("Received score data: $data");
          }
          return UserScore.fromJson(data);
        } on FormatException catch (e) { // Catch parsing errors specifically
          print("Error parsing UserScore JSON: $e");
          throw Exception('Failed to parse user score data received from server.');
        } catch (e) { // Catch any other decoding errors
          print("Error decoding UserScore JSON: $e");
          throw Exception('Failed to decode user score data.');
        }
      } else if (response.statusCode == 404) {
        // Throw a specific, clear exception if score data isn't found
        throw Exception('Score data not found for user (ID: $userId)');
      } else {
        // Handle other potential HTTP errors
        throw Exception('Failed to fetch user score for $userId (${response.statusCode}) - ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) { // Catch network errors
      print("Network error fetching user score $userId: $e");
      throw Exception('Network error fetching score for user $userId.');
    } catch (e) { // Catch any other unexpected errors
      print("Unexpected error fetching user score $userId: $e");
      throw Exception('An unexpected error occurred while fetching the score for user $userId.');
    }
  }


  // --- NEW/IMPLEMENTED Methods ---

  /// Simulates logging in or creating a test user.
  /// In this basic version, it just fetches the predefined test user.
  /// A real app would involve authentication, potentially creating a user if login fails.
  static Future<User> loginOrCreateTestUser() async {
    if (kDebugMode) {
      print("Attempting to fetch test user ID: ${AppConstants.currentUserId}");
    }
    // For simulation, we just fetch the predefined test user.
    // We assume this user *always* exists in the test backend.
    try {
      final user = await fetchUser(AppConstants.currentUserId);
      if (kDebugMode) {
        print("Successfully fetched test user: ${user.username}");
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch test user: $e");
      }
      // Handle cases where the test user might *not* exist,
      // potentially by trying to create one (if API supports it)
      // or throwing a more specific error.
      throw Exception("Could not log in or find the test user (ID: ${AppConstants.currentUserId}). Ensure the backend service is running and the user exists. Error: $e");
    }
  }

  /// Updates user details via a PATCH request.
  static Future<User> updateUser(int userId, {String? newUsername, String? newEmail}) async {
    final url = '${AppConstants.usersApiUrl}/$userId';
    final Map<String, dynamic> body = {};

    if (newUsername != null) {
      body['username'] = newUsername;
    }
    if (newEmail != null) {
      body['email'] = newEmail; // Allow setting empty string if intended
    }

    if (body.isEmpty) {
      // Should ideally be caught before calling, but as a safeguard:
      throw Exception("No update data provided.");
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        // Often validation errors (e.g., username taken)
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Bad request';
        throw Exception('Failed to update user: $errorMessage (${response.statusCode})');
      } else if (response.statusCode == 404) {
        throw Exception('User not found for update (ID: $userId)');
      } else {
        throw Exception('Failed to update user $userId (${response.statusCode})');
      }
    } catch (e) {
      print("Error updating user $userId: $e");
      throw Exception('Network or server error updating user $userId: $e');
    }
  }

  /// Deletes a user via a DELETE request.
  static Future<void> deleteUser(int userId) async {
    final url = '${AppConstants.usersApiUrl}/$userId';
    try {
      final response = await http.delete(Uri.parse(url));

      // Successful DELETE might return 200 OK or 204 No Content
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print("Successfully deleted user $userId");
        }
        return; // Success
      } else if (response.statusCode == 404) {
        throw Exception('User not found for deletion (ID: $userId)');
      } else {
        throw Exception('Failed to delete user $userId (${response.statusCode})');
      }
    } catch (e) {
      print("Error deleting user $userId: $e");
      throw Exception('Network or server error deleting user $userId: $e');
    }
  }


  // --- Static User Handling (TEMPORARY - kept for reference) ---
  static int getCurrentUserId() {
    return AppConstants.currentUserId;
  }
  static String getCurrentUsername() {
    return AppConstants.currentUsername;
  }
}