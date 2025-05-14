import 'package:flutter/material.dart';

class DesignedByText extends StatelessWidget {
  const DesignedByText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          "Designed by IT PRO",
          style: TextStyle(
            color: Colors.grey.withOpacity(0.4),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
