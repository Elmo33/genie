import 'package:flutter/foundation.dart' show immutable;

@immutable
class ChoreCompletion {
  final int id;
  final int choreId;
  final int userId;
  final DateTime completedAt;
  final int effortAtCompletion;

  const ChoreCompletion({
    required this.id,
    required this.choreId,
    required this.userId,
    required this.completedAt,
    required this.effortAtCompletion,
  });

  factory ChoreCompletion.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['chore_id'] == null || json['user_id'] == null ||
        json['completed_at'] == null || json['effort_at_completion'] == null) {
      throw FormatException("Missing required fields in ChoreCompletion JSON: $json");
    }
    return ChoreCompletion(
      id: json['id'] as int,
      choreId: json['chore_id'] as int,
      userId: json['user_id'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      effortAtCompletion: json['effort_at_completion'] as int,
    );
  }
}