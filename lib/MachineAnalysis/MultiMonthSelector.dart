import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';

class MultiMonthSelector extends StatefulWidget {
  final List<DateTime> initialSelectedMonths;
  final Function(List<DateTime>) onSelectionChanged;

  const MultiMonthSelector({
    super.key,
    this.initialSelectedMonths = const [],
    required this.onSelectionChanged,
  });

  @override
  State<MultiMonthSelector> createState() => _MultiMonthSelectorState();
}

class _MultiMonthSelectorState extends State<MultiMonthSelector> {
  late List<DateTime> _selectedMonths;

  // Tạo danh sách 12 tháng của năm hiện tại
  final int currentYear = DateTime.now().year;
  late final List<DateTime> months = List.generate(
    12,
    (i) => DateTime(currentYear, i + 1),
  );

  @override
  void initState() {
    super.initState();
    _selectedMonths = List.from(widget.initialSelectedMonths);
  }

  String _formatMonth(DateTime date) {
    return DateFormat("MMM yyyy").format(date); // ví dụ: Sep 2025
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultiSelectDialogField<DateTime>(
              items:
                  months
                      .map((m) => MultiSelectItem<DateTime>(m, _formatMonth(m)))
                      .toList(),
              title: const Text(
                "Select months",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              buttonIcon: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.blue,
              ),
              buttonText: const Text(
                "Select month",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              dialogHeight: 400,
              itemsTextStyle: const TextStyle(color: Colors.white),
              selectedItemsTextStyle: const TextStyle(color: Colors.blueAccent),
              initialValue: _selectedMonths,
              cancelText: const Text("Close"),
              confirmText: const Text("Apply"),
              onConfirm: (values) {
                setState(() {
                  _selectedMonths = values;
                });
                widget.onSelectionChanged(values);
              },
            ),
          ],
        ),
      ),
    );
  }
}
