import 'package:flutter/material.dart';
import 'package:genie/data/models/chore.dart'; // Correct import

class ChoreListItem extends StatelessWidget {
  final Chore chore;
  final int currentUserId; // Needed to check if assigned to current user
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const ChoreListItem({
    super.key,
    required this.chore,
    required this.currentUserId,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAssignedToMe = chore.assignedUserId == currentUserId;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        chore.name,
        style: textTheme.titleMedium?.copyWith(
          // Highlight if assigned to me?
          fontWeight: isAssignedToMe ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          "Effort: ${chore.effort.displayName} | ${chore.occurrence.displayName}"
          // Add assigned user display if needed:
          // + (chore.assignedUserId != null ? " | Assigned: ${chore.assignedUsername ?? 'ID: ${chore.assignedUserId}'}" : "")
          ,
          style: textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Complete Button
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            tooltip: 'Mark as complete',
            onPressed: onComplete,
          ),
          // Delete Button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent[100]),
            tooltip: 'Delete chore',
            onPressed: onDelete,
          ),
        ],
      ),
      // You can add onTap for editing later
      // onTap: () { /* Navigate to edit screen */ },
    );
  }
}