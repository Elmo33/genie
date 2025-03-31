import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the theme's indicator color
    return const Center(child: CircularProgressIndicator());
  }
}