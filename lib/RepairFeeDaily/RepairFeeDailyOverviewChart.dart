import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Model/RepairFeeModel.dart';
import '../API/ApiService.dart';
import '../Common/CustomLegend.dart';
import '../Common/TitleWithIndexBadge.dart';

class RepairFeeDailyOverviewChart extends StatefulWidget {
  final List<RepairFeeModel> data;
  final String month;

  const RepairFeeDailyOverviewChart({
    super.key,
    required this.data,
    required this.month,
  });

  @override
  State<RepairFeeDailyOverviewChart> createState() =>
      _RepairFeeDailyOverviewChartState();
}

class _RepairFeeDailyOverviewChartState
    extends State<RepairFeeDailyOverviewChart> {
  int? selectedIndex;
  final apiService = ApiService();
  final numberFormat = NumberFormat("##0.0");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleWithIndexBadge(index: 2, title: "Repair Fee (Daily)"),

        SizedBox(
          height: MediaQuery.of(context).size.height * .35,
          child: SfCartesianChart(
            plotAreaBorderColor: Colors.black45,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  details.text,
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationThickness: 3,
                  ),
                );
              },
            ),
            primaryYAxis: NumericAxis(
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              interval: _getInterval(widget.data),
              title: AxisTitle(
                text: 'K\$',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            series: _buildSeries(widget.data),
          ),
        ),
        const SizedBox(height: 8),
        CustomLegend(
          items: [
            LegendItem(Colors.red, 'PRESS'),
            LegendItem(Colors.green, 'MOLD'),
            LegendItem(Colors.grey, 'GUIDE'),
          ],
        ),
      ],
    );
  }

  List<CartesianSeries<RepairFeeModel, String>> _buildSeries(
    List<RepairFeeModel> data,
  ) {
    return <CartesianSeries<RepairFeeModel, String>>[
      ColumnSeries<RepairFeeModel, String>(
        animationDuration: 500,
        dataSource: data,
        xValueMapper: (item, _) => item.title,
        yValueMapper: (item, _) => item.actual,
        dataLabelMapper: (item, _) => numberFormat.format(item.actual),
        pointColorMapper:
            (item, _) => item.actual > item.target ? Colors.red : Colors.green,
        name: 'Actual',
        width: 0.5,
        spacing: 0.1,
        dataLabelSettings: const DataLabelSettings(
          labelAlignment: ChartDataLabelAlignment.top,
          isVisible: true,
          textStyle: TextStyle(
            fontSize: 18, // 👈 Tùy chỉnh kích thước nếu cần
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      ColumnSeries<RepairFeeModel, String>(
        animationDuration: 500,
        dataSource: data,
        xValueMapper: (item, _) => item.title,
        yValueMapper: (item, _) => item.target,
        dataLabelMapper: (item, _) => numberFormat.format(item.target),
        name: 'Target',
        width: 0.5,
        spacing: 0.1,
        // 👈 khoảng cách giữa các cột trong cùng nhóm
        dataLabelSettings: const DataLabelSettings(
          labelAlignment: ChartDataLabelAlignment.top,
          isVisible: true,
          textStyle: TextStyle(
            fontSize: 18, // 👈 Tùy chỉnh kích thước nếu cần
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  double _getInterval(List<RepairFeeModel> data) {
    if (data.isEmpty) return 1;

    double maxVal = data
        .map((e) => e.actual > e.target ? e.actual : e.target)
        .reduce((a, b) => a > b ? a : b);

    // Tránh chia ra 0
    final interval = (maxVal / 5).ceilToDouble();
    return interval > 0 ? interval : 1;
  }
}
