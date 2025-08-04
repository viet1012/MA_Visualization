import 'package:flutter/material.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysisAve.dart';

class MachineTableDialog extends StatelessWidget {
  final String div;
  final String month;
  final String monthBack;
  final int topLimit;

  const MachineTableDialog({
    super.key,
    required this.div,
    required this.month,
    required this.monthBack,
    required this.topLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height:
            MediaQuery.of(context).size.height * 0.9, // thêm chiều cao cố định
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Exit',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<MachineAnalysisAve>>(
                future: ApiService().fetchMachineDataAnalysisAvgFullResponse(
                  month: month,
                  monthBack: monthBack,
                  topLimit: topLimit,
                  div: div,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Lỗi: ${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Không có dữ liệu"),
                    );
                  }

                  final machines = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Div')),
                          DataColumn(label: Text('Rank')),
                          DataColumn(label: Text('Machine')),
                          DataColumn(label: Text('Repair Fee')),
                          DataColumn(label: Text('Count')),
                          DataColumn(label: Text('Ave Repair Fee')),
                          DataColumn(label: Text('Stop Case')),
                          DataColumn(label: Text('Stop Hour')),
                          DataColumn(label: Text('Ave Stop Hour')),
                        ],
                        rows:
                            machines.map((machine) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(machine.div)),
                                  DataCell(Text(machine.rank.toString())),
                                  DataCell(Text(machine.macName ?? "-")),
                                  DataCell(
                                    Text(machine.repairFee.toStringAsFixed(2)),
                                  ),
                                  DataCell(Text(machine.countMac.toString())),
                                  DataCell(
                                    Text(
                                      machine.aveRepairFee.toStringAsFixed(2),
                                    ),
                                  ),
                                  DataCell(
                                    Text(machine.stopCase?.toString() ?? '-'),
                                  ),
                                  DataCell(
                                    Text(
                                      machine.stopHour?.toStringAsFixed(2) ??
                                          '-',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      machine.aveStopHour?.toStringAsFixed(2) ??
                                          '-',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
