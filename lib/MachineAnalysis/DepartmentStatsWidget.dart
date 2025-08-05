import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';
import 'MachineTableScreen.dart';

class DepartmentStatsWidget extends StatelessWidget {
  final List<MachineAnalysis> data;
  final NumberFormat numberFormat;
  final AnalysisMode selectedMode; // 👈 thêm dòng này
  final String div;
  final String month;
  final String monthBack;
  final int topLimit;

  const DepartmentStatsWidget({
    super.key,
    required this.data,
    required this.numberFormat,
    required this.selectedMode,
    required this.div,
    required this.month,
    required this.monthBack,
    required this.topLimit,
  });

  @override
  Widget build(BuildContext context) {
    // Gom nhóm theo phòng ban (division)
    final Map<String, List<MachineAnalysis>> deptData = {};

    // Bước 1: Thêm vào Map và in ra
    for (var item in data) {
      deptData
          .putIfAbsent(item.div, () {
            // print('➕ Tạo mới department: ${item.div}');
            return [];
          })
          .add(item);
    }

    // Bước 2: In ra danh sách trước khi sắp xếp
    // print('\n📋 Danh sách department ban đầu (chưa sắp xếp):');
    // deptData.forEach((key, value) {
    //   print('- $key (${value.length} máy)');
    // });

    // Bước 3: Sắp xếp theo predefinedOrder
    List<String> predefinedOrder = ['KVH', 'PRESS', 'MOLD', 'GUIDE'];
    List<String> departmentOrder = deptData.keys.toList();

    departmentOrder.sort((a, b) {
      int indexA = predefinedOrder.indexOf(a);
      int indexB = predefinedOrder.indexOf(b);
      if (indexA == -1) indexA = predefinedOrder.length;
      if (indexB == -1) indexB = predefinedOrder.length;
      return indexA.compareTo(indexB);
    });

    // Bước 4: In ra sau khi sắp xếp
    // print('\n✅ Danh sách department sau khi sắp xếp:');
    // for (var dept in departmentOrder) {
    //   print('🔸 $dept');
    // }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  departmentOrder.map((dept) {
                    List<MachineAnalysis> machines = deptData[dept]!;

                    double totalRepairFee = machines.fold(
                      0,
                      (sum, m) => sum + m.repairFee,
                    );
                    double totalStopHour = machines.fold(
                      0,
                      (sum, m) => sum + m.stopHour,
                    );
                    int totalStopCase = machines.fold(
                      0,
                      (sum, m) => sum + m.stopCase.toInt(),
                    );

                    return Container(
                      width: 550,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DepartmentUtils.getDepartmentColor(
                          dept,
                        ).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DepartmentUtils.getDepartmentColor(dept),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: DepartmentUtils.getDepartmentColor(
                                        dept,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    dept,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: DepartmentUtils.getDepartmentColor(
                                        dept,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),

                              if (selectedMode == AnalysisMode.average)
                                Row(
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.table_chart),
                                        label: Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.blue,
                                          period: const Duration(
                                            milliseconds: 1800,
                                          ), // tốc độ shimmer
                                          child: Text(
                                            "View Table",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Colors
                                                      .black, // màu gốc vẫn cần để giữ shape
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                insetPadding:
                                                    EdgeInsets
                                                        .zero, // để full sát mép màn hình ngang
                                                child: SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      .9,

                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: MachineTableDialog(
                                                      div: div,
                                                      month: month,
                                                      monthBack: monthBack,
                                                      topLimit: topLimit,
                                                      numberFormat:
                                                          numberFormat,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(
                                '💰Repair Fee',
                                '${numberFormat.format(totalRepairFee)}\$',
                              ),
                              _buildStatItem(
                                '🔄Stop Case',
                                numberFormat.format(totalStopCase),
                              ),
                              _buildStatItem(
                                '⏰Stop Hour',
                                '${numberFormat.format(totalStopHour)}h',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
