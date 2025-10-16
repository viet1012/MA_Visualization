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

        // Lấy danh sách tháng trong dữ liệu
        final labels = data.map((e) => e.month).toList();
        print("labels = $labels");

        // Hàm normalize tháng về dạng "YYYYMM" để so sánh dễ hơn
        String normalizeMonth(String raw) {
          raw = raw.replaceAll('-', '').trim();
          if (raw.length == 6) return raw;
          return raw.padLeft(6, '0');
        }

        String from = normalizeMonth(widget.monthFrom);
        String to = normalizeMonth(widget.monthTo);

        // Tạo map để dễ tra chỉ số
        final labelMap = {
          for (int i = 0; i < labels.length; i++) normalizeMonth(labels[i]): i,
        };

        // Tìm vị trí
        int? startIndex = labelMap[from];
        int? endIndex = labelMap[to];

        // Nếu không có tháng trùng, tìm tháng gần nhất (theo giá trị số)
        List<int> monthValues =
            labelMap.keys.map((e) => int.tryParse(e) ?? 0).toList()..sort();
        int fromVal = int.tryParse(from) ?? 0;
        int toVal = int.tryParse(to) ?? 0;

        if (startIndex == null) {
          // Tìm tháng nhỏ nhất lớn hơn hoặc bằng fromVal, nếu không có thì lấy max
          int closest = monthValues.firstWhere(
            (v) => v >= fromVal,
            orElse: () => monthValues.last,
          );
          startIndex = labelMap[closest.toString()];
        }

        if (endIndex == null) {
          // Tìm tháng lớn nhất nhỏ hơn hoặc bằng toVal, nếu không có thì lấy min
          int closest = monthValues.lastWhere(
            (v) => v <= toVal,
            orElse: () => monthValues.first,
          );
          endIndex = labelMap[closest.toString()];
        }

        // Nếu vẫn lỗi thì fallback
        startIndex ??= 0;
        endIndex ??= labels.length - 1;

        double startVal =
            (startIndex - 0.5).clamp(0, labels.length - 1).toDouble();
        double endVal = (endIndex + 0.5).clamp(0, labels.length - 1).toDouble();

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

                  return ChartAxisLabel(
                    label,
                    const TextStyle(color: Colors.white),
                  );
                },
                plotBands: <PlotBand>[
                  PlotBand(
                    start: startVal,
                    end: endVal,
                    isVisible: true,
                    color: Colors.transparent,
                    shouldRenderAboveSeries: false,

                    // Gradient border với hiệu ứng glow
                    borderWidth: 2,
                    borderColor: const Color(0xFFFF006E),
                    dashArray: const <double>[8, 4],
                    text: widget.machineAnalysis.scale,
                    verticalTextAlignment: TextAnchor.start,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF006E),
                      letterSpacing: 2.0,

                      // Multi-layer shadow cho text glow
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF006E),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: const Color(0xFFFF006E).withOpacity(0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),

                    // Text styling cyberpunk
                    textAngle: 0,
                  ),

                  // ============ ALTERNATIVE: Thêm hiệu ứng neon animation ============
                  // Nếu muốn gradient text thay vì solid color
                  /*

*/

                  // ============ Màu cyberpunk alternatives ============
                  // Hot Pink: Color(0xFFFF006E)
                  // Electric Cyan: Color(0xFF00F5FF)
                  // Neon Purple: Color(0xFFB000FF)
                  // Neon Green: Color(0xFF39FF14)
                ],
              ),

              primaryYAxis: NumericAxis(
                name: 'CaseAxis',
                title: const AxisTitle(
                  text: 'K\$',
                  textStyle: TextStyle(color: Colors.white, fontSize: 18),
                ),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                axisLine: const AxisLine(width: 0),
              ),
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
                  yValueMapper:
                      (d, _) => double.parse(d.repairFee.toStringAsFixed(0)),
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
                                        MediaQuery.of(context).size.height *
                                        .95,
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
