import 'dart:math'; // Keep only one import
import 'package:flutter/material.dart';
import 'package:genie/presentation/screens/chores_screen.dart'; // Adjust import

class HexagonMenu extends StatelessWidget {
  final VoidCallback? onItemTap; // Callback when any item is tapped

  const HexagonMenu({super.key, this.onItemTap});

  // Helper function to create hexagons, reducing repetition
  Widget _buildHexagon({
    required BuildContext context,
    required double dx,
    required double dy,
    required IconData icon,
    required String tooltip,
    Color color = Colors.amber,
    double size = 70,
    VoidCallback? specificOnTap, // Tap for this specific hexagon
  }) {
    return Positioned(
      // Center calculation needs adjustment for responsiveness if parent size changes
      // These are still magic numbers relative to a presumed parent size
      left: 125 - (size / 2) + dx, // Centering calculation approximation
      top: 125 - (size / 2) + dy,
      child: Tooltip( // Add tooltips for accessibility
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            specificOnTap?.call(); // Call specific tap action first
            onItemTap?.call(); // Call general tap action (like hiding the menu)
          },
          child: HexagonWidget(
            icon: icon,
            color: color,
            size: size,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Refactor layout to be responsive (e.g., using Transform.translate or a custom layout)
    return Center(
      child: SizedBox(
        width: 250, // Fixed size - not responsive
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Hexagon - Chores
            _buildHexagon(
              context: context,
              dx: 0, dy: 0,
              icon: Icons.cleaning_services, // More relevant icon
              tooltip: "View Chores",
              specificOnTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChoreScreen()),
                );
              },
            ),
            // Surrounding Hexagons - Placeholders
            _buildHexagon(context: context, dx: 0, dy: 80, icon: Icons.add, tooltip: "Placeholder 1"),
            _buildHexagon(context: context, dx: 0, dy: -80, icon: Icons.add, tooltip: "Placeholder 2"),
            _buildHexagon(context: context, dx: -69, dy: -40, icon: Icons.add, tooltip: "Placeholder 3"), // Adjusted spacing slightly
            _buildHexagon(context: context, dx: 69, dy: -40, icon: Icons.add, tooltip: "Placeholder 4"),
            _buildHexagon(context: context, dx: -69, dy: 40, icon: Icons.add, tooltip: "Placeholder 5"),
            _buildHexagon(context: context, dx: 69, dy: 40, icon: Icons.add, tooltip: "Placeholder 6"),
          ],
        ),
      ),
    );
  }
}


// --- Hexagon Widget and Clipper (Keep as before) ---
class HexagonWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const HexagonWidget({
    super.key,
    required this.icon,
    required this.color,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(size: size),
      child: Container(
        width: size,
        height: size,
        color: color,
        child: Center(
          child: Icon(icon, color: Colors.black54, size: size * 0.4), // Darker icon
        ),
      ),
    );
  }
}


class HexagonClipper extends CustomClipper<Path> {
  final double size; // Size is diameter across flat sides

  HexagonClipper({required this.size});

  @override
  Path getClip(Size size) { // Use the size passed by ClipPath
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2; // Approximation

    // Start from top point
    path.moveTo(centerX, 0);
    path.lineTo(centerX + radius * 0.866, centerY - radius * 0.5); // Top right
    path.lineTo(centerX + radius * 0.866, centerY + radius * 0.5); // Bottom right
    path.lineTo(centerX, size.height); // Bottom
    path.lineTo(centerX - radius * 0.866, centerY + radius * 0.5); // Bottom left
    path.lineTo(centerX - radius * 0.866, centerY - radius * 0.5); // Top left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant HexagonClipper oldClipper) => size != oldClipper.size;
}