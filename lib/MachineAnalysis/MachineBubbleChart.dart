import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';

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

  // Tạo gradient cho từng department
  LinearGradient getDepartmentGradient(String div) {
    Color baseColor = DepartmentUtils.getDepartmentColor(div);
    return LinearGradient(
      colors: [baseColor, baseColor.withOpacity(0.3)],
      stops: const [0.3, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nhóm dữ liệu theo department
    Map<String, List<MachineAnalysis>> groupedData = {};
    for (var item in data) {
      if (!groupedData.containsKey(item.div)) {
        groupedData[item.div] = [];
      }
      groupedData[item.div]!.add(item);
    }

    groupedData.forEach((div, list) {
      print('Dept $div: ${list.length} machines');
      for (var machine in list) {
        print(
          '  - ${machine.macName}: Stop=${machine.stopCase}, Hour=${machine.stopHour}, Fee=${machine.repairFee}',
        );
      }
    });

    // Tạo danh sách series cho từng department
    List<BubbleSeries<MachineAnalysis, num>> seriesList = [];

    groupedData.forEach((div, machines) {
      seriesList.add(
        BubbleSeries<MachineAnalysis, num>(
          animationDuration: 500,
          dataSource: machines,
          xValueMapper: (MachineAnalysis d, _) => d.stopCase,
          yValueMapper: (MachineAnalysis d, _) => d.stopHour,
          sizeValueMapper: (MachineAnalysis d, _) => d.repairFee,
          name: div,
          // opacity: 0.85,
          minimumRadius: 15,
          maximumRadius: 50,
          enableTooltip: true,
          color: DepartmentUtils.getDepartmentColor(div),
          borderColor: DepartmentUtils.getDepartmentColor(div).withOpacity(0.8),
          borderWidth: 2,
          gradient: getDepartmentGradient(div),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.middle,
            builder: (
              dynamic d,
              dynamic point,
              dynamic series,
              int pointIndex,
              int seriesIndex,
            ) {
              MachineAnalysis machine = d as MachineAnalysis;
              String shortName =
                  machine.macName.length > 10
                      ? '${machine.macName.substring(0, 8)}..'
                      : machine.macName;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shortName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      numberFormat.format(machine.repairFee),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellow[300],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });

    return SfCartesianChart(
      plotAreaBorderWidth: 1,
      plotAreaBorderColor: Colors.grey[300],
      backgroundColor: Colors.grey[50],

      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        iconHeight: 15,
        iconWidth: 15,
        itemPadding: 8,
        // Custom legend items với màu sắc department
        legendItemBuilder: (
          String name,
          dynamic series,
          dynamic point,
          int seriesIndex,
        ) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: DepartmentUtils.getDepartmentColor(name),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DepartmentUtils.getDepartmentColor(name),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      tooltipBehavior: tooltipBehavior,
      zoomPanBehavior: zoomPanBehavior,
      primaryXAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Case (Number of Stops)',
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        majorGridLines: MajorGridLines(
          width: 0.8,
          color: Colors.grey[600],
          dashArray: const [5, 5],
        ),
        minorGridLines: MinorGridLines(width: 0.5, color: Colors.grey[600]),
        axisLine: AxisLine(width: 2, color: Colors.grey[600]),
        majorTickLines: MajorTickLines(
          size: 8,
          width: 1.5,
          color: Colors.grey[600],
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        interval: 200,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Hour (Hours)',
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        majorGridLines: MajorGridLines(
          width: 0.8,
          color: Colors.grey[300],
          dashArray: const [5, 5],
        ),
        minorGridLines: MinorGridLines(width: 0.5, color: Colors.grey[200]),
        axisLine: AxisLine(width: 2, color: Colors.grey[600]),
        majorTickLines: MajorTickLines(
          size: 8,
          width: 1.5,
          color: Colors.grey[600],
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        interval: 1000,
        labelFormat: '{value}h',
      ),
      series: seriesList,
    );
  }
}
