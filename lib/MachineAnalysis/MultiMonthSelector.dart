import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';

class MultiMonthSelector extends StatefulWidget {
  final List<DateTime> initialSelectedMonths; // đổi sang DateTime
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
  // Tạo list tháng cho năm 2025
  final List<DateTime> months = List.generate(12, (i) => DateTime(2025, i + 1));

  late List<DateTime> _selectedMonths;

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
                "Chọn nhiều tháng",
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
                "Chọn tháng",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              dialogHeight: 400,
              itemsTextStyle: const TextStyle(
                color: Colors.white,
              ), // ✅ đổi màu chữ item trong dial
              initialValue: _selectedMonths,
              cancelText: const Text("Hủy"),
              confirmText: const Text("Xong"),
              onConfirm: (values) {
                setState(() {
                  _selectedMonths = values;
                });
                widget.onSelectionChanged(values);
              },
            ),
            // if (_selectedMonths.isNotEmpty) ...[
            //   const Text(
            //     "Đã chọn:",
            //     style: TextStyle(fontWeight: FontWeight.w600),
            //   ),
            //   const SizedBox(height: 6),
            //   Wrap(
            //     spacing: 8,
            //     runSpacing: 8,
            //     children:
            //         _selectedMonths
            //             .map(
            //               (m) => Chip(
            //                 label: Text(_formatMonth(m)),
            //                 labelStyle: const TextStyle(
            //                   fontWeight: FontWeight.w500,
            //                   color: Colors.white,
            //                 ),
            //                 backgroundColor: Colors.blue.shade400,
            //                 deleteIcon: const Icon(Icons.close, size: 16),
            //                 onDeleted: () {
            //                   setState(() {
            //                     _selectedMonths.remove(m);
            //                   });
            //                   widget.onSelectionChanged(_selectedMonths);
            //                 },
            //               ),
            //             )
            //             .toList(),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
