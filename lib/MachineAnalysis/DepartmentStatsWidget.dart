import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';

class DepartmentStatsWidget extends StatelessWidget {
  final List<MachineAnalysis> data;
  final NumberFormat numberFormat;

  const DepartmentStatsWidget({
    super.key,
    required this.data,
    required this.numberFormat,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, List<MachineAnalysis>> deptData = {};
    for (var item in data) {
      deptData.putIfAbsent(item.div, () => []).add(item);
    }

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
                  deptData.entries.map((entry) {
                    String dept = entry.key;
                    List<MachineAnalysis> machines = entry.value;

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
