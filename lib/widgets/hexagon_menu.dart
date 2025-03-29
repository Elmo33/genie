import 'dart:math';
import 'package:flutter/material.dart';

class HexagonMenu extends StatefulWidget {
  const HexagonMenu({super.key});

  @override
  State<HexagonMenu> createState() => _HexagonMenuState();
}

class _HexagonMenuState extends State<HexagonMenu>
    with SingleTickerProviderStateMixin {
  bool isHidden = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          HexagonWidget(icon: Icons.smart_toy, color: Colors.blueAccent),
          ...List.generate(6, (i) {
            final angle = pi / 3 * i;
            final offset = Offset(cos(angle), sin(angle)) * 80;
            return Positioned(
              left: offset.dx + MediaQuery.of(context).size.width / 2 - 40,
              top: offset.dy + 100,
              child: HexagonWidget(
                icon: Icons.add, // explicitly place "+" everywhere initially for clarity
                color: Colors.grey[850]!,
              ),
            );
          }),

        ],
      ),
    );
  }

}

class HexagonWidget extends StatelessWidget {
  final IconData? icon;
  final Color color;

  const HexagonWidget({super.key, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 70,
        height: 70,
        color: color,
        child: icon != null
            ? Center(child: Icon(icon, color: Colors.white70, size: 30))
            : null,
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
