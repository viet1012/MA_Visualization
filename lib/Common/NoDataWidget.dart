import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final double iconSize;

  const NoDataWidget({
    Key? key,
    this.title = "No data available",
    this.message = "Please select another month or check back later.",
    this.icon = Icons.insert_chart_outlined,
    this.iconSize = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
