import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ma_visualization/Model/MachineAnalysis.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../API/ApiService.dart';
import '../Model/ChartMSMovingAveModel.dart';
import '../Model/DetailsMSMovingAveModel.dart';
import '../Popup/DetailsDataMSMovingAvePopup.dart';
import 'DepartmentUtils.dart';

class ChartMSMovingAveScreen extends StatefulWidget {
  const ChartMSMovingAveScreen({
    super.key,
    required this.futureData,
    required this.monthFrom,
    required this.monthTo,
    required this.machineAnalysis,
  });
  final Future<List<ChartMSMovingAveModel>> futureData;
  final String monthFrom;
  final String monthTo;
  final MachineAnalysis machineAnalysis;
  @override
  State<ChartMSMovingAveScreen> createState() => _MachineStopChartScreenState();
}

class _MachineStopChartScreenState extends State<ChartMSMovingAveScreen> {
  @override
  void initState() {
    super.initState();
    print("monthFrom: ${widget.monthFrom} --- monthTo: ${widget.monthTo}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.machineAnalysis.macName} - Machine Stopping',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<ChartMSMovingAveModel>>(
        future: widget.futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SfCartesianChart(
              plotAreaBackgroundColor: Colors.black,
              backgroundColor: Colors.black,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(width: 0),
                plotBands: <PlotBand>[
                  PlotBand(
                    start: widget.monthFrom,
                    end: widget.monthTo,
                    isVisible: true,
                    color: Colors.transparent,
                    shouldRenderAboveSeries: false,
                    borderWidth: 2,
                    borderColor: Colors.redAccent,
                    dashArray: const <double>[6, 3],
                  ),
                ], // ✅ dùng list rỗng thay vì null
              ),
              primaryYAxis: NumericAxis(
                name: 'HourAxis',
                title: const AxisTitle(text: 'Hour'),
                labelStyle: const TextStyle(color: Colors.white),
                axisLine: const AxisLine(width: 0),
              ),
              axes: <ChartAxis>[
                NumericAxis(
                  name: 'CaseAxis',
                  opposedPosition: true,
                  title: const AxisTitle(text: 'Case'),
                  labelStyle: const TextStyle(color: Colors.white),
                  axisLine: const AxisLine(width: 0),
                ),
              ],
              legend: const Legend(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<ChartMSMovingAveModel, String>>[
                // Biểu đồ cột (Stop Case)
                ColumnSeries<ChartMSMovingAveModel, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.stopCase,
                  yAxisName: 'CaseAxis',
                  color: Colors.greenAccent.withOpacity(0.6),
                  name: 'Stop_Case',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  onPointTap: (ChartPointDetails details) async {
                    final index = details.pointIndex!;
                    final clickedData = data[index];
                    print(
                      "Bạn vừa click vào tháng: ${clickedData.month}, StopCase: ${clickedData.stopCase}",
                    );
                    // Ví dụ: Hiển thị dialog thông tin
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                              const Center(child: CircularProgressIndicator()),
                    );
                    final int pointIndex = details.pointIndex!;

                    try {
                      List<DetailsMSMovingAveModel> dataMS = await ApiService()
                          .fetchDetailsMSMovingAve(
                            monthFrom: clickedData.month,
                            monthTo: clickedData.month,
                            div: widget.machineAnalysis.div,
                            macName: widget.machineAnalysis.macName,
                          );

                      Navigator.of(context).pop();
                      // Color colorTitle = DepartmentUtils.getDepartmentColor(
                      //   machine.div,
                      // );

                      if (dataMS.isNotEmpty) {
                        // Hiển thị popup dữ liệu
                        showDialog(
                          context: context,
                          builder:
                              (_) => SizedBox(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DetailsDataMSMovingAvePopup(
                                        title: 'machine.macName',
                                        colorTitle: Colors.blueAccent,
                                        subTitle: 'Machine Stopping ',
                                        data: dataMS,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      }
                    } catch (e) {
                      print("❌ Lỗi gọi API: $e");
                    }
                  },
                ),
                // Biểu đồ đường (Stop Hour)
                LineSeries<ChartMSMovingAveModel, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.stopHour,
                  yAxisName: 'HourAxis',
                  color: Colors.blueAccent,
                  markerSettings: const MarkerSettings(isVisible: true),
                  name: 'Stop_Hour',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 10),
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
