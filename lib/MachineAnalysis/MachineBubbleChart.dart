import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';

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
  int? selectedIndex;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool showPieChart = false;

  final GlobalKey _chartKey = GlobalKey();
  Offset? _selectedBubblePosition;

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
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    Map<String, List<MachineAnalysis>> groupedData = {};
    for (var item in widget.data) {
      if (!groupedData.containsKey(item.div)) {
        groupedData[item.div] = [];
      }
      groupedData[item.div]!.add(item);
    }

    double minRepairFee = widget.data.map((e) => e.repairFee).reduce(min);
    double maxRepairFee = widget.data.map((e) => e.repairFee).reduce(max);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return _buildBubbleChart(groupedData, minRepairFee, maxRepairFee);
          },
        ),
      ],
    );
  }

  double getBubbleRadius(double repairFee, double minFee, double maxFee) {
    const minRadius = 15; // tăng từ 15 lên 20
    const maxRadius = 50; // tăng từ 50 lên 60
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

    double rawInterval = range / targetTickCount;
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

  Widget _buildBubbleChart(
    Map<String, List<MachineAnalysis>> groupedData,
    double minRepairFee,
    double maxRepairFee,
  ) {
    List<MachineAnalysis> allMachines = [];
    groupedData.forEach((div, machines) {
      allMachines.addAll(machines);
    });

    double minX = _calculateMinX(widget.data);
    double maxX = _calculateMaxX(widget.data);
    double minY = _calculateMinY(widget.data);
    double maxY = _calculateMaxY(widget.data);

    double intervalX = calculateAxisInterval(minX, maxX);
    double intervalY = calculateAxisInterval(minY, maxY);

    List<BubbleSeries<MachineAnalysis, num>> seriesList = [
      BubbleSeries<MachineAnalysis, num>(
        onPointTap: (ChartPointDetails details) {
          final int pointIndex = details.pointIndex!;
          final machine = allMachines[pointIndex];

          final renderBox =
              _chartKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final size = renderBox.size;

            double xValue = machine.stopCase;
            double yValue = machine.stopHour;

            double xPos = (xValue - minX) / (maxX - minX) * size.width;
            double yPos =
                size.height - (yValue - minY) / (maxY - minY) * size.height;

            setState(() {
              _selectedBubblePosition = Offset(xPos, yPos);
              selectedIndex = pointIndex;
              if (selectedMachine == machine) {
                // If the same bubble is clicked again, reset selection
                selectedMachine = null;
                _animationController.reverse();
              } else {
                // Select new bubble
                selectedMachine = machine;
                _animationController.forward(from: 0.0);
              }
            });
          }
        },
        animationDuration: 500,
        dataSource: allMachines,
        xValueMapper: (MachineAnalysis d, _) => d.stopCase,
        yValueMapper: (MachineAnalysis d, _) => d.stopHour,
        sizeValueMapper: (MachineAnalysis d, _) => d.repairFee,
        pointColorMapper: (MachineAnalysis d, _) {
          Color baseColor = DepartmentUtils.getDepartmentColor(d.div);
          return selectedMachine == null || selectedMachine == d
              ? baseColor
              : baseColor.withOpacity(_fadeAnimation.value);
        },
        minimumRadius: 15,
        maximumRadius: 50,
        borderWidth: 2,
        borderColor:
            selectedMachine == null && selectedIndex == null
                ? Colors.grey.shade200
                : Colors.black12,
        name: 'All Machines',
        opacity: 1.0,
        enableTooltip: selectedMachine == null,
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

            double radius = getBubbleRadius(
              machine.repairFee,
              minRepairFee,
              maxRepairFee,
            );
            double maxLabelWidth = radius * 3.14;

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
      key: _chartKey,
      plotAreaBorderWidth: 1,
      plotAreaBorderColor: Colors.grey[300],
      tooltipBehavior: widget.tooltipBehavior,
      zoomPanBehavior: widget.zoomPanBehavior,
      legend: Legend(isVisible: false),
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
            formatted,
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        },
        plotOffset: 30,
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
        interval: intervalY,
        minimum: minY - intervalY,
        maximum: maxY + intervalY,
        rangePadding: ChartRangePadding.round,
      ),
      series: seriesList,
    );
  }
}
