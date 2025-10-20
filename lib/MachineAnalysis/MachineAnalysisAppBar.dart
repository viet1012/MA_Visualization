import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../Common/BlinkingText.dart';
import 'AnimatedChoiceChip.dart';
import 'DivisionFilterChips.dart';
import 'EnhancedDropdown.dart';
import 'MachineBubbleScreen.dart';
import 'MachineTableScreen.dart';

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
  final String month;
  final String monthBack;
  final NumberFormat numberFormat;
  final String? lastClickedMachine;

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
    required this.month,
    required this.monthBack,
    required this.numberFormat,
    required this.lastClickedMachine,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 24),
              BlinkingText(text: "Machine Analysis"),
              SizedBox(width: 10),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [Colors.redAccent, Colors.orange, Colors.yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: Text(
                  selectedMode.name == "MovAve"
                      ? "Moving Average"
                      : selectedMode.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white, // ⚠️ bắt buộc để ShaderMask apply
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),
          Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton.icon(
                  icon: const Icon(Icons.table_chart),
                  label: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.blue,
                    period: const Duration(
                      milliseconds: 1800,
                    ), // tốc độ shimmer
                    child: Text(
                      "View Table",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // màu gốc vẫn cần để giữ shape
                      ),
                    ),
                  ),
                  onPressed: () {
                    final selectedString = selectedDivs.join(',');
                    print("selectedMode:  $selectedMode");
                    showMachineTableDialog(
                      selectedMode: selectedMode,
                      div: selectedString,
                      month: month,
                      monthBack: monthBack,
                      topLimit: selectedTopN,
                      numberFormat: numberFormat,
                      context: context,
                      lastClickedMachine: lastClickedMachine,
                    );
                  },
                ),
              ),
            ],
          ),
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
                      label: 'Total\nMachines',
                      icon: Icon(Icons.bar_chart, color: Colors.black),
                      isSelected: selectedMode == AnalysisMode.Total,
                      onTap: () => onModeChanged(AnalysisMode.Total),
                      selectedColor: Colors.blue,
                      selectedGradient: const LinearGradient(
                        colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      lastClickedMachine: lastClickedMachine,
                    ),
                    const SizedBox(width: 12),
                    AnimatedChoiceChip(
                      label:
                          selectedMode == AnalysisMode.MovAve
                              ? "Moving\nAverage"
                              : "Average\nMachine",
                      icon: Icon(
                        Icons.align_vertical_center,
                        color: Colors.black,
                      ),
                      isSelected:
                          selectedMode == AnalysisMode.Average ||
                          selectedMode == AnalysisMode.MovAve,
                      onTap:
                          () => onModeChanged(
                            selectedMode == AnalysisMode.Average
                                ? AnalysisMode.MovAve
                                : AnalysisMode.Average,
                          ),
                      selectedColor: Colors.green,
                      selectedGradient:
                          selectedMode == AnalysisMode.MovAve
                              ? const LinearGradient(
                                colors: [Colors.pinkAccent, Colors.blue],
                              )
                              : const LinearGradient(
                                colors: [Colors.pinkAccent, Colors.green],
                              ),
                      lastClickedMachine: lastClickedMachine,
                      targetMode:
                          selectedMode == AnalysisMode.Average
                              ? 'MovAve'
                              : 'Average', // 👈 thêm dòng này
                    ),
                    const SizedBox(width: 12),

                    AnimatedChoiceChip(
                      label: "Average\nMonth",
                      icon: Icon(
                        Icons.align_vertical_bottom_outlined,
                        color: Colors.black,
                      ),
                      isSelected: selectedMode == AnalysisMode.MonthAve,
                      onTap: () => onModeChanged(AnalysisMode.MonthAve),
                      selectedColor: Colors.pinkAccent,
                      selectedGradient: const LinearGradient(
                        colors: [Colors.yellow, Colors.pinkAccent],
                      ),
                      lastClickedMachine: lastClickedMachine,
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
                  items: [
                    ...List.generate(10, (i) => i + 1), // 1 đến 10
                    20,
                    30,
                  ],
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
