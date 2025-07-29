import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Common/CustomTooltipWidget.dart';
import 'package:ma_visualization/Common/RepairFeeStatusHelper.dart';
import 'package:ma_visualization/Model/DetailsDataModel.dart';
import 'package:ma_visualization/Model/MachineData.dart';
import 'package:ma_visualization/Model/RepairFeeModel.dart';
import 'package:ma_visualization/Popup/DetailsDataPopup.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../API/ApiService.dart';
import '../Common/CustomLegend.dart';
import '../MachineAnalysis/MachineBubbleScreenChart.dart';
import '../MachineData/TreeMapScreen.dart';

class RepairFeeOverviewChart extends StatefulWidget {
  final List<RepairFeeModel> data;
  final String month;
  final String nameChart;

  const RepairFeeOverviewChart({
    super.key,
    required this.data,
    required this.month,
    required this.nameChart,
  });

  @override
  State<RepairFeeOverviewChart> createState() => _RepairFeeOverviewChartState();
}

class _RepairFeeOverviewChartState extends State<RepairFeeOverviewChart> {
  int? selectedIndex;
  final apiService = ApiService();
  final numberFormat = NumberFormat("##0.0");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .33,
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
                    decorationThickness: 3,
                    decoration: TextDecoration.underline,
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
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              canShowMarker: true,
              builder: (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) {
                final repairItem = data as RepairFeeModel;

                return CustomTooltipWidget(
                  item: repairItem,
                  numberFormat: numberFormat,
                  seriesName: series.name,
                  getActual: (item) => item.actual,
                  getTarget: (item) => item.target,
                  getStatus: (item) => RepairFeeStatusHelper.getStatus(item),
                  getStatusColor:
                      (status) => RepairFeeStatusHelper.getStatusColor(status),
                );
              },
            ),
            // onAxisLabelTapped: (AxisLabelTapArgs args) async {
            //   final index = widget.data.indexWhere((e) => e.title == args.text);
            //   if (index != -1) {
            //     final item = widget.data[index];
            //
            //     await showDialog(
            //       context: context,
            //       builder: (context) {
            //         return TreeMapScreen(dept: item.title, month: widget.month);
            //       },
            //     );
            //   }
            // },
            onAxisLabelTapped: (AxisLabelTapArgs args) async {
              final index = widget.data.indexWhere((e) => e.title == args.text);
              if (index != -1) {
                final item = widget.data[index];

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'View Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.grid_view,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              '${item.title} by Group',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text(
                              'View data summarized by group',
                            ),
                            onTap: () async {
                              final index = widget.data.indexWhere(
                                (e) => e.title == args.text,
                              );
                              if (index != -1) {
                                final item = widget.data[index];

                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return TreeMapScreen(
                                      dept: item.title,
                                      month: widget.month,
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              '${item.title} by Day',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text(
                              'View daily breakdown of data',
                            ),
                            onTap: () async {
                              final index = widget.data.indexWhere(
                                (e) => e.title == args.text,
                              );
                              if (index != -1) {
                                final item = widget.data[index];

                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return BubbleChartScreen(
                                      div: item.title,
                                      month: widget.month,
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        CustomLegend(
          items: [
            LegendItem(Colors.red, 'Actual > Target (Negative)'),
            LegendItem(Colors.green, 'Target Achieved'),
            LegendItem(Colors.grey, 'Target'),
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
        yValueMapper: (item, _) => item.target,
        dataLabelMapper: (item, _) => numberFormat.format(item.target),
        color: Colors.grey,
        name: 'Target',
        width: 0.5,
        spacing: 0.1,
        // 👈 khoảng cách giữa các cột trong cùng nhóm
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

        onPointTap: (ChartPointDetails details) async {
          final index = details.pointIndex ?? -1;
          final item = data[index];

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            // Gọi API để lấy dữ liệu
            List<DetailsDataModel> detailsData = await ApiService()
                .fetchDetailsDataRF(widget.month, item.title);

            // Tắt loading
            Navigator.of(context).pop();

            if (detailsData.isNotEmpty) {
              // Hiển thị popup dữ liệu
              showDialog(
                context: context,
                builder:
                    (_) => DetailsDataPopup(
                      title: widget.nameChart,
                      data: detailsData,
                    ),
              );
            } else {
              // Có thể thêm thông báo nếu không có dữ liệu
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 22.0, // Tăng kích thước font chữ
                        fontWeight: FontWeight.bold, // Tùy chọn để làm đậm
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  // Thêm khoảng cách trên/dưới
                  behavior:
                      SnackBarBehavior
                          .fixed, // Tùy chọn hiển thị phía trên thay vì ở dưới
                ),
              );
            }
          } catch (e) {
            Navigator.of(context).pop(); // Đảm bảo tắt loading nếu lỗi
            print("Error fetching data: $e");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error fetching data')));
          }
        },
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
