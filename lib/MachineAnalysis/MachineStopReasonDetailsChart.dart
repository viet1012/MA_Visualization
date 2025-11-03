import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../API/ApiService.dart';
import '../Model/MachineStopReasonModel.dart';

class MachineStopReasonDetailsChart extends StatefulWidget {
  final String month;
  final String div;
  final String? selectedReason;

  const MachineStopReasonDetailsChart({
    super.key,
    required this.month,
    required this.div,
    required this.selectedReason,
  });

  @override
  State<MachineStopReasonDetailsChart> createState() =>
      _MachineStopDetailsChartState();
}

class _MachineStopDetailsChartState
    extends State<MachineStopReasonDetailsChart> {
  final ApiService api = ApiService();
  List<MachineStopReasonModel> detailsReasons = [];
  bool isLoading = true;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _loadDetails();
  }

  @override
  void didUpdateWidget(MachineStopReasonDetailsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedReason != widget.selectedReason) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    setState(() => isLoading = true);
    try {
      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: widget.selectedReason ?? '',
      );
      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));
      setState(() => detailsReasons = detailsData);
    } catch (e) {
      debugPrint('Error loading detail data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
      );
    }

    if (detailsReasons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No data available for current month",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "💡 Click a bar to view details",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return SfCartesianChart(
      tooltipBehavior: _tooltipBehavior,
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(color: Color(0xFF8BA5C1), fontSize: 16),
        isInversed: true,
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Color(0xFF8BA5C1), fontSize: 16),
      ),
      series: <BarSeries<MachineStopReasonModel, String>>[
        BarSeries<MachineStopReasonModel, String>(
          dataSource: detailsReasons,
          xValueMapper: (data, _) => data.reason2 ?? 'Unknown',
          yValueMapper: (data, _) => data.stopHour,
          color: const Color(0xFF00B4D8),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
