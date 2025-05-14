import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String text;

  const BlinkingText({super.key, required this.text});

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _opacityAnim = Tween(begin: 1.0, end: 0.4).animate(_controller);

    _colorAnim = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.blue.shade700,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (context, child) => Opacity(
            opacity: _opacityAnim.value,
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _colorAnim.value,
              ),
            ),
          ),
    );
  }
}
