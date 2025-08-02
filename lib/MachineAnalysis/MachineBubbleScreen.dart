import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';
import '../Common/BlinkingText.dart';
import '../Common/NoDataWidget.dart';
import '../Model/MachineAnalysis.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'BubbleChartCard.dart';
import 'DepartmentStatsWidget.dart';
import 'DepartmentUtils.dart';
import 'DivisionFilterChips.dart';
import 'EnhancedDropdown.dart';
import 'MachineAnalysisAppBar.dart';
import 'MachineBubbleChart.dart';

class BubbleChartScreen extends StatefulWidget {
  final String month;
  final String div;

  const BubbleChartScreen({required this.month, required this.div, super.key});

  @override
  _BubbleChartScreenState createState() => _BubbleChartScreenState();
}

enum AnalysisMode { normal, average }

class _BubbleChartScreenState extends State<BubbleChartScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late Future<List<MachineAnalysis>> _futureData;

  final List<String> _divisions = ['KVH', 'PRESS', 'MOLD', 'GUIDE'];

  List<String> _selectedDivs = [];

  final numberFormat = NumberFormat('#,###', 'en_US');

  late String _selectedMonth;

  final List<String> _monthOptions = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];

  int _selectedTopN = 10; // mặc định Top 10

  final List<int> _topOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; // tuỳ chọn top

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
      shouldAlwaysShow: true, // ✅ Tooltip sẽ luôn hiển thị khi được kích hoạt
      shared: false, // ✅ Tooltip riêng biệt cho từng điểm
      duration: 0, // ✅ Không tự ẩn sau thời gian (0 = vô hạn)
      color: Colors.black87,
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.6),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      borderColor: Colors.white,
      borderWidth: 1.5,
      animationDuration:
          300, // ✅ Giảm thời gian animation để phản hồi nhanh hơn
      // ✅ Thêm activationMode để tooltip chỉ hiện khi click/tap
      activationMode: ActivationMode.singleTap, // hoặc ActivationMode.longPress
      builder: (
        dynamic data,
        ChartPoint<dynamic> point,
        ChartSeries<dynamic, dynamic> series,
        int pointIndex,
        int seriesIndex,
      ) {
        final formattedFee = numberFormat.format(data.repairFee);
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header với close button
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏭 ${data.div} Department',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // ✅ Close button (tùy chọn)
                  GestureDetector(
                    onTap: () {
                      _tooltipBehavior.hide(); // Ẩn tooltip thủ công
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '⚙️ Machine: ${data.macName}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '🔄 Stop Case: ${data.stopCase?.toInt() ?? '-'}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '⏰ Stop Hour: ${data.stopHour?.toStringAsFixed(1) ?? '-'}h',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '💰 Repair Fee: $formattedFee\$',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '📊 Rank: #${data.rank}',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
              const SizedBox(height: 8),
              // ✅ Thêm hint text
              Text(
                'Click close (×) or tap another point to hide',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      // ✅ Thêm selection zooming
      enableSelectionZooming: true,
      selectionRectBorderColor: Colors.blue,
      selectionRectBorderWidth: 2,
      selectionRectColor: Colors.blue.withOpacity(0.1),
    );

    _selectedDivs = [widget.div];

    _selectedMonth = '12'; // giữ giá trị ban đầu

    _loadData();
  }

  AnalysisMode _selectedMode = AnalysisMode.normal;

  void _loadData() {
    final selectedString = _selectedDivs.join(',');
    setState(() {
      if (_selectedMode == AnalysisMode.normal) {
        _futureData = ApiService().fetchMachineDataAnalysis(
          month: widget.month,
          div: selectedString,
          monthBack: _selectedMonth,
          topLimit: _selectedTopN,
        );
      } else {
        _futureData = ApiService().fetchMachineDataAnalysisAvg(
          month: widget.month,
          div: selectedString,
          monthBack: _selectedMonth,
          topLimit: _selectedTopN,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MachineAnalysisAppBar(
        selectedMode: _selectedMode,
        onModeChanged: (mode) {
          setState(() => _selectedMode = mode);
          _loadData();
        },
        selectedMonth: _selectedMonth,
        onMonthChanged: (month) {
          if (month != null) {
            setState(() => _selectedMonth = month);
            _loadData();
          }
        },
        selectedTopN: _selectedTopN,
        onTopNChanged: (top) {
          if (top != null) {
            setState(() => _selectedTopN = top);
            _loadData();
          }
        },
        selectedDivs: _selectedDivs,
        allDivs: _divisions,
        onDivisionChanged: (newDivs) {
          setState(() => _selectedDivs = newDivs);
          _loadData();
        },
      ),
      body: FutureBuilder<List<MachineAnalysis>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                DepartmentStatsWidget(
                  data: snapshot.data!,
                  numberFormat: numberFormat,
                ),
                BubbleChartCard(
                  data: snapshot.data!,
                  tooltipBehavior: _tooltipBehavior,
                  zoomPanBehavior: _zoomPanBehavior,
                  numberFormat: numberFormat,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
