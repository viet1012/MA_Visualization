import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MtdDateText extends StatelessWidget {
  final DateTime selectedDate;
  final bool minusOneDayIfCurrentMonth;

  const MtdDateText({
    super.key,
    required this.selectedDate,
    this.minusOneDayIfCurrentMonth = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        selectedDate.year == now.year && selectedDate.month == now.month;

    DateTime displayDate;

    if (isCurrentMonth) {
      if (minusOneDayIfCurrentMonth) {
        // Tháng hiện tại và yêu cầu lùi 1 ngày
        displayDate = DateTime(now.year, now.month, now.day - 1);
      } else {
        // Tháng hiện tại và lấy đúng ngày hiện tại
        displayDate = DateTime(now.year, now.month, now.day);
      }
    } else {
      // Tháng khác → lấy ngày cuối tháng
      final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      displayDate = nextMonth.subtract(const Duration(days: 1));
    }

    final formatted = DateFormat('d/MMM/yyyy').format(displayDate);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.date_range, size: 16, color: Colors.orange),
        const SizedBox(width: 4),
        const Text('MTD: ', style: TextStyle(fontSize: 18)),
        Text(
          formatted,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
