import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/DetailsDataMachineStoppingModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../API/ApiService.dart';
import '../Model/DetailsMSMovingAveModel.dart';
import '../Model/DetailsRFMovingAveModel.dart';
import '../Model/MachineAnalysis.dart';
import '../Popup/DetailsDataMSMovingAvePopup.dart';
import '../Popup/DetailsDataRFMovingAvePopup.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';
import 'MachineTileWidget.dart';
import 'RankConverter.dart';

class BubbleChart extends StatefulWidget {
  final List<MachineAnalysis> data;
  final TooltipBehavior tooltipBehavior;
  final ZoomPanBehavior zoomPanBehavior;
  final NumberFormat numberFormat;
  final void Function(String machineName)? onBubbleTap; // ✅ callback
  final void Function(AnalysisMode mode)? onModeChange;

  final String? selectedMachine;
  final AnalysisMode? selectedMode; // 🔹 nhận từ parent

  const BubbleChart({
    required this.data,
    required this.tooltipBehavior,
    required this.zoomPanBehavior,
    required this.numberFormat,
    this.onBubbleTap,
    this.onModeChange,
    this.selectedMachine,
    this.selectedMode,
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

  bool showPieChart = false;

  final GlobalKey _chartKey = GlobalKey();

  List<MachineAnalysis> allMachines = []; // ✅ giữ data ở state

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

    groupedData.forEach((div, machines) {
      print("Division: $div");
      for (var m in machines) {
        print(
          "Scale: ${m.scale}, Rank: ${m.rank}, Machine: ${m.macName}, Fee: ${m.repairFee}",
        );
      }
    });

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

  Color myColor = Colors.white;

  Color getTextColor({
    required String machineName,
    String? selectedMachine,
    Color selectedColor = Colors.white,
    Color unselectedColor = Colors.grey,
    double unselectedOpacity = 0.3,
  }) {
    if (selectedMachine == null || machineName == selectedMachine) {
      return selectedColor;
    } else {
      return unselectedColor.withOpacity(unselectedOpacity);
    }
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

    Color saturateColor(Color color) {
      HSLColor hsl = HSLColor.fromColor(color);
      return hsl
          .withSaturation((hsl.saturation + 0.6).clamp(0.0, 1.0))
          .toColor();
    }

    List<BubbleSeries<MachineAnalysis, num>> seriesList = [
      BubbleSeries<MachineAnalysis, num>(
        onPointTap: (ChartPointDetails details) async {
          if (widget.selectedMode == AnalysisMode.Total) return;

          final int pointIndex = details.pointIndex!;
          final machine = allMachines[pointIndex];
          final renderBox =
              _chartKey.currentContext?.findRenderObject() as RenderBox?;

          if (renderBox == null) return;

          if (machine.macName == widget.selectedMachine) {
            // 👉 Bấm lần 2 => reset
            // setState(() {
            //   selectedIndex = null;
            //   selectedMachine = null;
            //   _animationController.reverse();
            // });
            //
            // widget.onBubbleTap?.call(""); // gửi rỗng

            // ✅ Gọi API ngoài setState
            final range = RankConverter.convertRankToMonthRange(
              machine.rank,
              DateTime.now().year,
            );

            if (range == null) {
              print("❌ Rank không hợp lệ: ${machine.rank}");
              return;
            }
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              List<DetailsMSMovingAveModel> dataMS = await ApiService()
                  .fetchDetailsMSMovingAve(
                    monthFrom: range["monthFrom"]!,
                    monthTo: range["monthTo"]!,
                    div: machine.div,
                    macName: machine.macName,
                  );
              List<DetailsRFMovingAveModel> dataRF = await ApiService()
                  .fetchDetailsRFMovingAve(
                    monthFrom: range["monthFrom"]!,
                    monthTo: range["monthTo"]!,
                    div: machine.div,
                    macName: machine.macName,
                  );

              Navigator.of(context).pop();

              if (dataMS.isNotEmpty || dataRF.isNotEmpty) {
                // Hiển thị popup dữ liệu
                showDialog(
                  context: context,
                  builder:
                      (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DetailsDataMSMovingAvePopup(
                            title: machine.macName,
                            subTitle: 'Machine Stopping [${machine.rank}]',
                            data: dataMS,
                          ),
                          DetailsDataRFMovingAvePopup(
                            title: machine.macName,
                            subTitle: 'Repair Fee [${machine.rank}]',
                            data: dataRF,
                          ),
                        ],
                      ),
                );
              }
            } catch (e) {
              print("❌ Lỗi gọi API: $e");
            }
          } else {
            // 👉 Bấm bubble mới => chọn
            setState(() {
              selectedIndex = pointIndex;
              selectedMachine = machine;
              _animationController.forward(from: 0.0);
            });

            print(
              "selectedMachine?.macName ${selectedMachine?.macName}  machine.macName ${machine.macName}",
            );

            widget.onModeChange?.call(AnalysisMode.MovAve);
            widget.onBubbleTap?.call(machine.macName); // gửi tên machine
          }
        },

        animationDuration: 500,
        dataSource: allMachines,
        xValueMapper: (MachineAnalysis d, _) => d.stopCase,
        yValueMapper: (MachineAnalysis d, _) => d.stopHour,
        sizeValueMapper: (MachineAnalysis d, _) => d.repairFee,

        pointColorMapper: (d, _) {
          Color baseColor = DepartmentUtils.getDepartmentColor(d.div);
          Color aveColor = DepartmentUtils.getDepartmentBorderColor(d.div);

          // Nếu là AVE → giữ nguyên
          if (d.scale == "AVE") {
            return baseColor;
          }

          // Nếu là MovAve → áp dụng độ mờ theo thứ hạng
          if (d.scale.startsWith("MovAve")) {
            // Lấy số sau MovAve (vd: "MovAve3" -> 3)
            final rank = int.tryParse(d.scale.replaceAll("MovAve", "")) ?? 1;

            // Map rank (1→đậm, 5→mờ)
            // rank 1 → opacity 1.0
            // rank 5 → opacity 0.2
            double opacity = 1.0 - (rank - 1) * 0.2;
            opacity = opacity.clamp(0.2, 1.0);

            return aveColor.withOpacity(opacity);
          }

          // Trường hợp khác → giữ nguyên
          return baseColor;
        },

        minimumRadius: 15,
        maximumRadius: 50,
        borderWidth: 1,
        borderColor: Colors.grey.shade200,
        name: 'All Machines',
        opacity: 1.0,
        enableTooltip: true,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          overflowMode: OverflowMode.shift, // đẩy label tránh trùng
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

            double maxLabelWidth = radius * 3.14 * 2;

            // gán màu label dựa theo selectedMachine
            Color macNameColor = getTextColor(
              machineName: machine.macName,
              selectedMachine: widget.selectedMachine,
              selectedColor:
                  Colors.white, // 👉 bạn muốn highlight bằng màu khác
              unselectedColor: Colors.white, // 👉 màu khi không chọn
              unselectedOpacity: 0.1, // 👉 tuỳ chỉnh opacity
            );

            Color repairFeeColor = getTextColor(
              machineName: machine.macName,
              selectedMachine: widget.selectedMachine,
              selectedColor:
                  Colors.yellow, // 👉 bạn muốn highlight bằng màu khác
              unselectedColor: Colors.yellow, // 👉 màu khi không chọn
              unselectedOpacity: 0.1, // 👉 tuỳ chỉnh opacity
            );
            Color baseColor = DepartmentUtils.getDepartmentColor(d.div);
            return MachineTileWidget(
              machine: machine,
              selectedMachine: widget.selectedMachine,
              baseColor: baseColor,
              macNameColor: macNameColor,
              repairFeeColor: repairFeeColor,
              maxLabelWidth: maxLabelWidth,
              numberFormat: widget.numberFormat,
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
