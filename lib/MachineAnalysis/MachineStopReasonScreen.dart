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
    try {
      setState(() {
        isLoading = true;
        selectedReason = (reason == null || reason.isEmpty) ? 'ALL' : reason;
      });

      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: reason ?? '',
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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "${widget.div} • ANALYSIS",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00D9FF),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D1622),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1622),
                const Color(0xFF0A0E27).withOpacity(0.95),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF00D9FF).withOpacity(0.15),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? _buildLoading()
              : (reasons.isEmpty && detailsReasons.isEmpty)
              ? const Center(
                child: Text(
                  'NO DATA AVAILABLE',
                  style: TextStyle(
                    color: Color(0xFF6E7681),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Chart 1 - Main
                    Expanded(child: _buildMainChart()),
                    const SizedBox(width: 20),
                    Container(
                      width: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF00D9FF),
                            const Color(0xFF00D9FF).withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Chart 2 - Details
                    Expanded(child: _buildDetailChart()),
                  ],
                ),
              ),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00D9FF), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                strokeWidth: 2.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'INITIALIZING SYSTEM',
          style: TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildMainChart() => Container(
    decoration: _chartBoxDecoration(
      color: const Color(0xFF0D1622),
      glowColor: const Color(0xFF00D9FF),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF00D9FF), const Color(0xFF0099CC)],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PRIMARY METRICS',
                style: TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              plotAreaBorderColor: const Color(0xFF00D9FF).withOpacity(0.1),
              plotAreaBorderWidth: 1,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8BA5C1),
                  fontWeight: FontWeight.w500,
                ),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: const Color(0xFF00D9FF).withOpacity(0.08),
                ),
              ),
              primaryYAxis: NumericAxis(
                title: const AxisTitle(
                  text: "HOURS",
                  textStyle: TextStyle(
                    color: Color(0xFF8BA5C1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF8BA5C1),
                  fontSize: 11,
                ),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: const Color(0xFF00D9FF).withOpacity(0.08),
                ),
              ),
              series: <BarSeries<MachineStopReasonModel, String>>[
                BarSeries<MachineStopReasonModel, String>(
                  dataSource: reasons,
                  xValueMapper: (data, _) => data.reason1 ?? 'Unknown',
                  yValueMapper: (data, _) => data.stopHour,
                  color: const Color(0xFF00D9FF),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  borderColor: const Color(0xFF0099CC),
                  borderWidth: 1,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPointTap: (ChartPointDetails details) {
                    final selectedReason = reasons[details.pointIndex!].reason1;
                    _loadDetailsForReason(selectedReason);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDetailChart() => Container(
    decoration: _chartBoxDecoration(
      color: const Color(0xFF0A0E27),
      glowColor: const Color(0xFF00D9FF).withOpacity(0.2),
      dark: true,
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00B4D8),
                          const Color(0xFF0077B6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$selectedReason DETAILS',
                    style: const TextStyle(
                      color: Color(0xFF00B4D8),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              _buildAllButton(),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehaviorDetails,
              plotAreaBorderColor: const Color(0xFF00B4D8).withOpacity(0.1),
              plotAreaBorderWidth: 1,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8BA5C1),
                  fontWeight: FontWeight.w500,
                ),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: const Color(0xFF00B4D8).withOpacity(0.08),
                ),
              ),
              primaryYAxis: NumericAxis(
                title: const AxisTitle(
                  text: "HOURS",
                  textStyle: TextStyle(
                    color: Color(0xFF8BA5C1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF8BA5C1),
                  fontSize: 11,
                ),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: const Color(0xFF00B4D8).withOpacity(0.08),
                ),
              ),
              series: <BarSeries<MachineStopReasonModel, String>>[
                BarSeries<MachineStopReasonModel, String>(
                  dataSource: detailsReasons,
                  xValueMapper: (data, _) => data.reason2 ?? 'Unknown',
                  yValueMapper: (data, _) => data.stopHour,
                  color: const Color(0xFF00B4D8),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  borderColor: const Color(0xFF0077B6),
                  borderWidth: 1,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: Color(0xFF00B4D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildAllButton() => GestureDetector(
    onTap: () => _loadDetailsForReason(''),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00B4D8).withOpacity(0.6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xFF00B4D8).withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.refresh, color: Color(0xFF00B4D8), size: 16),
          SizedBox(width: 6),
          Text(
            'ALL',
            style: TextStyle(
              color: Color(0xFF00B4D8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    ),
  );

  BoxDecoration _chartBoxDecoration({
    required Color color,
    required Color glowColor,
    bool dark = false,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: glowColor.withOpacity(0.3), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: glowColor.withOpacity(0.12),
        blurRadius: 24,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: glowColor.withOpacity(0.05),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
  );
}
