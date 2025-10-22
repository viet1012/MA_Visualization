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
  List<MachineStopReasonModel> prevDetailsReasons = [];
  bool isLoadingMain = true;
  bool isLoadingDetails = false;
  bool isCompareMode = false; // 🔹 trạng thái bật/tắt phân tích
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
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getPreviousMonth(String currentMonth) {
    final year = int.parse(currentMonth.substring(0, 4));
    final month = int.parse(currentMonth.substring(4));
    final prev =
        month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1);
    return "${prev.year}${prev.month.toString().padLeft(2, '0')}";
  }

  /// ✅ Load toàn bộ dữ liệu ban đầu
  Future<void> _loadData() async {
    try {
      setState(() => isLoadingMain = true);

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
        prevDetailsReasons = []; // ❌ chưa gọi tháng trước ở đây
        selectedReason = null;
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

      // 🔹 Chỉ load chi tiết tháng hiện tại thôi
      final detailsData = await api.fetchDetailsMSReason(
        month: widget.month,
        div: widget.div,
        inputReason: reason ?? '',
      );
      detailsData.sort((a, b) => b.stopHour.compareTo(a.stopHour));

      setState(() {
        detailsReasons = detailsData;
        // ❌ Không load tháng trước nữa
        prevDetailsReasons = [];
      });
    } catch (e) {
      debugPrint('Error loading details: $e');
    } finally {
      setState(() => isLoadingDetails = false);
    }
  }

  // 🔹 Thẻ có hiệu ứng sáng
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

  Widget _buildAnalysisSummary() {
    if (!isCompareMode || reasons.isEmpty || prevDetailsReasons.isEmpty) {
      return const SizedBox.shrink();
    }

    // 🔹 Tổng giờ dừng và số case
    final totalCurrentHours = reasons.fold<double>(
      0,
      (sum, e) => sum + e.stopHour,
    );
    final totalPrevHours = prevDetailsReasons.fold<double>(
      0,
      (sum, e) => sum + e.stopHour,
    );

    final totalCurrentCases = reasons.fold<int>(
      0,
      (sum, e) => sum + e.stopCase,
    );
    final totalPrevCases = prevDetailsReasons.fold<int>(
      0,
      (sum, e) => sum + e.stopCase,
    );

    double calcPercent(double current, double prev) {
      if (prev == 0) return 0;
      return ((current - prev) / prev) * 100;
    }

    final percentHour = calcPercent(totalCurrentHours, totalPrevHours);
    final percentCase = calcPercent(
      totalCurrentCases.toDouble(),
      totalPrevCases.toDouble(),
    );

    final diff = totalCurrentHours - totalPrevHours;
    final trendColor = diff >= 0 ? Colors.redAccent : Colors.greenAccent;
    final overallTrend = diff >= 0 ? "INCREASING" : "DECREASING";

    // 🔹 Map tháng trước theo reason
    final Map<String, double> prevMap = {
      for (var e in prevDetailsReasons) e.reason1 ?? 'Unknown': e.stopHour,
    };

    // 🔹 Tính thay đổi từng lý do
    final List<Map<String, dynamic>> changes = [];
    for (var e in reasons) {
      final prevValue = prevMap[e.reason1 ?? 'Unknown'] ?? 0;
      final delta = e.stopHour - prevValue;
      if (delta.abs() > 0.01) {
        changes.add({
          'reason': e.reason1 ?? 'Unknown',
          'delta': delta,
          'percent': prevValue == 0 ? 100.0 : (delta / prevValue) * 100,
        });
      }
    }

    // 🔹 Top tăng & giảm
    changes.sort((a, b) => b['delta'].compareTo(a['delta']));
    final topIncrease = changes.where((e) => e['delta'] > 0).take(3).toList();
    final topDecrease = changes.where((e) => e['delta'] < 0).take(3).toList();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1622),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 ANALYSIS SUMMARY",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Bảng so sánh 2 cột × 2 hàng
          Table(
            border: TableBorder.all(color: Colors.cyanAccent.withOpacity(0.2)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xFF132031)),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Metric",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Current",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Previous",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Change (%)",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Stop Hours",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${totalCurrentHours.toStringAsFixed(1)}h",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${totalPrevHours.toStringAsFixed(1)}h",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${percentHour >= 0 ? '+' : ''}${percentHour.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color:
                            percentHour >= 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Stop Cases",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "$totalCurrentCases",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "$totalPrevCases",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${percentCase >= 0 ? '+' : ''}${percentCase.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color:
                            percentCase >= 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            "Overall Trend: $overallTrend",
            style: TextStyle(
              color: trendColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Divider(height: 16, color: Colors.cyanAccent, thickness: 0.3),

          // 🔺 Top tăng mạnh
          if (topIncrease.isNotEmpty) ...[
            const Text(
              "🔺 Top 3 Increasing Reasons",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (var e in topIncrease)
              Text(
                "• ${e['reason']} (+${e['delta'].toStringAsFixed(1)}h, ${e['percent'].toStringAsFixed(1)}%)",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
          ],
          const SizedBox(height: 8),

          // 🔻 Top giảm mạnh
          if (topDecrease.isNotEmpty) ...[
            const Text(
              "🔻 Top 3 Decreasing Reasons",
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (var e in topDecrease)
              Text(
                "• ${e['reason']} (${e['delta'].toStringAsFixed(1)}h, ${e['percent'].toStringAsFixed(1)}%)",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
          ],
        ],
      ),
    );
  }

  /// 🔸 Biểu đồ chi tiết (tháng hiện tại hoặc so sánh)
  Widget _buildDetailsChart() {
    // 🔹 Nếu bật Compare mode => So sánh tổng reasons tháng này vs tháng trước
    if (isCompareMode) {
      final hasCurrent = reasons.isNotEmpty;
      final hasPrevious = prevDetailsReasons.isNotEmpty;

      if (!hasCurrent && !hasPrevious) {
        return const Center(
          child: Text(
            "No data for both current and previous months",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        );
      }

      return SfCartesianChart(
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: _tooltipBehaviorDetails,
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(color: Color(0xFF8BA5C1), fontSize: 16),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(color: Color(0xFF8BA5C1), fontSize: 16),
        ),
        series: <CartesianSeries<MachineStopReasonModel, String>>[
          ColumnSeries<MachineStopReasonModel, String>(
            name: "Current (${widget.month})",
            dataSource: reasons,
            xValueMapper: (data, _) => data.reason1 ?? 'Unknown',
            yValueMapper: (data, _) => data.stopHour,
            color: const Color(0xFF00B4D8),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          ColumnSeries<MachineStopReasonModel, String>(
            name: "Previous (${_getPreviousMonth(widget.month)})",
            dataSource: prevDetailsReasons,
            xValueMapper: (data, _) => data.reason1 ?? 'Unknown',
            yValueMapper: (data, _) => data.stopHour,
            color: Colors.orangeAccent,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ],
      );
    }

    // 🔹 Còn lại = hiển thị chi tiết của lý do đang chọn (detailsReasons)
    if (detailsReasons.isEmpty) {
      return const Center(
        child: Text(
          "No data available for current month",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return SfCartesianChart(
      tooltipBehavior: _tooltipBehaviorDetails,
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(color: Color(0xFF8BA5C1), fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          "${widget.div} • STOP REASONS",
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D1622),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8BA5C1)),
            onPressed: _loadData,
          ),
          TextButton.icon(
            icon: const Icon(Icons.analytics, color: Colors.cyanAccent),
            label: Text(
              isCompareMode ? "Hide Analysis" : "Analyze",
              style: const TextStyle(color: Colors.cyanAccent),
            ),
            onPressed: () async {
              setState(() => isCompareMode = !isCompareMode);

              // ✅ Khi bật compare mode -> gọi API tháng trước cho reasons (không phải details)
              if (isCompareMode) {
                final prevMonth = _getPreviousMonth(widget.month);
                try {
                  setState(() => isLoadingDetails = true);
                  final prevData = await api.fetchMSReason(
                    month: prevMonth,
                    div: widget.div,
                  );
                  prevData.sort((a, b) => b.stopHour.compareTo(a.stopHour));
                  setState(() => prevDetailsReasons = prevData);
                } catch (e) {
                  debugPrint('Error loading previous month data: $e');
                } finally {
                  setState(() => isLoadingDetails = false);
                }
              }
            },
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
                          padding: const EdgeInsets.all(12.0),
                          child: SfCartesianChart(
                            tooltipBehavior: _tooltipBehavior,
                            primaryXAxis: CategoryAxis(
                              labelStyle: const TextStyle(
                                color: Color(0xFF8BA5C1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              labelStyle: const TextStyle(
                                color: Color(0xFF8BA5C1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                                    fontSize: 14,
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
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isCompareMode
                                        ? "COMPARE STOP REASONS ${widget.month} vs ${_getPreviousMonth(widget.month)}"
                                        : selectedReason == null
                                        ? "DETAILS (ALL)"
                                        : "DETAILS OF [${selectedReason!}]",
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
                                        : Column(
                                          children: [
                                            Expanded(
                                              child: _buildDetailsChart(),
                                            ),
                                            _buildAnalysisSummary(), // 🧩 thêm dòng này
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
