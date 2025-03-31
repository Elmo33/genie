import 'package:flutter/material.dart';
import 'package:genie/presentation/screens/chat_screen.dart'; // Adjusted import

void main() {
  // Potentially initialize services or SharedPreferences here if needed globally
  runApp(const GenieApp());
}

class GenieApp extends StatelessWidget {
  const GenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Customize dark theme further if desired
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.amber
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: const ChatScreen(), // Start with the main chat/nav screen
    );
  }
}