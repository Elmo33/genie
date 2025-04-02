import 'package:flutter/material.dart';
import 'package:genie/presentation/screens/user_settings_screen.dart'; // Import the new screen

class GenieAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GenieAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Background set in main theme
      title: const Text('Genie', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'User Settings', // Updated tooltip
          onPressed: () {
            // Navigate to the User Settings Screen
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings (coming soon)',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings coming soon!")));
          },
        ),
      ],
    );
  }
}