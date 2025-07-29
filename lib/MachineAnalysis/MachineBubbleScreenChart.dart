import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/API/ApiService.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Model/MachineAnalysis.dart';

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
  List<String> _divisions = ['PRESS', 'MOLD', 'GUIDE'];
  List<String> _selectedDivs = [];
  final numberFormat = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '', // hoặc tên máy, nhưng để trống thì focus vào nội dung
      canShowMarker: true,
      color: Colors.black87,
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.6),
      textStyle: TextStyle(
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
        final formattedAct = numberFormat.format(data.repairFee);

        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Machine: ${data.macName}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Stop Case: ${data.stopCase}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Repair Fee: ${formattedAct}K',
                style: TextStyle(color: Colors.white),
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

    _futureData = ApiService().fetchMachineDataAnalysis(
      widget.month,
      widget.div,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MachineAnalysis>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _divisions.map((div) {
                          final isSelected = _selectedDivs.contains(div);
                          return FilterChip(
                            label: Text(div),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedDivs.add(div);
                                } else {
                                  _selectedDivs.remove(div);
                                }
                                // _fetchData();
                              });
                            },
                            selectedColor: Colors.blueGrey,
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                  ),
                ),

                // Biểu đồ chính
                Container(
                  height: MediaQuery.of(context).size.height * .8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        title: ChartTitle(
                          text: '[Analysis] Repair Fee & Machine Stopping',
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        legend: Legend(isVisible: false),
                        tooltipBehavior: _tooltipBehavior,
                        zoomPanBehavior: _zoomPanBehavior,
                        primaryXAxis: NumericAxis(
                          title: AxisTitle(
                            text: 'Stop Case',
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          majorGridLines: const MajorGridLines(width: 0),
                          majorTickLines: const MajorTickLines(width: 0),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          interval: 200,
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                            text: 'Stop Hour',
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          majorGridLines: const MajorGridLines(width: 0),
                          majorTickLines: const MajorTickLines(width: 0),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          interval: 2000,
                          labelFormat: '{value}',
                        ),
                        series: <BubbleSeries<MachineAnalysis, num>>[
                          BubbleSeries<MachineAnalysis, num>(
                            animationDuration: 500,
                            dataSource: data,
                            xValueMapper: (MachineAnalysis d, _) => d.stopCase,
                            yValueMapper: (MachineAnalysis d, _) => d.stopHour,
                            sizeValueMapper:
                                (MachineAnalysis d, _) => d.repairFee,
                            opacity: 0.85,
                            minimumRadius: 12,
                            maximumRadius: 45,
                            enableTooltip: true,
                            name: 'Máy móc',
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.middle,
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              builder: (
                                dynamic d,
                                dynamic point,
                                dynamic series,
                                int pointIndex,
                                int seriesIndex,
                              ) {
                                MachineAnalysis machine = d as MachineAnalysis;
                                String shortName =
                                    machine.macName.split(' ')[0];
                                if (shortName.length > 8) {
                                  shortName = shortName.substring(0, 8);
                                }
                                return Text(
                                  textAlign: TextAlign.center,
                                  '${machine.macName}\n${numberFormat.format(machine.repairFee)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.white],
                              stops: const [0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),
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
