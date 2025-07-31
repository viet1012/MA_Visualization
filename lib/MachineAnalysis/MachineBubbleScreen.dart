import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';
import '../Common/BlinkingText.dart';
import '../Common/NoDataWidget.dart';
import '../Model/MachineAnalysis.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'DepartmentStatsWidget.dart';
import 'DepartmentUtils.dart';
import 'DivisionFilterChips.dart';
import 'MachineBubbleChart.dart';

class BubbleChartScreen extends StatefulWidget {
  final String month;
  final String div;

  const BubbleChartScreen({required this.month, required this.div, super.key});

  @override
  _BubbleChartScreenState createState() => _BubbleChartScreenState();
}

class _BubbleChartScreenState extends State<BubbleChartScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late Future<List<MachineAnalysis>> _futureData;

  final List<String> _divisions = ['KVH', 'PRESS', 'MOLD', 'GUIDE'];

  List<String> _selectedDivs = [];

  final numberFormat = NumberFormat('#,###', 'en_US');

  late String _selectedMonth;

  int _selectedTopN = 10; // mặc định Top 10

  final List<int> _topOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; // tuỳ chọn top

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
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
      animationDuration: 500,
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
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏭 ${data.div} Department',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '⚙️ Machine: ${data.macName}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '🔄 Stop Case: ${data.stopCase?.toInt() ?? '-'}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '⏰ Stop Hour: ${data.stopHour?.toStringAsFixed(1) ?? '-'}h',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '💰 Repair Fee: $formattedFee\$',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '📊 Rank: #${data.rank}',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
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
    );

    _selectedDivs = [widget.div];

    _selectedMonth = '12'; // giữ giá trị ban đầu

    _loadData();
  }

  void _loadData() {
    final selectedString = _selectedDivs.join(',');
    setState(() {
      _futureData = ApiService().fetchMachineDataAnalysis(
        month: widget.month,
        div: selectedString,
        monthBack: _selectedMonth,
        topLimit: _selectedTopN,
      );
    });
  }

  void _selectMonthOnly(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthStr = month.toString().padLeft(2, '0');
            return ListTile(
              title: Text('$monthStr Month'),
              onTap:
                  () => {
                    setState(() {
                      _selectedMonth = monthStr;
                    }),
                    _loadData(),
                    Navigator.pop(context),
                  },
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedMonth = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, size: 24),
                BlinkingText(text: "Machine Analysis"),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Chọn tháng
                  InkWell(
                    onTap: () => _selectMonthOnly(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_selectedMonth Month',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Chọn Top N
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedTopN,
                        dropdownColor: Colors.grey.shade900,
                        iconEnabledColor: Colors.white,
                        items:
                            _topOptions.map((top) {
                              return DropdownMenuItem<int>(
                                value: top,
                                child: Text(
                                  'Top $top',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTopN = value;
                            });
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12,
              ),
              child: DivisionFilterChips(
                divisions: _divisions,
                selectedDivs: _selectedDivs,
                onSelectionChanged: (newSelectedDivs) {
                  setState(() {
                    _selectedDivs = newSelectedDivs;
                  });
                  _loadData();
                },
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
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

                SizedBox(
                  height: MediaQuery.of(context).size.height * .85,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 12,
                    child: BubbleChart(
                      data: snapshot.data!,
                      tooltipBehavior: _tooltipBehavior,
                      zoomPanBehavior: _zoomPanBehavior,
                      numberFormat: numberFormat,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
