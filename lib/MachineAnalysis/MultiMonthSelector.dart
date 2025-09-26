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

  GlobalKey<FormFieldState> _multiSelectKey = GlobalKey<FormFieldState>();

  // Trong onConfirm:
  void _updateSelection(List<DateTime> newSelection) {
    setState(() {
      _selectedMonths = newSelection;
    });
    widget.onSelectionChanged(newSelection);
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
              // key: _multiSelectKey,
              dialogHeight: 600,
              buttonText: const Text("Select month"),
              buttonIcon: const Icon(
                Icons.keyboard_arrow_down_outlined, // đổi thành icon bạn muốn
                color: Colors.blueAccent,
              ),
              initialValue: _selectedMonths,
              itemsTextStyle: const TextStyle(color: Colors.white),
              selectedItemsTextStyle: const TextStyle(color: Colors.blueAccent),
              cancelText: const Text(
                "CANCEL",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              confirmText: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onConfirm: (values) {
                setState(() {
                  _selectedMonths = values;
                });
                widget.onSelectionChanged(values);
              },
              // Ẩn chip mặc định
              chipDisplay: MultiSelectChipDisplay.none(),
            ),

            // Custom chip riêng
            if (_selectedMonths.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_selectedMonths.length == 1)
                    Chip(
                      label: Text(_formatMonth(_selectedMonths.first)),
                      backgroundColor: Colors.black45,
                      labelStyle: const TextStyle(color: Colors.lightBlue),
                      // onDeleted: () {
                      //   setState(() {
                      //     _selectedMonths.clear();
                      //   });
                      //   widget.onSelectionChanged(_selectedMonths);
                      // },
                    )
                  else
                    Chip(
                      label: const Text("Multi months"),
                      backgroundColor: Colors.blue.shade500,
                      labelStyle: const TextStyle(color: Colors.black),
                      // onDeleted: () {
                      //   setState(() {
                      //     _selectedMonths.clear();
                      //   });
                      //
                      //   _updateSelection([]);
                      //   widget.onSelectionChanged(_selectedMonths);
                      // },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
