import 'package:flutter/material.dart';
import 'package:genie/app/app.dart'; // Import the new App widget
import 'package:genie/core/di/injection.dart'; // Import DI configuration

Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await configureDependencies(); // Initialize DI before running the app
  // TODO: Initialize other services (Config, Logging, etc.) here
  runApp(const App()); // Run the App widget from app/app.dart
}

// The GenieApp StatelessWidget has been moved to app/app.dart