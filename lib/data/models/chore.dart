import 'package:flutter/foundation.dart' show immutable;
import 'package:genie/core/config/constants.dart'; // For default room

// Enum to represent Chore Effort (matches backend integer values)
enum ChoreEffort {
  low(1),
  medium(2),
  high(3);

  const ChoreEffort(this.value);
  final int value;

  // Helper to get enum from value
  static ChoreEffort fromValue(int value) {
    return ChoreEffort.values.firstWhere((e) => e.value == value,
        orElse: () => ChoreEffort.medium); // Default if value is invalid
  }

  // Helper for display string
  String get displayName {
    switch (this) {
      case ChoreEffort.low: return 'Low';
      case ChoreEffort.medium: return 'Medium';
      case ChoreEffort.high: return 'High';
    }
  }
}

// Enum for Chore Occurrence (matches backend string values)
enum ChoreOccurrence {
  anytime("anytime"),
  daily("daily"),
  weekly("weekly"),
  monthly("monthly");

  const ChoreOccurrence(this.value);
  final String value;

  // Helper to get enum from value
  static ChoreOccurrence fromValue(String value) {
    return ChoreOccurrence.values.firstWhere((e) => e.value == value.toLowerCase(),
        orElse: () => ChoreOccurrence.anytime); // Default
  }

  String get displayName => value[0].toUpperCase() + value.substring(1);
}


@immutable
class Chore {
  final int id;
  final String name;
  final String room;
  final int? assignedUserId; // Changed from assignedTo
  final ChoreEffort effort; // Changed to Enum
  final ChoreOccurrence occurrence; // Changed to Enum
  // lastDone is removed - completion history is separate

  // Optional: Store associated username if fetched separately
  final String? assignedUsername;

  const Chore({
    required this.id,
    required this.name,
    required this.room,
    required this.effort,
    required this.occurrence,
    this.assignedUserId,
    this.assignedUsername, // Add this if you fetch/store it
  });

  factory Chore.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null || json['effort'] == null || json['occurrence'] == null) {
      throw FormatException("Missing required fields in Chore JSON: $json");
    }
    // Handle potentially null room from backend
    final rawRoom = json['room'] as String?;
    final room = (rawRoom == null || rawRoom.trim().isEmpty)
        ? AppConstants.defaultRoomName
        : rawRoom;

    return Chore(
      id: json['id'] as int,
      name: json['name'] as String,
      room: room,
      assignedUserId: json['assigned_user_id'] as int?, // Expect user ID
      effort: ChoreEffort.fromValue(json['effort'] as int), // Parse effort value
      occurrence: ChoreOccurrence.fromValue(json['occurrence'] as String), // Parse occurrence value
      // assignedUsername: null, // Initialize as null, populate later if needed
    );
  }

  // Use this or a separate class for creating chores via API
  Map<String, dynamic> toCreateJson() => {
    'name': name,
    'room': room == AppConstants.defaultRoomName ? null : room, // Send null if default
    'assigned_user_id': assignedUserId,
    'effort': effort.value, // Send the integer value
    'occurrence': occurrence.value, // Send the string value
  };

  // Use this or a separate class for updating chores via API
  // Note: Only include fields that are actually being updated
  Map<String, dynamic> toUpdateJson({
    String? newName,
    String? newRoom,
    int? newAssignedUserId, // Use null to unassign
    bool unassignUser = false, // Explicit flag to unassign
    ChoreEffort? newEffort,
    ChoreOccurrence? newOccurrence,
  }) {
    final Map<String, dynamic> data = {};
    if (newName != null) data['name'] = newName;
    if (newRoom != null) data['room'] = newRoom == AppConstants.defaultRoomName ? null : newRoom;
    if (unassignUser) data['assigned_user_id'] = null; // Handle unassignment
    else if (newAssignedUserId != null) data['assigned_user_id'] = newAssignedUserId;
    if (newEffort != null) data['effort'] = newEffort.value;
    if (newOccurrence != null) data['occurrence'] = newOccurrence.value;
    return data;
  }
}