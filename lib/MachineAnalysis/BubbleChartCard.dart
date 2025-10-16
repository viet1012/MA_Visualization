import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';
import 'MachineBubbleChart.dart';
import 'MachineBubbleScreen.dart';

class BubbleChartCard extends StatelessWidget {
  final List<MachineAnalysis> data;
  final TooltipBehavior tooltipBehavior;
  final ZoomPanBehavior zoomPanBehavior;
  final NumberFormat numberFormat;
  final void Function(String machineName)? onBubbleTap; // ✅ callback
  final void Function(AnalysisMode mode)? onModeChange;

  final String? selectedMachine;
  final AnalysisMode selectedMode; // 🔹 nhận từ parent
  final String selectedMonth;
  final String month;

  const BubbleChartCard({
    super.key,
    required this.data,
    required this.tooltipBehavior,
    required this.zoomPanBehavior,
    required this.numberFormat,
    this.onBubbleTap,
    this.onModeChange,
    this.selectedMachine,
    required this.selectedMode,
    required this.month,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .85,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 12,
        child: Stack(
          children: [
            BubbleChart(
              data: data,
              tooltipBehavior: tooltipBehavior,
              zoomPanBehavior: zoomPanBehavior,
              numberFormat: numberFormat,
              onBubbleTap: onBubbleTap, // ✅ truyền thẳng lên
              onModeChange: onModeChange,
              selectedMachine: selectedMachine,
              selectedMode: selectedMode,
              month: month,
              selectedMonth: selectedMonth,
            ),
          ],
        ),
      ),
    );
  }
}
