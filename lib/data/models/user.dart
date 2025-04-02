// data/models/user.dart (or relevant file)

import 'package:flutter/foundation.dart'; // For @immutable

// ... other models like User ...

@immutable
class UserScore {
  final int userId;
  final String username; // Username is now included
  final int scoreThisMonth; // Score specifically for the current month

  const UserScore({
    required this.userId,
    required this.username,
    required this.scoreThisMonth,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    // Enhanced validation
    if (json['user_id'] == null || json['username'] == null || json['score_this_month'] == null) {
      // Use kDebugMode to avoid showing raw JSON in production errors if sensitive
      final errorJsonString = kDebugMode ? json.toString() : "{hidden}";
      throw FormatException("Missing required fields in UserScore JSON: $errorJsonString");
    }
    try {
      return UserScore(
        userId: json['user_id'] as int,
        username: json['username'] as String,
        scoreThisMonth: json['score_this_month'] as int,
      );
    } on TypeError catch (e) { // Catch potential casting errors
      throw FormatException("Type error parsing UserScore JSON: $e. Received JSON: ${kDebugMode ? json.toString() : "{hidden}"}");
    }
  }

  // Optional: Add toJson if you ever need to send this model *to* an API
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'score_this_month': scoreThisMonth,
    };
  }

  // Optional: Add toString for easier debugging
  @override
  String toString() {
    return 'UserScore(userId: $userId, username: $username, scoreThisMonth: $scoreThisMonth)';
  }
}

// --- Keep your User class definition here ---
class User {
  final int id;
  final String username;
  final String? email; // Email can be optional
  final DateTime createdAt; // When the user was created

  const User({
    required this.id,
    required this.username,
    this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['username'] == null || json['created_at'] == null) {
      throw FormatException("Missing required fields in User JSON: $json");
    }
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?, // Allow null
      createdAt: DateTime.parse(json['created_at'] as String), // Assuming ISO 8601 format
    );
  }

  // Optional: Add toJson if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}