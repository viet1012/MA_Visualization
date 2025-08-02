import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';
import 'MachineBubbleChart.dart';

class BubbleChartCard extends StatelessWidget {
  final List<MachineAnalysis> data;
  final TooltipBehavior tooltipBehavior;
  final ZoomPanBehavior zoomPanBehavior;
  final NumberFormat numberFormat;

  const BubbleChartCard({
    super.key,
    required this.data,
    required this.tooltipBehavior,
    required this.zoomPanBehavior,
    required this.numberFormat,
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
            ),
          ],
        ),
      ),
    );
  }
}
