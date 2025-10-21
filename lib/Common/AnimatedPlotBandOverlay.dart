import 'package:flutter/material.dart';

class AnimatedPlotBandOverlay extends StatefulWidget {
  final double startVal;
  final double endVal;
  final String text;

  const AnimatedPlotBandOverlay({
    required this.startVal,
    required this.endVal,
    required this.text,
  });

  @override
  State<AnimatedPlotBandOverlay> createState() =>
      _AnimatedPlotBandOverlayState();
}

class _AnimatedPlotBandOverlayState extends State<AnimatedPlotBandOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF006E), width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF006E,
                ).withOpacity(_glowAnimation.value * 0.6),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
              BoxShadow(
                color: const Color(
                  0xFFFF006E,
                ).withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 40 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
            color: const Color(0xFF1a1a2e),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PlotBand Range',
                style: TextStyle(
                  color: const Color(0xFF00F5FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.text,
                style: TextStyle(
                  color: const Color(0xFFFF006E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(
                        0xFFFF006E,
                      ).withOpacity(_glowAnimation.value),
                      blurRadius: 10 * _glowAnimation.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
