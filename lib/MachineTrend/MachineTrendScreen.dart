import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import 'package:ma_visualization/API/ApiService.dart';

import '../MachineData/TreeMapWidgets.dart';
import '../Model/MachineTrendModel.dart';

// Function để group data theo machine
Map<String, List<MachineTrendModel>> groupByMachine(
  List<MachineTrendModel> data,
) {
  final Map<String, List<MachineTrendModel>> grouped = {};

  for (final item in data) {
    if (!grouped.containsKey(item.macId)) {
      grouped[item.macId] = [];
    }
    grouped[item.macId]!.add(item);
  }

  // Sort each group by date
  grouped.forEach((key, value) {
    value.sort((a, b) => a.monthUse.compareTo(b.monthUse));
  });

  return grouped;
}

void printGroupedData(List<MachineTrendModel> data) {
  final grouped = groupByMachine(data);

  grouped.forEach((macId, items) {
    print('🔧 Máy: $macId');
    for (final item in items) {
      print('  📅 Tháng: ${item.monthUse} | 🔢 Giá trị: ${item.act}');
    }
  });
}

Widget buildMachineChart(
  BuildContext context,
  title,
  List<MachineTrendModel> data,
) {
  final now = DateTime.now();
  final months = List.generate(12, (i) {
    final date = DateTime(now.year, now.month - 11 + i);
    final yyyymm = DateFormat('yyyyMM').format(date);
    return yyyymm;
  });

  // Tạo map từ monthUse -> MachineTrendModel
  final dataMap = {for (var e in data) e.monthUse: e};

  // Tạo list đủ 12 tháng, gán act = 0 nếu không có dữ liệu
  final fullData =
      months.map((m) {
        final d = dataMap[m];
        return MachineTrendModel(
          macId: d?.macId ?? '',
          macName: d?.macName ?? '',
          monthUse: m,
          act: d?.act ?? 0,
          ttl: d?.ttl ?? 0,
          cate: d?.macName ?? '',
          stt: d?.stt ?? 0,
        );
      }).toList();

  final total = fullData.fold(0.0, (sum, e) => sum + e.act);

  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Spacer(),
            Text(
              'Total: ${NumberFormat('#,###').format(total)}',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 8),
        Expanded(
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              labelRotation: 45,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              majorGridLines: MajorGridLines(width: 0.2),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<MachineTrendModel, String>(
                animationDuration: 500,
                dataSource: fullData,
                xValueMapper:
                    (MachineTrendModel data, _) =>
                        '${data.monthUse.substring(4, 6)}/${data.monthUse.substring(2, 4)}',
                yValueMapper: (MachineTrendModel data, _) => data.act,
                name: 'Act',
                borderRadius: BorderRadius.circular(6),
                color: Colors.blue[600],
                width: 0.5,
                dataLabelSettings: DataLabelSettings(
                  labelAlignment: ChartDataLabelAlignment.top,
                  isVisible: true,
                  textStyle: TextStyle(
                    fontSize: 18, // 👈 Tùy chỉnh kích thước nếu cần
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildMachineChart1(String title, List<MachineTrendModel> data) {
  final sortedData = List<MachineTrendModel>.from(data)
    ..sort((a, b) => a.monthUse.compareTo(b.monthUse));

  final total = sortedData.fold(0.0, (sum, e) => sum + e.act);

  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Spacer(),
            Text(
              'Total: ${NumberFormat('#,###').format(total)}',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),

        SizedBox(height: 8),
        Expanded(
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              labelRotation: 45,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              majorGridLines: MajorGridLines(width: 0.2),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<MachineTrendModel, String>(
                animationDuration: 500,
                dataSource: sortedData,
                xValueMapper:
                    (MachineTrendModel data, _) =>
                        '${data.monthUse.substring(4, 6)}/${data.monthUse.substring(2, 4)}',
                yValueMapper: (MachineTrendModel data, _) => data.act,
                name: 'Act',
                borderRadius: BorderRadius.circular(6),
                color: Colors.blue[600],
                width: 0.5,

                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Main Screen
class MachineTrendScreen extends StatefulWidget {
  @override
  _MachineTrendScreenState createState() => _MachineTrendScreenState();
}

class _MachineTrendScreenState extends State<MachineTrendScreen> {
  List<MachineTrendModel> _data = [];
  String _selectedMn = '12';
  final String _div = 'PRESS';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final monthParam = DateFormat('yyyyMM').format(now); // Lấy tháng hiện tại

      final rawData = await ApiService().fetchMachineTrend(
        month: monthParam,
        div: _div,
        mn: _selectedMn,
      );
      printGroupedData(rawData);

      setState(() {
        _data = rawData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = groupByMachine(_data);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TreeMapWidgets.buildAppBar(theme, 'Repair Fee Trend'),

      body: Column(
        children: [
          _buildFilterSection(),
          // if (_isLoading)
          //   Expanded(
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           CircularProgressIndicator(),
          //           SizedBox(height: 16),
          //           Text('Loading data...'),
          //         ],
          //       ),
          //     ),
          //   )
          // else if (_error != null)
          //   Expanded(
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          //           SizedBox(height: 16),
          //           Text(
          //             'Error loading data',
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           SizedBox(height: 8),
          //           Text(
          //             _error!,
          //             textAlign: TextAlign.center,
          //             style: TextStyle(color: Colors.grey[600]),
          //           ),
          //           SizedBox(height: 16),
          //           ElevatedButton(onPressed: _fetchData, child: Text('Retry')),
          //         ],
          //       ),
          //     ),
          //   )
          // else if (groupedData.isEmpty)
          //   Expanded(
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
          //           SizedBox(height: 16),
          //           Text(
          //             'No data available',
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.grey[600],
          //             ),
          //           ),
          //           SizedBox(height: 8),
          //           Text(
          //             'Try adjusting your filters',
          //             style: TextStyle(color: Colors.grey[500]),
          //           ),
          //         ],
          //       ),
          //     ),
          //   )
          // else
          //   Expanded(
          //     child: GridView.count(
          //       padding: EdgeInsets.all(12),
          //       crossAxisCount: 2, // số cột
          //       crossAxisSpacing: 12,
          //       mainAxisSpacing: 12,
          //       childAspectRatio: 1.4, // Điều chỉnh chiều rộng/cao của ô chart
          //       children:
          //           groupedData.entries.map((entry) {
          //             final title =
          //                 '[${entry.key}] ${entry.value.first.macName}';
          //             return buildMachineChart(context, title, entry.value);
          //           }).toList(),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    // Tính khoảng thời gian từ selectedMn đến hiện tại
    final int mn = int.tryParse(_selectedMn ?? '12') ?? 12;
    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month - mn + 1);

    // Format dates professionally
    final String startDateFormatted = DateFormat('MMM yyyy').format(startDate);
    final String endDateFormatted = DateFormat('MMM yyyy').format(now);
    final String rangeText = '$startDateFormatted - $endDateFormatted';

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Row
            _buildFilterRow(
              icon: Icons.schedule,
              iconColor: Colors.blue[600]!,
              label: 'Time Period',
              content: Row(
                children: [
                  Expanded(child: _buildCustomDropdown()),
                  SizedBox(width: 16),
                  Expanded(child: _buildDateRangeChip(rangeText)),
                  SizedBox(width: 16),
                  _buildDivisionChip(),
                ],
              ),
            ),

            // Division Row
            Spacer(),
            // Statistics Row
            if (_data.isNotEmpty) _buildStatisticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 140,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: content,
        ),
      ],
    );
  }

  Widget _buildCustomDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMn,
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          borderRadius: BorderRadius.circular(10),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[600],
            size: 20,
          ),
          onChanged: (value) {
            setState(() {
              _selectedMn = value!;
            });
            _fetchData();
          },
          items:
              [
                {
                  'value': '6',
                  'label': '6 months',
                  'icon': Icons.calendar_view_month,
                },
                {
                  'value': '12',
                  'label': '12 months',
                  'icon': Icons.calendar_today,
                },
                {'value': '18', 'label': '18 months', 'icon': Icons.date_range},
                {
                  'value': '24',
                  'label': '24 months',
                  'icon': Icons.calendar_view_week,
                },
              ].map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'] as String,
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateRangeChip(String rangeText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.date_range_outlined, color: Colors.blue[700], size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              rangeText,
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.factory_outlined, color: Colors.white, size: 12),
          ),
          SizedBox(width: 8),
          Text(
            _div,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final machineCount = groupByMachine(_data).length;
    final recordCount = _data.length;
    final totalRepairFee = _data.fold(0.0, (sum, item) => sum + item.act);

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, color: Colors.purple[600], size: 16),
            SizedBox(width: 6),
            Text(
              'Analysis Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatCard(
              icon: Icons.precision_manufacturing,
              label: 'Machines',
              value: machineCount.toString(),
              color: Colors.blue[600]!,
            ),
            SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.list_alt,
              label: 'Records',
              value: NumberFormat('#,###').format(recordCount),
              color: Colors.green[600]!,
            ),
            SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.monetization_on,
              label: 'Total Cost',
              value: NumberFormat.compactCurrency(
                symbol: '\$',
                decimalDigits: 1,
              ).format(totalRepairFee),
              color: Colors.orange[600]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
