import 'package:flutter/material.dart';

class TitleWithIndexBadge extends StatelessWidget {
  final String title;
  final int index;
  final Color badgeColor;
  final double fontSize;

  const TitleWithIndexBadge({
    super.key,
    required this.title,
    required this.index,
    this.badgeColor = const Color(0xFFE0E0E0), // Mặc định: grey.shade300
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Text(
            index.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
