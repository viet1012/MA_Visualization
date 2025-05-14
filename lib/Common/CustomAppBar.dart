import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'BlinkingText.dart';
import 'DateDisplayWidget.dart';
import 'MonthYearDropdown.dart';
import 'TimeInfoCard.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final DateTime currentDate;
  final VoidCallback? onBack;
  final VoidCallback? onToggleTheme;
  final bool showBackButton;
  final String selectedDivision;
  final Function(String?) onDivisionChanged;

  const CustomAppBar({
    super.key,
    required this.titleText,
    required this.selectedDate,
    required this.onDateChanged,
    required this.currentDate,
    this.onBack,
    this.onToggleTheme,
    this.showBackButton = false,
    required this.selectedDivision,
    required this.onDivisionChanged,
  });

  Widget _buildDivisionSelector() {
    final divisions = ['KVH', 'PR', 'MO', 'GU'];
    return Wrap(
      spacing: 4,
      children:
          divisions.map((div) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: div,
                  groupValue: selectedDivision,
                  onChanged: onDivisionChanged,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Colors.blue,
                ),
                Text(div, style: const TextStyle(color: Colors.blue)),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('d/MMM/yyyy');
    return AppBar(
      elevation: 4,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
              : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlinkingText(text: titleText),
              const SizedBox(width: 16),
              DateDisplayWidget(
                selectedDate: selectedDate,
                monthYearDropDown: SizedBox(
                  width: 140,
                  height: 40,
                  child: MonthYearDropdown(
                    selectedDate: selectedDate,
                    onDateChanged: onDateChanged,
                  ),
                ),
              ),
            ],
          ),
          TimeInfoCard(
            finalTime: dayFormat.format(currentDate),
            nextTime: dayFormat.format(
              currentDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        _buildDivisionSelector(),
        if (onToggleTheme != null)
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
