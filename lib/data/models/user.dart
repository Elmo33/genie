import 'package:flutter/foundation.dart' show immutable;

@immutable // Good practice for models if they don't change after creation
class User {
  final int id;
  final String username;
  final String? email; // Backend email is optional
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Add defensive checks for required fields
    if (json['id'] == null || json['username'] == null || json['created_at'] == null) {
      throw FormatException("Missing required fields in User JSON: $json");
    }
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

// No toJson needed unless you plan to send User data TO the backend
// For UserCreate, a separate simpler class or Map is better.
}

// Optional: Model for user score if needed frequently
@immutable
class UserScore {
  final int userId;
  final String username;
  final int scoreThisMonth;

  const UserScore({
    required this.userId,
    required this.username,
    required this.scoreThisMonth,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    if (json['user_id'] == null || json['username'] == null || json['score_this_month'] == null) {
      throw FormatException("Missing required fields in UserScore JSON: $json");
    }
    return UserScore(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      scoreThisMonth: json['score_this_month'] as int,
    );
  }
}