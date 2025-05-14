import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Common/BlinkingText.dart';
import '../Common/DateDisplayWidget.dart';
import '../Common/MonthYearDropdown.dart';
import '../Common/TimeInfoCard.dart';

class CustomToolCostAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titleText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final DateTime currentDate;
  final VoidCallback? onBack;
  final VoidCallback? onToggleTheme;
  final bool showBackButton;

  const CustomToolCostAppBar({
    super.key,
    required this.titleText,
    required this.selectedDate,
    required this.onDateChanged,
    required this.currentDate,
    this.onBack,
    this.onToggleTheme,
    this.showBackButton = false,
  });

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
