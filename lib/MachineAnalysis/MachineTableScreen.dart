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
  final AnalysisMode selectedMode;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.85,
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Title + Exit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMode.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Table
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

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.blueGrey[200],
                            ),
                            columnSpacing: 16,
                            columns:
                                headers
                                    .map(
                                      (key) => DataColumn(
                                        label: Text(
                                          key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            rows:
                                dataList.map((dataRow) {
                                  final divValue =
                                      dataRow['Div']?.toString() ?? '';
                                  final rowColor =
                                      DepartmentUtils.getDepartmentColor(
                                        divValue,
                                      ).withOpacity(.8);

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                      Color?
                                    >((Set<MaterialState> states) => rowColor),
                                    cells:
                                        headers.map((key) {
                                          final value = dataRow[key];
                                          return DataCell(
                                            Text(
                                              value is num
                                                  ? numberFormat.format(value)
                                                  : value?.toString() ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
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
