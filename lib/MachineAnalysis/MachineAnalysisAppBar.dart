import 'package:flutter/material.dart';

import '../Common/BlinkingText.dart';
import 'AnimatedChoiceChip.dart';
import 'DivisionFilterChips.dart';
import 'EnhancedDropdown.dart';
import 'MachineBubbleScreen.dart';

class MachineAnalysisAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AnalysisMode selectedMode;
  final ValueChanged<AnalysisMode> onModeChanged;
  final String selectedMonth;
  final ValueChanged<String?> onMonthChanged;
  final int selectedTopN;
  final ValueChanged<int?> onTopNChanged;
  final List<String> selectedDivs;
  final List<String> allDivs;
  final ValueChanged<List<String>> onDivisionChanged;

  const MachineAnalysisAppBar({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.selectedTopN,
    required this.onTopNChanged,
    required this.selectedDivs,
    required this.allDivs,
    required this.onDivisionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, size: 24),
              BlinkingText(text: "Machine Analysis"),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedChoiceChip(
                      label: 'Total',
                      icon: Icon(Icons.bar_chart, color: Colors.black),
                      isSelected: selectedMode == AnalysisMode.total,
                      onTap: () => onModeChanged(AnalysisMode.total),
                      selectedColor: Colors.blue,
                      selectedGradient: const LinearGradient(
                        colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedChoiceChip(
                      label: 'Average',
                      icon: Image.asset(
                        'assets/icon_ave.png',
                        fit: BoxFit.cover,
                      ),
                      isSelected: selectedMode == AnalysisMode.average,
                      onTap: () => onModeChanged(AnalysisMode.average),
                      selectedColor: Colors.green,
                      selectedGradient: const LinearGradient(
                        colors: [Colors.lightGreen, Colors.green],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                EnhancedDropdown<String>(
                  value: selectedMonth,
                  items: List.generate(
                    12,
                    (i) => (i + 1).toString().padLeft(2, '0'),
                  ),
                  onChanged: onMonthChanged,
                  labelBuilder: (month) {
                    final int m = int.tryParse(month) ?? 1;
                    return '$m Month${m == 1 ? '' : 's'}';
                  },
                  icon: Icons.calendar_today_rounded,
                  startColor: Colors.blueGrey.shade700,
                  endColor: Colors.blueGrey.shade900,
                  iconBackground: Colors.blue.shade600,
                ),
                const SizedBox(width: 20),
                EnhancedDropdown<int>(
                  value: selectedTopN,
                  items: List.generate(10, (i) => i + 1),
                  onChanged: onTopNChanged,
                  labelBuilder: (top) => 'Top $top',
                  icon: Icons.add_chart,
                  startColor: Colors.orange.shade600,
                  endColor: Colors.grey.shade800,
                  iconBackground: Colors.amber.shade600,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DivisionFilterChips(
              divisions: allDivs,
              selectedDivs: selectedDivs,
              onSelectionChanged: onDivisionChanged,
            ),
          ),
        ],
      ),
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
