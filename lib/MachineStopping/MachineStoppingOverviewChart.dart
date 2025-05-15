import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/MachineStoppingModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Common/CustomLegend.dart';

class MachineStoppingOverviewChart extends StatefulWidget {
  final List<MachineStoppingModel> data;
  final String month;

  const MachineStoppingOverviewChart({
    super.key,
    required this.data,
    required this.month,
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
  Widget build(BuildContext context) {
    final maxY = _getMaxY(widget.data);
    final interval = _getInterval(maxY);

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .35,
          child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              canShowMarker: true,
              textStyle: TextStyle(fontSize: 20),
            ),
            plotAreaBorderColor: Colors.black45,
            primaryXAxis: CategoryAxis(
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
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              labelRotation: 45,
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
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                labelRotation: 45,
                title: AxisTitle(
                  text: 'Hour',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            series: _buildSeries(widget.data),
          ),
        ),
        const SizedBox(height: 8),
        CustomLegend(
          items: [
            LegendItem(Colors.brown, 'PRESS'),
            LegendItem(Colors.orange, 'MOLD'),
            LegendItem(Colors.purple, 'GUIDE'),
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
      'PRESS': Colors.brown,
      'MOLD': Colors.orange,
      'GUIDE': Colors.purple,
    };

    final divColorsTarget = {
      'PRESS': Colors.brown,
      'MOLD': Colors.orange,
      'GUIDE': Colors.purple,
    };

    final List<CartesianSeries<MachineStoppingModel, String>> seriesList = [];
    data = calculateMtd(data);

    final moldData = data.where((d) => d.div == 'MOLD').toList();
    for (var item in moldData) {
      print(
        'Ngày: ${DateFormat('yyyy-MM-dd').format(item.date)}, '
        'Div: ${item.div}, '
        'stopHourAct MTD: ${item.stopHourAct.toStringAsFixed(2)}, '
        'stopHourTgtMtd MTD: ${item.stopHourTgtMtd.toStringAsFixed(2)}',
      );
    }

    // Thêm các stacked column series
    for (var divName in divs) {
      final filteredData = data.where((d) => d.div == divName).toList();
      seriesList.add(
        StackedColumnSeries<MachineStoppingModel, String>(
          dataSource: filteredData,
          xValueMapper: (datum, _) => DateFormat('dd').format(datum.date),
          yValueMapper: (datum, _) => datum.stopHourAct,
          dataLabelMapper: (datum, _) => datum.stopHourAct.toStringAsFixed(0),
          name: divName,
          color: divColorsActual[divName],
          dataLabelSettings: const DataLabelSettings(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      seriesList.add(
        StackedAreaSeries<MachineStoppingModel, String>(
          dataSource: filteredData,
          yAxisName: 'AreaAxis',
          xValueMapper: (datum, _) => DateFormat('dd').format(datum.date),
          yValueMapper: (datum, _) => datum.stopHourTgtMtd,
          name: divName,
          color: divColorsTarget[divName]!.withOpacity(0.3),
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  double _getMaxY(List<MachineStoppingModel> data) {
    return data.map((e) => e.stopHourAct).fold(0.0, (a, b) => a > b ? a : b);
  }

  double _getInterval(double maxY) {
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    final interval = (maxY / 5).ceilToDouble();
    return interval > 0 ? interval : 1;
  }
}
