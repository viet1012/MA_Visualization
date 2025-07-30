import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysis.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
        fontSize: 14,
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
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '⚙️ Machine: ${data.macName}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '🔄 Stop Case: ${data.stopCase?.toInt() ?? '-'}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '⏰ Stop Hour: ${data.stopHour?.toStringAsFixed(1) ?? '-'}h',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '💰 Repair Fee: ${formattedFee}',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '🏆 Rank: #${data.rank}',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
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
    _loadData();
  }

  void _loadData() {
    final selectedString = _selectedDivs.join(',');
    setState(() {
      _futureData = ApiService().fetchMachineDataAnalysis(
        widget.month,
        selectedString,
      );
    });
  }

  // Department statistics widget
  Widget _buildDepartmentStats(List<MachineAnalysis> data) {
    Map<String, List<MachineAnalysis>> deptData = {};
    for (var item in data) {
      deptData.putIfAbsent(item.div, () => []).add(item);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Department Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    deptData.entries.map((entry) {
                      String dept = entry.key;
                      List<MachineAnalysis> machines = entry.value;

                      double totalRepairFee = machines.fold(
                        0,
                        (sum, m) => sum + m.repairFee,
                      );
                      double totalStopHour = machines.fold(
                        0,
                        (sum, m) => sum + m.stopHour,
                      );
                      int totalStopCase = machines.fold(
                        0,
                        (sum, m) => sum + m.stopCase.toInt(),
                      );

                      return Container(
                        width: 330,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: getDepartmentColor(dept).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: getDepartmentColor(dept),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: getDepartmentColor(dept),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dept,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: getDepartmentColor(dept),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${machines.length} machines',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${numberFormat.format(totalRepairFee)} repair fee',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '$totalStopCase stops • ${totalStopHour.toStringAsFixed(1)}h downtime',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getDepartmentColor(String div) {
    switch (div.toUpperCase()) {
      case 'PRESS':
        return const Color(0xFF2E7D32);
      case 'MOLD':
        return const Color(0xFF1565C0);
      case 'GUIDE':
        return const Color(0xFFE65100);
      case 'KVH':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF424242);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machine Analysis by Department"),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DivisionFilterChips(
              divisions: _divisions,
              selectedDivs: _selectedDivs,
              onSelectionChanged: (div, selected) {
                setState(() {
                  if (selected) {
                    _selectedDivs.add(div);
                  } else {
                    _selectedDivs.remove(div);
                  }
                });
                _loadData();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MachineAnalysis>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDepartmentStats(snapshot.data!),
                      Container(
                        height: MediaQuery.of(context).size.height * .8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 12,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BubbleChart(
                              data: snapshot.data!,
                              tooltipBehavior: _tooltipBehavior,
                              zoomPanBehavior: _zoomPanBehavior,
                              numberFormat: numberFormat,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
