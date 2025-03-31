import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:genie/core/config/constants.dart'; // Correct import
import 'package:genie/data/models/chore.dart'; // Correct import
import 'package:genie/data/models/chore_completion.dart'; // Correct import

class ChoreService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-T8', // Specify UTF-8
  };

  static Future<List<Chore>> fetchChores() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.choresApiUrl));
      if (response.statusCode == 200) {
        // Decode response body assuming UTF-8
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => Chore.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch chores (${response.statusCode})');
      }
    } catch (e) {
      print("Error fetching chores: $e");
      throw Exception('Network or parsing error fetching chores: $e');
    }
  }

  // Example: Takes specific fields for creation
  static Future<Chore> addChore({
    required String name,
    String? room,
    int? assignedUserId,
    required ChoreEffort effort,
    required ChoreOccurrence occurrence,
  }) async {
    // Create a map matching the ChoreCreate schema implicitly
    final body = jsonEncode({
      'name': name,
      'room': room,
      'assigned_user_id': assignedUserId,
      'effort': effort.value, // Send enum value
      'occurrence': occurrence.value, // Send enum value
    });

    try {
      final response = await http.post(
        Uri.parse(AppConstants.choresApiUrl),
        headers: _headers,
        body: body,
      );
      // Backend creates with 201, but might return 200 OK as well
      if (response.statusCode == 201 || response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return Chore.fromJson(jsonDecode(decodedBody));
      } else {
        // Log detailed error from backend if available
        String errorDetail = response.body;
        try {
          errorDetail = jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? response.body;
        } catch(_){}
        throw Exception('Failed to add chore (${response.statusCode}): $errorDetail');
      }
    } catch (e) {
      print("Error adding chore: $e");
      throw Exception('Network or parsing error adding chore: $e');
    }
  }

  // Takes ID and a map representing ChoreUpdate fields
  static Future<Chore> updateChore(int id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) {
      throw ArgumentError("No updates provided for chore $id");
    }
    final url = '${AppConstants.choresApiUrl}/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(updates),
      );
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return Chore.fromJson(jsonDecode(decodedBody)); // Return updated chore
      } else {
        String errorDetail = response.body;
        try {
          errorDetail = jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? response.body;
        } catch(_){}
        throw Exception('Failed to update chore $id (${response.statusCode}): $errorDetail');
      }
    } catch (e) {
      print("Error updating chore $id: $e");
      throw Exception('Network or parsing error updating chore $id: $e');
    }
  }

  static Future<bool> deleteChore(int id) async {
    final url = '${AppConstants.choresApiUrl}/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      // Expect 204 No Content on success
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        print("Chore $id not found for deletion.");
        return false; // Or throw specific exception
      } else {
        // Log error
        print('Failed to delete chore $id (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print("Error deleting chore $id: $e");
      return false; // Or rethrow
    }
  }

  // --- New Method for Completion ---
  static Future<ChoreCompletion> completeChore(int choreId, int userId) async {
    // Backend endpoint expects POST to /chores/{chore_id}/complete
    // And takes user_id as a required query parameter based on endpoint signature
    // Adjust if backend expects user_id in body instead.
    final url = Uri.parse('${AppConstants.choresApiUrl}/$choreId/complete')
        .replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.post(
        url,
        headers: _headers, // No body needed if user_id is query param
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return ChoreCompletion.fromJson(jsonDecode(decodedBody));
      } else {
        String errorDetail = response.body;
        try {
          errorDetail = jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? response.body;
        } catch(_){}
        throw Exception('Failed to complete chore $choreId for user $userId (${response.statusCode}): $errorDetail');
      }
    } catch (e) {
      print("Error completing chore $choreId: $e");
      throw Exception('Network or parsing error completing chore $choreId: $e');
    }
  }
}