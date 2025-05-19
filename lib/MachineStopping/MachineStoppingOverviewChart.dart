import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/API/ApiService.dart';
import 'package:ma_visualization/Common/DetailsDataPopupMachineStopping.dart';
import 'package:ma_visualization/Model/DetailsDataMachineStoppingModel.dart';
import 'package:ma_visualization/Model/MachineStoppingModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Common/CustomLegend.dart';

class MachineStoppingOverviewChart extends StatefulWidget {
  final List<MachineStoppingModel> data;
  final String month;
  final String nameChart;

  const MachineStoppingOverviewChart({
    super.key,
    required this.data,
    required this.month,
    required this.nameChart,
  });

  @override
  State<MachineStoppingOverviewChart> createState() =>
      _MachineStoppingOverviewChartState();
}

class _MachineStoppingOverviewChartState
    extends State<MachineStoppingOverviewChart> {
  int? selectedIndex;
  final numberFormat = NumberFormat("##0.0");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tính max value từ dữ liệu
    final double dynamicMax =
        getMaxValueBetweenActualAndTarget(widget.data) * 1.2;

    final double roundedMax = _getInterval(dynamicMax);

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .33,
          child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              canShowMarker: true,
              textStyle: TextStyle(fontSize: 20),
            ),
            plotAreaBorderColor: Colors.black45,
            primaryXAxis: CategoryAxis(
              labelAlignment: LabelAlignment.center,
              labelPlacement: LabelPlacement.betweenTicks,
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  details.text,
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationThickness: 3,
                  ),
                );
              },
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: dynamicMax,
              interval: roundedMax,
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                final valueInThousands = (details.value / 1000).toStringAsFixed(
                  0,
                );
                return ChartAxisLabel(
                  '$valueInThousands K',
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
              title: AxisTitle(
                text: 'Hour',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            axes: [
              NumericAxis(
                name: 'AreaAxis',
                opposedPosition: true, // Y bên phải
                majorGridLines: const MajorGridLines(width: 0),
                isVisible: false,
              ),
            ],
            series: _buildSeries(widget.data),
            annotations: buildAnnotations(widget.data),
          ),
        ),
        const SizedBox(height: 8),
        CustomLegend(
          items: [
            LegendItem(Colors.blue.shade800, 'PRESS'),
            LegendItem(Colors.orange.shade800, 'MOLD'),
            LegendItem(Colors.green.shade800, 'GUIDE'),
          ],
        ),
      ],
    );
  }

  List<MachineStoppingModel> calculateMtd(List<MachineStoppingModel> input) {
    final result = <MachineStoppingModel>[];

    if (input.isEmpty) return result;

    final sorted = input.toList()..sort((a, b) => a.date.compareTo(b.date));

    final divs = sorted.map((e) => e.div).toSet(); // lấy tất cả các div

    final startDate = sorted.first.date;
    final endDate = sorted.last.date;

    for (final div in divs) {
      final itemsByDiv = sorted.where((e) => e.div == div).toList();
      final dataByDate = <String, MachineStoppingModel>{
        for (var item in itemsByDiv)
          DateFormat('yyyy-MM-dd').format(item.date): item,
      };

      var actMtd = 0.0;
      var tgtMtd = 0.0;

      for (
        var d = startDate;
        !d.isAfter(endDate);
        d = d.add(const Duration(days: 1))
      ) {
        final dateKey = DateFormat('yyyy-MM-dd').format(d);
        final item = dataByDate[dateKey];

        if (item != null) {
          // Nếu có dữ liệu ngày này thì cộng dồn
          actMtd += item.stopHourAct;
          tgtMtd += item.stopHourTgtMtd;
          result.add(
            item.copyWith(stopHourAct: actMtd, stopHourTgtMtd: tgtMtd),
          );
        } else {
          // Nếu không có thì thêm bản ghi giữ nguyên MTD
          result.add(
            MachineStoppingModel(
              stopHourAct: actMtd,
              stopHourTgtMtd: tgtMtd,
              countDay: 0,
              div: div,
              date: d,
              wdOffice: 0,
              stopHourTgt: 0,
            ),
          );
        }
      }
    }

    return result..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CartesianSeries<MachineStoppingModel, String>> _buildSeries(
    List<MachineStoppingModel> data,
  ) {
    final divs = ['PRESS', 'MOLD', 'GUIDE'];
    final divColorsActual = {
      'PRESS': Colors.blue.shade800,
      'MOLD': Colors.orange.shade800,
      'GUIDE': Colors.green.shade800,
    };

    final divColorsTarget = {
      'PRESS': Colors.blueAccent,
      'MOLD': Colors.orange,
      'GUIDE': Colors.green,
    };

    final List<CartesianSeries<MachineStoppingModel, String>> seriesList = [];

    data = calculateMtd(data);

    // 👇 Lọc dữ liệu chỉ đến ngày hôm nay
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final filteredDataToToday =
        data.where((e) {
          final eDate = DateTime(e.date.year, e.date.month, e.date.day);
          return !eDate.isAfter(todayDate);
        }).toList();

    // 🟦 1. Add toàn bộ StackedAreaSeries TRƯỚC
    for (var divName in divs) {
      final filteredData = data.where((d) => d.div == divName).toList();

      seriesList.add(
        StackedAreaSeries<MachineStoppingModel, String>(
          dataSource: filteredData,
          yAxisName: 'AreaAxis',
          xValueMapper: (datum, _) => DateFormat('dd').format(datum.date),
          yValueMapper: (datum, _) => datum.stopHourTgtMtd,
          name: divName,
          gradient: LinearGradient(
            colors: [
              divColorsTarget[divName]!.withOpacity(0.5),
              divColorsActual[divName]!.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: divColorsActual[divName]!.withOpacity(.8),
          borderWidth: 1,
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    // 🟧 2. Add toàn bộ StackedColumnSeries SAU
    for (var divName in divs) {
      final filteredData =
          filteredDataToToday.where((d) => d.div == divName).toList();

      seriesList.add(
        StackedColumnSeries<MachineStoppingModel, String>(
          dataSource: filteredData,
          xValueMapper: (datum, _) => DateFormat('dd').format(datum.date),
          yValueMapper: (datum, _) => datum.stopHourAct,
          dataLabelMapper: (datum, _) => datum.stopHourAct.toStringAsFixed(0),
          name: divName,
          width: .4,
          color: divColorsActual[divName],
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
              String month = DateFormat('yyyy-MM-dd').format(item.date);

              // Gọi API để lấy dữ liệu
              List<DetailsDataMachineStoppingModel> detailsData =
                  await ApiService().fetchDetailsDataMS(month);

              // Tắt loading
              Navigator.of(context).pop();

              if (detailsData.isNotEmpty) {
                // Hiển thị popup dữ liệu
                showDialog(
                  context: context,
                  builder:
                      (_) => DetailsDataPopupMachineStopping(
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
      );
    }

    return seriesList;
  }

  List<CartesianChartAnnotation> buildAnnotations(
    List<MachineStoppingModel> data,
  ) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    data = calculateMtd(data);

    // Lọc dữ liệu đến hôm nay
    final filtered = data.where((d) => !d.date.isAfter(todayDate)).toList();

    // Nhóm theo ngày (yyyy-MM-dd để tránh trùng) và tính tổng Actual cho mỗi ngày
    final Map<String, double> dailySum = {};
    for (var item in filtered) {
      final key = DateFormat('yyyy-MM-dd').format(item.date);
      dailySum[key] = (dailySum[key] ?? 0) + item.stopHourAct;
    }

    // Giờ thì sẽ tạo annotation như cũ, dựa trên grouped list
    // (nếu vẫn cần hiển thị từng ngày)
    final annotations = <CartesianChartAnnotation>[];
    dailySum.forEach((dateKey, sum) {
      final dayLabel = DateFormat('dd').format(DateTime.parse(dateKey));
      annotations.add(
        CartesianChartAnnotation(
          widget: Text(
            (sum / 1000).toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          coordinateUnit: CoordinateUnit.point,
          region: AnnotationRegion.chart,
          x: dayLabel,
          y: sum * 1.1, // đặt annotation cao hơn đúng tầm
        ),
      );
    });

    return annotations;
  }

  double _getInterval(double maxY) {
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    final interval = (maxY / 6).ceilToDouble();
    return interval > 0 ? interval : 1;
  }

  double getMaxValueBetweenActualAndTarget(List<MachineStoppingModel> rawData) {
    rawData = calculateMtd(rawData);

    final actualMax = _getMaxDailyActualSum(rawData);
    final targetMax = _getMaxDailyTargetSum(rawData);

    return actualMax > targetMax ? actualMax : targetMax;
  }

  /// Trả về giá trị lớn nhất của tổng stopHourAct trên mỗi ngày (từ đầu tháng đến hôm nay)
  double _getMaxDailyActualSum(List<MachineStoppingModel> rawData) {
    // 2. Lọc đến ngày hiện tại
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final filtered =
        rawData.where((d) {
          final dDate = DateTime(d.date.year, d.date.month, d.date.day);
          return !dDate.isAfter(todayDate);
        }).toList();

    // 3. Gom nhóm theo ngày và cộng Actual
    final Map<String, double> dailySum = {};
    for (var item in filtered) {
      final key = DateFormat('yyyy-MM-dd').format(item.date);
      dailySum[key] = (dailySum[key] ?? 0) + item.stopHourAct;
    }

    // 4. Tìm max
    final maxSum = dailySum.values.fold<double>(
      0.0,
      (prev, curr) => curr > prev ? curr : prev,
    );

    return maxSum;
  }

  double _getMaxDailyTargetSum(List<MachineStoppingModel> rawData) {
    final now = DateTime.now();
    final firstDayNextMonth =
        (now.month < 12)
            ? DateTime(now.year, now.month + 1, 1)
            : DateTime(now.year + 1, 1, 1);
    final lastDayOfMonth = firstDayNextMonth.subtract(Duration(days: 1));

    // So sánh theo ngày (bỏ giờ phút)
    final targetDate = DateTime(
      lastDayOfMonth.year,
      lastDayOfMonth.month,
      lastDayOfMonth.day,
    );

    // Lọc các dòng đúng ngày cuối tháng
    final endOfMonthData = rawData.where((item) {
      final itemDate = DateTime(item.date.year, item.date.month, item.date.day);
      return itemDate == targetDate;
    });

    // Cộng lại nếu có nhiều bản ghi cùng ngày
    return endOfMonthData.fold<double>(
      0.0,
      (sum, item) => sum + item.stopHourTgtMtd,
    );
  }
}
