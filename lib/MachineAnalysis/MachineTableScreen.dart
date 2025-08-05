import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysisAve.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';

class MachineTableDialog extends StatelessWidget {
  final String div;
  final String month;
  final String monthBack;
  final int topLimit;
  final NumberFormat numberFormat;
  final AnalysisMode selectedMode; // 👈 thêm dòng này

  const MachineTableDialog({
    super.key,
    required this.div,
    required this.month,
    required this.monthBack,
    required this.topLimit,
    required this.numberFormat,
    required this.selectedMode,
  });

  Future<List<Map<String, dynamic>>> getMachineDataAsMap() async {
    if (selectedMode == AnalysisMode.average) {
      final result = await ApiService().fetchMachineDataAnalysisAvgFullResponse(
        month: month,
        monthBack: monthBack,
        topLimit: topLimit,
        div: div,
      );
      return result.map((e) => e.toJson()).toList();
    } else {
      final result = await ApiService().fetchMachineDataAnalysis(
        month: month,
        monthBack: monthBack,
        topLimit: topLimit,
        div: div,
      );
      return result.map((e) => e.toJson()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            Row(
              children: [
                Text(selectedMode.name),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    tooltip: 'Exit',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getMachineDataAsMap(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final dataList = snapshot.data!;
                  final headers = dataList.first.keys.toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns:
                          headers
                              .map((key) => DataColumn(label: Text(key)))
                              .toList(),
                      rows:
                          dataList.map((dataRow) {
                            return DataRow(
                              color: MaterialStateProperty.all(
                                DepartmentUtils.getDepartmentColor(
                                  dataRow['div'],
                                ).withOpacity(.6),
                              ),
                              cells:
                                  headers.map((key) {
                                    final value = dataRow[key];
                                    return DataCell(
                                      Text(
                                        value is num
                                            ? numberFormat.format(value)
                                            : value.toString(),
                                      ),
                                    );
                                  }).toList(),
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
