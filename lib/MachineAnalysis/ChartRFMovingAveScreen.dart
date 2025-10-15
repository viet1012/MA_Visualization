import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../API/ApiService.dart';
import '../Model/ChartMSMovingAveModel.dart';
import '../Model/ChartRFMovingAveModel.dart';
import '../Model/DetailsMSMovingAveModel.dart';
import '../Model/DetailsRFMovingAveModel.dart';
import '../Model/MachineAnalysis.dart';
import '../Popup/DetailsDataMSMovingAvePopup.dart';
import '../Popup/DetailsDataRFMovingAvePopup.dart';
import 'DepartmentUtils.dart';

class ChartRFMovingAveScreen extends StatefulWidget {
  const ChartRFMovingAveScreen({
    super.key,
    required this.futureData,
    required this.monthFrom,
    required this.monthTo,
    required this.machineAnalysis,
  });

  final Future<List<ChartRFMovingAveModel>> futureData;
  final String monthFrom;
  final String monthTo;
  final MachineAnalysis machineAnalysis;

  @override
  State<ChartRFMovingAveScreen> createState() => _ChartRFMovingAveScreenState();
}

class _ChartRFMovingAveScreenState extends State<ChartRFMovingAveScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChartRFMovingAveModel>>(
      future: widget.futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        final data = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2.3,
            child: SfCartesianChart(
              plotAreaBackgroundColor: Colors.black,
              backgroundColor: Colors.black,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                majorGridLines: const MajorGridLines(width: 0),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  String raw = details.text.trim() ?? '';
                  if (raw.isEmpty) {
                    return ChartAxisLabel(
                      '',
                      const TextStyle(color: Colors.white, fontSize: 16),
                    );
                  }

                  String label = raw;
                  const monthNames = [
                    '',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];

                  try {
                    // --- AUTO-DETECT LOGIC ---
                    if (RegExp(r'^\d{6}$').hasMatch(raw)) {
                      // 👉 "092025" hoặc "202509"
                      String monthStr, yearStr;
                      if (raw.startsWith('20')) {
                        // dạng YYYYMM
                        yearStr = raw.substring(0, 4);
                        monthStr = raw.substring(4, 6);
                      } else {
                        // dạng MMYYYY
                        monthStr = raw.substring(0, 2);
                        yearStr = raw.substring(2, 6);
                      }
                      final month = int.tryParse(monthStr) ?? 0;
                      if (month >= 1 && month <= 12) {
                        label =
                            '${monthNames[month]}-${yearStr.substring(2)}'; // 👉 "Sep-25"
                      }
                    } else if (RegExp(r'^\d{4}-\d{2}$').hasMatch(raw)) {
                      // 👉 "2025-09"
                      final parts = raw.split('-');
                      final year = parts[0];
                      final month = int.tryParse(parts[1]) ?? 0;
                      if (month >= 1 && month <= 12) {
                        label = '${monthNames[month]}-${year.substring(2)}';
                      }
                    } else if (RegExp(r'^\d{2}-\d{4}$').hasMatch(raw)) {
                      // 👉 "09-2025"
                      final parts = raw.split('-');
                      final month = int.tryParse(parts[0]) ?? 0;
                      final year = parts[1];
                      if (month >= 1 && month <= 12) {
                        label = '${monthNames[month]}-${year.substring(2)}';
                      }
                    }
                  } catch (_) {
                    // fallback: giữ nguyên nếu lỗi
                    label = raw;
                  }
                  final labels = data.map((e) => e.month).toList();
                  int startIndex = labels.indexOf(widget.monthFrom);
                  int endIndex = labels.indexOf(widget.monthTo);

                  return ChartAxisLabel(
                    label,
                    const TextStyle(color: Colors.white),
                  );
                },
                plotBands: <PlotBand>[
                  PlotBand(
                    start: widget.monthFrom,
                    end: widget.monthTo, // tiến 1 tháng
                    isVisible: true,
                    color: Colors.transparent,
                    shouldRenderAboveSeries: false,
                    borderWidth: 2,
                    borderColor: Colors.redAccent,
                    dashArray: const <double>[6, 3],
                  ),
                ],
              ),

              primaryYAxis: NumericAxis(
                name: 'HourAxis',
                title: const AxisTitle(
                  text: 'Hour',
                  textStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                axisLine: const AxisLine(width: 0),
              ),
              axes: <ChartAxis>[
                NumericAxis(
                  name: 'CaseAxis',
                  opposedPosition: true,
                  title: const AxisTitle(
                    text: '\$',
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  axisLine: const AxisLine(width: 0),
                ),
              ],
              legend: const Legend(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 16),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                textStyle: const TextStyle(fontSize: 16),
              ),
              series: <CartesianSeries<ChartRFMovingAveModel, String>>[
                ColumnSeries<ChartRFMovingAveModel, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.repairFee,
                  yAxisName: 'CaseAxis',
                  color: Colors.greenAccent.withOpacity(0.6),
                  name: 'Repair_Fee',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPointTap: (ChartPointDetails details) async {
                    final index = details.pointIndex!;
                    final clickedData = data[index];

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      List<DetailsRFMovingAveModel> dataMS = await ApiService()
                          .fetchDetailsRFMovingAve(
                            monthFrom: clickedData.month,
                            monthTo: clickedData.month,
                            div: widget.machineAnalysis.div,
                            macName: widget.machineAnalysis.macName,
                          );

                      Navigator.of(context).pop(); // đóng loading
                      Color colorTitle = DepartmentUtils.getDepartmentColor(
                        widget.machineAnalysis.div,
                      );

                      if (dataMS.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder:
                              (_) => SizedBox(
                                child: SingleChildScrollView(
                                  child: DetailsDataRFMovingAvePopup(
                                    title: widget.machineAnalysis.macName,
                                    colorTitle: colorTitle,
                                    subTitle:
                                        'Repair Fee [${widget.machineAnalysis.rank}]',
                                    data: dataMS,
                                    maxHeight:
                                        MediaQuery.of(context).size.height * .9,
                                  ),
                                ),
                              ),
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      print("❌ Lỗi gọi API: $e");
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
