import 'package:flutter/material.dart';

class WaterfallBackground extends StatefulWidget {
  final Widget child;
  final double borderWidth;

  const WaterfallBackground({
    super.key,
    required this.child,
    this.borderWidth = 1.0,
  });

  @override
  State<WaterfallBackground> createState() => _WaterfallBackgroundState();
}

class _WaterfallBackgroundState extends State<WaterfallBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _WaterfallBorderPainter(
                progress: _controller.value,
                borderWidth: widget.borderWidth,
              ),
              child: Container(
                margin: EdgeInsets.all(widget.borderWidth),
                child: widget.child,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WaterfallBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;

  _WaterfallBorderPainter({required this.progress, required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Tạo gradient trượt theo progress
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Colors.black,
        Colors.lightBlueAccent,
        Colors.white,
        Colors.blue,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      tileMode: TileMode.repeated,
    ).createShader(
      Rect.fromLTWH(
        0,
        -size.height + size.height * 2 * progress,
        size.width,
        size.height * 2,
      ),
    );

    final paint =
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    final borderRect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );

    final rrect = RRect.fromRectAndRadius(borderRect, Radius.circular(12));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterfallBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
