import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../API/ApiService.dart';
import '../Model/MachineStopReasonModel.dart';

class MachineStopReasonScreen extends StatefulWidget {
  final String month;
  final String div;

  const MachineStopReasonScreen({
    super.key,
    required this.month,
    required this.div,
  });

  @override
  State<MachineStopReasonScreen> createState() =>
      _MachineStopReasonScreenState();
}

class _MachineStopReasonScreenState extends State<MachineStopReasonScreen> {
  final ApiService api = ApiService();
  List<MachineStopReasonModel> reasons = [];
  List<MachineStopReasonModel> detailsReasons = [];
  bool isLoading = true;

  late TooltipBehavior _tooltipBehavior;
  late TooltipBehavior _tooltipBehaviorDetails;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehaviorDetails = TooltipBehavior(enable: true);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      // Load chart 1
      final data = await api.fetchMSReason(
        month: widget.month,
        div: widget.div,
      );
      data.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      // Load chart 2
      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: 'Electronic',
      );
      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      setState(() {
        reasons = data;
        detailsReasons = detailsData;
      });
    } catch (e) {
      debugPrint('Error loading reasons: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.div} > STOP REASONS"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : (reasons.isEmpty && detailsReasons.isEmpty)
              ? const Center(child: Text('Không có dữ liệu'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Chart 1
                    Expanded(
                      child: SfCartesianChart(
                        tooltipBehavior: _tooltipBehavior,
                        title: ChartTitle(
                          text: "Main Stop Reasons",
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(fontSize: 13),
                          majorGridLines: const MajorGridLines(width: 0.3),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: "Stop Hours"),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        series: <BarSeries<MachineStopReasonModel, String>>[
                          BarSeries<MachineStopReasonModel, String>(
                            dataSource: reasons,
                            xValueMapper:
                                (data, _) => data.reason1 ?? 'Unknown',
                            yValueMapper: (data, _) => data.stopHour,
                            name: "Stop Hours",
                            color: Colors.blue.shade800,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Chart 2 (Details)
                    Expanded(
                      child: SfCartesianChart(
                        tooltipBehavior: _tooltipBehaviorDetails,
                        title: ChartTitle(
                          text: "Details Stop Reasons",
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(fontSize: 13),
                          majorGridLines: const MajorGridLines(width: 0.3),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: "Stop Hours"),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        series: <BarSeries<MachineStopReasonModel, String>>[
                          BarSeries<MachineStopReasonModel, String>(
                            dataSource: detailsReasons,
                            xValueMapper:
                                (data, _) => data.reason2 ?? 'Unknown',
                            yValueMapper: (data, _) => data.stopHour,
                            name: "Stop Hours",
                            color: Colors.orange.shade800,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
