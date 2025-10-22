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

class _MachineStopReasonScreenState extends State<MachineStopReasonScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();
  List<MachineStopReasonModel> reasons = [];
  List<MachineStopReasonModel> detailsReasons = [];
  bool isLoading = true;
  String? selectedReason;

  late TooltipBehavior _tooltipBehavior;
  late TooltipBehavior _tooltipBehaviorDetails;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehaviorDetails = TooltipBehavior(enable: true);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      final data = await api.fetchMSReason(
        month: widget.month,
        div: widget.div,
      );
      data.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: '',
      );
      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      setState(() {
        reasons = data;
        detailsReasons = detailsData;
        selectedReason = data.isNotEmpty ? data[0].reason1 : null;
      });
    } catch (e) {
      debugPrint('Error loading reasons: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadDetailsForReason(String? reason) async {
    if (reason == null || reason.isEmpty) return;

    try {
      setState(() {
        isLoading = true;
        selectedReason = reason;
      });

      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: reason,
      );

      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      setState(() {
        detailsReasons = detailsData;
      });
    } catch (e) {
      debugPrint('Error loading details for reason $reason: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(
          "${widget.div} › SYSTEM ANALYSIS",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF58A6FF),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF161B22),
                const Color(0xFF0D1117).withOpacity(0.9),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF30363D).withOpacity(0.8),
                width: 1,
              ),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(
                        begin: 0.8,
                        end: 1.2,
                      ).animate(_pulseController),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF58A6FF),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF58A6FF),
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'INITIALIZING SYSTEM...',
                      style: TextStyle(
                        color: Color(0xFF58A6FF),
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : (reasons.isEmpty && detailsReasons.isEmpty)
              ? const Center(
                child: Text(
                  'NO DATA AVAILABLE',
                  style: TextStyle(
                    color: Color(0xFF6E7681),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Chart 1 - Main Reasons
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF30363D),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF58A6FF).withOpacity(0.05),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                '› PRIMARY METRICS',
                                style: TextStyle(
                                  color: Color(0xFF58A6FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: SfCartesianChart(
                                  tooltipBehavior: _tooltipBehavior,
                                  plotAreaBorderColor: const Color(
                                    0xFF30363D,
                                  ).withOpacity(0.5),
                                  plotAreaBorderWidth: 0.5,
                                  primaryXAxis: CategoryAxis(
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8B949E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    majorGridLines: MajorGridLines(
                                      width: 0.3,
                                      color: const Color(
                                        0xFF30363D,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: const AxisTitle(
                                      text: "HOURS",
                                      textStyle: TextStyle(
                                        color: Color(0xFF8B949E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF8B949E),
                                      fontSize: 10,
                                    ),
                                    majorGridLines: MajorGridLines(
                                      width: 0.3,
                                      color: const Color(
                                        0xFF30363D,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  series: <
                                    BarSeries<MachineStopReasonModel, String>
                                  >[
                                    BarSeries<MachineStopReasonModel, String>(
                                      dataSource: reasons,
                                      xValueMapper:
                                          (data, _) =>
                                              data.reason1 ?? 'Unknown',
                                      yValueMapper: (data, _) => data.stopHour,
                                      color: const Color(0xFF58A6FF),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(3),
                                      ),
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                            isVisible: true,
                                            textStyle: TextStyle(
                                              color: Color(0xFF58A6FF),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      onPointTap: (ChartPointDetails details) {
                                        final selectedReason =
                                            reasons[details.pointIndex!]
                                                .reason1;
                                        _loadDetailsForReason(selectedReason);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Divider
                    Container(
                      width: 1,
                      color: const Color(0xFF30363D).withOpacity(0.5),
                    ),

                    const SizedBox(width: 16),

                    // Chart 2 - Details
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF30363D),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F6FEB).withOpacity(0.05),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '› $selectedReason BREAKDOWN',
                                style: const TextStyle(
                                  color: Color(0xFF1F6FEB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: SfCartesianChart(
                                  tooltipBehavior: _tooltipBehaviorDetails,
                                  plotAreaBorderColor: const Color(
                                    0xFF30363D,
                                  ).withOpacity(0.5),
                                  plotAreaBorderWidth: 0.5,
                                  primaryXAxis: CategoryAxis(
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8B949E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    majorGridLines: MajorGridLines(
                                      width: 0.3,
                                      color: const Color(
                                        0xFF30363D,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: const AxisTitle(
                                      text: "HOURS",
                                      textStyle: TextStyle(
                                        color: Color(0xFF8B949E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF8B949E),
                                      fontSize: 10,
                                    ),
                                    majorGridLines: MajorGridLines(
                                      width: 0.3,
                                      color: const Color(
                                        0xFF30363D,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  series: <
                                    BarSeries<MachineStopReasonModel, String>
                                  >[
                                    BarSeries<MachineStopReasonModel, String>(
                                      dataSource: detailsReasons,
                                      xValueMapper:
                                          (data, _) =>
                                              data.reason2 ?? 'Unknown',
                                      yValueMapper: (data, _) => data.stopHour,
                                      color: const Color(0xFF1F6FEB),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(3),
                                      ),
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                            isVisible: true,
                                            textStyle: TextStyle(
                                              color: Color(0xFF1F6FEB),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
