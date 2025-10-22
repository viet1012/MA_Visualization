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
  bool isLoadingMain = true;
  bool isLoadingDetails = false;
  String? selectedReason;

  late TooltipBehavior _tooltipBehavior;
  late TooltipBehavior _tooltipBehaviorDetails;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehaviorDetails = TooltipBehavior(enable: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// ✅ Load toàn bộ dữ liệu ban đầu
  Future<void> _loadData() async {
    try {
      setState(() => isLoadingMain = true);

      final data = await api.fetchMSReason(
        month: widget.month,
        div: widget.div,
      );

      // sắp xếp giảm dần stopHour
      data.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      // load all details
      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: '',
      );

      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      setState(() {
        reasons = data;
        detailsReasons = detailsData;
        selectedReason = null; // ❗ ban đầu chưa chọn lý do nào
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => isLoadingMain = false);
    }
  }

  /// ✅ Load chi tiết theo lý do cụ thể
  Future<void> _loadDetailsForReason(String? reason) async {
    try {
      setState(() {
        isLoadingDetails = true;
        selectedReason = (reason == null || reason.isEmpty) ? null : reason;
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
      debugPrint('Error loading details for $reason: $e');
    } finally {
      setState(() => isLoadingDetails = false);
    }
  }

  // 🔹 Chart wrapper với hiệu ứng sáng nhè nhẹ
  Widget _animatedGlowingCard({
    required Widget child,
    required Color glowColor,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final glow = 0.06 + (_pulseController.value * 0.04);
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1622),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: glowColor.withOpacity(0.3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(glow),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  // 🔹 Chart bên phải hiển thị chi tiết
  Widget _buildDetailsChart({Key? key}) {
    return Container(
      key: key,
      child: SfCartesianChart(
        tooltipBehavior: _tooltipBehaviorDetails,
        plotAreaBorderColor: const Color(0xFF00B4D8).withOpacity(0.06),
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(color: Color(0xFF8BA5C1)),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(color: Color(0xFF8BA5C1)),
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
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          "${widget.div} • STOP REASONS",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D9FF),
          ),
        ),
        backgroundColor: const Color(0xFF0D1622),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8BA5C1)),
            onPressed: _loadData,
          ),
        ],
      ),
      body:
          isLoadingMain
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // 🟦 Chart bên trái
                    Expanded(
                      child: _animatedGlowingCard(
                        glowColor: const Color(0xFF00D9FF),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SfCartesianChart(
                            tooltipBehavior: _tooltipBehavior,
                            primaryXAxis: CategoryAxis(
                              labelStyle: const TextStyle(
                                color: Color(0xFF8BA5C1),
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              labelStyle: const TextStyle(
                                color: Color(0xFF8BA5C1),
                              ),
                            ),
                            series: <BarSeries<MachineStopReasonModel, String>>[
                              BarSeries<MachineStopReasonModel, String>(
                                dataSource: reasons,
                                xValueMapper:
                                    (data, _) => data.reason1 ?? 'Unknown',
                                yValueMapper: (data, _) => data.stopHour,
                                pointColorMapper:
                                    (data, _) =>
                                        (data.reason1 == selectedReason)
                                            ? const Color(0xFF00FFD1)
                                            : const Color(0xFF00D9FF),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPointTap: (ChartPointDetails details) {
                                  final tapped =
                                      reasons[details.pointIndex!].reason1;
                                  _loadDetailsForReason(tapped);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // 🟧 Chart bên phải
                    Expanded(
                      child: _animatedGlowingCard(
                        glowColor: const Color(0xFF00B4D8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedReason == null
                                        ? 'DETAILS (ALL)'
                                        : 'DETAILS OF [${selectedReason!}]',
                                    style: const TextStyle(
                                      color: Color(0xFF00B4D8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _loadDetailsForReason(''),
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Color(0xFF00B4D8),
                                    ),
                                    label: const Text(
                                      'ALL',
                                      style: TextStyle(
                                        color: Color(0xFF00B4D8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child:
                                    isLoadingDetails
                                        ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF00B4D8),
                                          ),
                                        )
                                        : _buildDetailsChart(),
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
