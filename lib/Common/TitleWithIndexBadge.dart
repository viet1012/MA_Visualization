import 'dart:math';

import 'package:flutter/material.dart';

class TitleWithIndexBadge extends StatefulWidget {
  final String title;
  final int index;
  final Color badgeColor;
  final double fontSize;

  const TitleWithIndexBadge({
    super.key,
    required this.title,
    required this.index,
    this.badgeColor = const Color(0xFFE0E0E0),
    this.fontSize = 18,
  });

  @override
  State<TitleWithIndexBadge> createState() => _TitleWithIndexBadgeState();
}

class _TitleWithIndexBadgeState extends State<TitleWithIndexBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Lặp vô hạn
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RotatingBorderPainter(_controller.value),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  widget.index.toString(),
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double rotation;

  _RotatingBorderPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * pi,
      colors: [
        Colors.blue,
        Colors.blue.withOpacity(0.1),
        Colors.blue.withOpacity(0.05),
        Colors.blue,
      ],
      stops: [0.0, 0.2, 0.8, 1.0],
      transform: GradientRotation(2 * pi * rotation),
    );

    final paint =
        Paint()
          ..shader = sweepGradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RotatingBorderPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
