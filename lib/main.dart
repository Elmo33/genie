import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const GenieApp());
}

class GenieApp extends StatelessWidget {
  const GenieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}
