import 'package:flutter/material.dart';

import '../Common/BlinkingText.dart';
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
          Row(
            children: [
              ChoiceChip(
                label: const Text('Normal'),
                selected: selectedMode == AnalysisMode.normal,
                onSelected: (val) {
                  if (val) onModeChanged(AnalysisMode.normal);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.blue.shade600,
                labelStyle: TextStyle(
                  color:
                      selectedMode == AnalysisMode.normal
                          ? Colors.white
                          : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        selectedMode == AnalysisMode.normal
                            ? Colors.blue.shade600
                            : Colors.grey.shade400,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Average'),
                selected: selectedMode == AnalysisMode.average,
                onSelected: (val) {
                  if (val) onModeChanged(AnalysisMode.average);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.green.shade600,
                labelStyle: TextStyle(
                  color:
                      selectedMode == AnalysisMode.average
                          ? Colors.white
                          : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        selectedMode == AnalysisMode.average
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ],
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
                  labelBuilder: (month) => '$month Month',
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
