import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearDropdown extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const MonthYearDropdown({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> options = List.generate(
      12,
      (index) => DateTime(now.year, now.month - index, 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: selectedDate,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent,
          ),
          // dropdownColor: Colors.black,
          items:
              options.map((date) {
                final label = DateFormat('MMM yyyy').format(date);
                return DropdownMenuItem(value: date, child: Text(label));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              onDateChanged(value);
            }
          },
        ),
      ),
    );
  }
}
