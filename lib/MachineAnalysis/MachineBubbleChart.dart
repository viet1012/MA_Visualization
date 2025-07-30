import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';

class BubbleChart extends StatelessWidget {
  final List<MachineAnalysis> data;
  final TooltipBehavior tooltipBehavior;
  final ZoomPanBehavior zoomPanBehavior;
  final NumberFormat numberFormat;

  const BubbleChart({
    required this.data,
    required this.tooltipBehavior,
    required this.zoomPanBehavior,
    required this.numberFormat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 1,
      title: ChartTitle(
        text: '[Analysis] Repair Fee & Machine Stopping',
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      legend: Legend(isVisible: false),
      tooltipBehavior: tooltipBehavior,
      zoomPanBehavior: zoomPanBehavior,
      primaryXAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Case',
          alignment: ChartAlignment.far,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        interval: 200,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Hour',
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        interval: 2000,
        labelFormat: '{value}',
      ),
      series: <BubbleSeries<MachineAnalysis, num>>[
        BubbleSeries<MachineAnalysis, num>(
          animationDuration: 500,
          dataSource: data,
          xValueMapper: (MachineAnalysis d, _) => d.stopCase,
          yValueMapper: (MachineAnalysis d, _) => d.stopHour,
          sizeValueMapper: (MachineAnalysis d, _) => d.repairFee,
          opacity: 0.85,
          minimumRadius: 12,
          maximumRadius: 45,
          enableTooltip: true,
          name: 'Máy móc',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.middle,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            builder: (
              dynamic d,
              dynamic point,
              dynamic series,
              int pointIndex,
              int seriesIndex,
            ) {
              MachineAnalysis machine = d as MachineAnalysis;
              return Text(
                textAlign: TextAlign.center,
                '${machine.macName}\n${numberFormat.format(machine.repairFee)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ],
                ),
              );
            },
          ),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            stops: [0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }
}
