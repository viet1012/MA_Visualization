import 'dart:async';

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

  String _visibleText = '';
  Timer? _typingTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Blinking animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _opacityAnim = Tween(begin: 1.0, end: 0.4).animate(_controller);
    _colorAnim = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.blue.shade700,
    ).animate(_controller);

    // Typewriter effect
    _startTyping();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _visibleText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (context, child) => Opacity(
            opacity: _opacityAnim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(.5),
              //   borderRadius: BorderRadius.circular(8),
              //   border: Border.all(
              //     color: _colorAnim.value ?? Colors.blue,
              //     width: 2,
              //   ),
              //   boxShadow: [
              //     BoxShadow(
              //       color: (_colorAnim.value ?? Colors.blue).withOpacity(0.3),
              //       blurRadius: 8,
              //       offset: const Offset(2, 4),
              //     ),
              //   ],
              // ),
              child: Text(
                _visibleText,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _colorAnim.value,
                ),
              ),
            ),
          ),
    );
  }
}
