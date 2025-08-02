import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';
import 'PieChartDetail.dart';

class BubbleChart extends StatefulWidget {
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
  State<BubbleChart> createState() => _BubbleChartState();
}

extension LogExtension on num {
  double log10() => log(this) / ln10;
}

class _BubbleChartState extends State<BubbleChart>
    with SingleTickerProviderStateMixin {
  MachineAnalysis? selectedMachine;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool showPieChart = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  double _calculateMinX(List<MachineAnalysis> data) =>
      data.map((e) => e.stopCase).reduce((a, b) => a < b ? a : b);

  double _calculateMaxX(List<MachineAnalysis> data) =>
      data.map((e) => e.stopCase).reduce((a, b) => a > b ? a : b);

  double _calculateMinY(List<MachineAnalysis> data) =>
      data.map((e) => e.stopHour).reduce((a, b) => a < b ? a : b);

  double _calculateMaxY(List<MachineAnalysis> data) =>
      data.map((e) => e.stopHour).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    // Nhóm dữ liệu theo department
    Map<String, List<MachineAnalysis>> groupedData = {};
    for (var item in widget.data) {
      if (!groupedData.containsKey(item.div)) {
        groupedData[item.div] = [];
      }
      groupedData[item.div]!.add(item);
    }

    return Stack(
      children: [
        // Main bubble chart
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return AnimatedOpacity(
              opacity: selectedMachine != null ? _fadeAnimation.value : 1.0,
              duration: const Duration(milliseconds: 500),
              child: _buildBubbleChart(groupedData),
            );
          },
        ),
      ],
    );
  }

  double getBubbleRadius(double repairFee, double minFee, double maxFee) {
    const minRadius = 15;
    const maxRadius = 50;
    if (minFee == maxFee) return (minRadius + maxRadius) / 2;

    return minRadius +
        (repairFee - minFee) * (maxRadius - minRadius) / (maxFee - minFee);
  }

  double calculateAxisInterval(
    double min,
    double max, {
    int targetTickCount = 5,
  }) {
    double range = max - min;
    if (range <= 0) return 1;

    // Ước lượng khoảng cách giữa các ticks
    double rawInterval = range / targetTickCount;

    // Làm tròn về 1 số có nghĩa
    double magnitude = pow(10, rawInterval.log10().floor()).toDouble();
    double normalized = rawInterval / magnitude;

    double rounded;
    if (normalized < 1.5) {
      rounded = 1;
    } else if (normalized < 3) {
      rounded = 2;
    } else if (normalized < 7) {
      rounded = 5;
    } else {
      rounded = 10;
    }

    return rounded * magnitude;
  }

  Widget _buildBubbleChart(Map<String, List<MachineAnalysis>> groupedData) {
    // ✅ Gộp tất cả machines vào 1 danh sách
    List<MachineAnalysis> allMachines = [];
    groupedData.forEach((div, machines) {
      allMachines.addAll(machines);
    });

    double minRepairFee = allMachines.map((e) => e.repairFee).reduce(min);
    double maxRepairFee = allMachines.map((e) => e.repairFee).reduce(max);

    double minX = _calculateMinX(widget.data);
    double maxX = _calculateMaxX(widget.data);
    double minY = _calculateMinY(widget.data);
    double maxY = _calculateMaxY(widget.data);

    double intervalX = calculateAxisInterval(minX, maxX);
    double intervalY = calculateAxisInterval(minY, maxY);

    // ✅ Tạo chỉ 1 series duy nhất
    List<BubbleSeries<MachineAnalysis, num>> seriesList = [
      BubbleSeries<MachineAnalysis, num>(
        animationDuration: 500,
        dataSource: allMachines,
        xValueMapper: (MachineAnalysis d, _) => d.stopCase,
        yValueMapper: (MachineAnalysis d, _) => d.stopHour,
        sizeValueMapper:
            (MachineAnalysis d, _) => d.repairFee, // ✅ Dùng trực tiếp
        // ✅ Màu sắc theo department
        pointColorMapper:
            (MachineAnalysis d, _) => DepartmentUtils.getDepartmentColor(d.div),
        name: 'All Machines',
        opacity: selectedMachine != null ? 0.3 : 0.85,
        minimumRadius: 15,
        maximumRadius: 50,
        enableTooltip: selectedMachine == null,
        borderWidth: 2,
        dataLabelSettings: DataLabelSettings(
          isVisible: selectedMachine == null,
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

            double radius = getBubbleRadius(
              machine.repairFee,
              minRepairFee,
              maxRepairFee,
            );
            double maxLabelWidth = radius * 3.14; // Đường kính

            return Container(
              constraints: BoxConstraints(maxWidth: maxLabelWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${machine.rank}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[300],
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    machine.macName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.numberFormat.format(machine.repairFee)}\$',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.yellow[300],
                      shadows: [
                        Shadow(
                          color: Colors.yellowAccent,
                          blurRadius: 6,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];

    return SfCartesianChart(
      plotAreaBorderWidth: 1,
      plotAreaBorderColor: Colors.grey[300],
      tooltipBehavior: widget.tooltipBehavior,
      zoomPanBehavior: widget.zoomPanBehavior,
      // ✅ Tạo custom legend cho departments
      legend: Legend(
        isVisible: false, // Tắt legend mặc định
      ),
      primaryXAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Case',
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        majorGridLines: MajorGridLines(
          width: 0.3,
          color: Colors.grey[100],
          dashArray: const [5, 5],
        ),

        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          final formatted = widget.numberFormat.format(details.value);
          return ChartAxisLabel(
            '$formatted',
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        },
        plotOffset: 30,

        // interval: 200,
        // minimum: _calculateMinX(widget.data) - 10,
        // maximum: _calculateMaxX(widget.data) + 100,
        interval: intervalX,
        minimum: minX - intervalX,
        maximum: maxX + intervalX,

        rangePadding: ChartRangePadding.round,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Stop Hour',
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        majorGridLines: MajorGridLines(
          width: 0.3,
          color: Colors.grey[100],
          dashArray: const [5, 5],
        ),
        minorGridLines: MinorGridLines(width: 0.5, color: Colors.grey[200]),
        axisLine: AxisLine(width: 1, color: Colors.grey[600]),
        majorTickLines: MajorTickLines(size: 8, width: 1.5),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          final formatted = widget.numberFormat.format(details.value);
          return ChartAxisLabel(
            formatted,
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        },
        plotOffset: 30,

        // interval: 1000,
        // minimum: _calculateMinY(widget.data) - 500,
        // maximum: _calculateMaxY(widget.data) + 3000,
        interval: intervalY,
        minimum: minY - intervalY,
        maximum: maxY + intervalY,
        rangePadding: ChartRangePadding.round,
      ),
      series: seriesList,
    );
  }
}
