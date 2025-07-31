import 'package:flutter/material.dart';
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

  void _onBubbleTapped(MachineAnalysis machine) {
    setState(() {
      if (selectedMachine == machine) {
        // If same machine clicked, deselect
        selectedMachine = null;
        _animationController.reverse();
      } else {
        // Select new machine
        selectedMachine = machine;
        _animationController.forward();
      }
    });
  }

  void _closePieChart() {
    setState(() {
      selectedMachine = null;
      _animationController.reverse();
    });
  }

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

        // Pie chart overlay
        if (selectedMachine != null)
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: PieChartDetail(
                        machine: selectedMachine!,
                        numberFormat: widget.numberFormat,
                        onClose: _closePieChart,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Close button
        if (selectedMachine != null)
          Positioned(
            top: 40,
            right: 20,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _closePieChart,
                      icon: const Icon(Icons.close, color: Colors.grey),
                      iconSize: 24,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBubbleChart(Map<String, List<MachineAnalysis>> groupedData) {
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
          opacity: selectedMachine != null ? 0.3 : 0.85,
          minimumRadius: 15,
          maximumRadius: 50,
          enableTooltip: selectedMachine == null,
          color: DepartmentUtils.getDepartmentColor(div),
          borderColor: DepartmentUtils.getDepartmentColor(div).withOpacity(0.8),
          borderWidth: 2,
          gradient: getDepartmentGradient(div),
          onPointTap: (ChartPointDetails details) {
            // Handle point tap for individual bubbles
            if (details.pointIndex != null) {
              _onBubbleTapped(machines[details.pointIndex!]);
            }
          },
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
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.numberFormat.format(machine.repairFee)}\$',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
      tooltipBehavior: widget.tooltipBehavior,
      zoomPanBehavior: widget.zoomPanBehavior,
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
          color: Colors.grey[600],
          dashArray: const [5, 5],
        ),
        minorGridLines: MinorGridLines(width: 0.5, color: Colors.grey[600]),
        axisLine: AxisLine(width: 2, color: Colors.grey[600]),
        majorTickLines: MajorTickLines(
          size: 1,
          width: 1.5,
          color: Colors.grey[600],
        ),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        interval: 200,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        plotOffset: 30,
        minimum: _calculateMinX(widget.data) - 10,
        maximum: _calculateMaxX(widget.data) + 100,
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
            '$formatted',
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        },
        plotOffset: 30,
        minimum: _calculateMinY(widget.data) - 1000,
        maximum: _calculateMaxY(widget.data) + 1000,
        rangePadding: ChartRangePadding.round,
      ),
      series: seriesList,
    );
  }
}
