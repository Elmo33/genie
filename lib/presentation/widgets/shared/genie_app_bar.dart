import 'package:flutter/material.dart';
// Consider importing user profile screen later
// import 'package:genie/presentation/screens/user_profile_screen.dart';

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
        // Placeholder actions - implement later
        IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'User Profile (coming soon)',
            onPressed: () {
              // Example: Show user score or navigate to profile
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserProfileScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User profile coming soon!"))
              );
            }
        ),
        IconButton(
            icon: const Icon(Icons.settings_outlined), // Changed icon
            tooltip: 'Settings (coming soon)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings coming soon!"))
              );
            }
        ),
      ],
    );
  }
}