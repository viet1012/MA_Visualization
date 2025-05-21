import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class DesignedByText extends StatelessWidget {
  const DesignedByText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        child: AnimatedTextKit(
          repeatForever: true, // Lặp vô tận
          animatedTexts: [
            TypewriterAnimatedText(
              'Designed by IT PRO',
              speed: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
