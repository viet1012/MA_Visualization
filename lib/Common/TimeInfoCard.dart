import 'package:flutter/material.dart';

class TimeInfoCard extends StatelessWidget {
  final String finalTime;
  final String nextTime;

  const TimeInfoCard({
    super.key,
    required this.finalTime,
    required this.nextTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.update, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              const Text("Final: ", style: TextStyle(fontSize: 16)),
              Text(
                finalTime,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              const Text("Next: ", style: TextStyle(fontSize: 16)),
              Text(
                nextTime,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
