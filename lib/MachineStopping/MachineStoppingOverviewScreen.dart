import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/MtdDateText.dart';
import 'package:ma_visualization/Common/TitleWithIndexBadge.dart';
import 'package:ma_visualization/Model/MachineStoppingModel.dart';
import 'package:ma_visualization/Provider/MachineStoppingProvider.dart';
import 'package:provider/provider.dart';

import '../Common/NoDataWidget.dart';
import '../Provider/DateProvider.dart';
import 'MachineStoppingOverviewChart.dart';

class MachineStoppingOverviewScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate; // 👈 Thêm dòng này
  const MachineStoppingOverviewScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
  });

  @override
  State<MachineStoppingOverviewScreen> createState() =>
      _MachineStoppingOverviewScreenState();
}

class _MachineStoppingOverviewScreenState
    extends State<MachineStoppingOverviewScreen> {
  @override
  void didUpdateWidget(covariant MachineStoppingOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateProvider = context.read<DateProvider>();
    if (oldWidget.selectedDate != dateProvider.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final machineStoppingProvider = Provider.of<MachineStoppingProvider>(
          context,
          listen: false,
        );
        final newMonth =
            "${dateProvider.selectedDate.year}-${dateProvider.selectedDate.month.toString().padLeft(2, '0')}";
        print("newMonth: $newMonth");
        machineStoppingProvider.fetchMachineStopping(newMonth);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MachineStoppingProvider>(
        context,
        listen: false,
      );
      _fetchData(provider);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData(MachineStoppingProvider provider) {
    final dateProvider = context.read<DateProvider>();
    final month =
        "${dateProvider.selectedDate.year}-${dateProvider.selectedDate.month.toString().padLeft(2, '0')}";
    provider.clearData(); // 👈 Reset trước khi fetch
    provider.fetchMachineStopping(month);
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final selectedDate = dateProvider.selectedDate;
    final nameChart = "Machine Stopping";

    return Scaffold(
      body: Consumer<MachineStoppingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.data.isEmpty) {
            return const NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
            );
          }

          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TitleWithIndexBadge(index: 4, title: nameChart),
                            SizedBox(width: 16),
                            MtdDateText(
                              selectedDate: selectedDate,
                              minusOneDayIfCurrentMonth:
                                  false, // hoặc false nếu bạn muốn lấy ngày hiện tại
                            ),
                          ],
                        ),

                        _buildMTDInfo(provider.data),
                      ],
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: MachineStoppingOverviewChart(
                        data: provider.data,
                        month:
                            "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}",
                        nameChart: nameChart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMTDInfo(List<MachineStoppingModel> data) {
    final mtdAct = data.map((e) => e.stopHourAct).fold(0.0, (a, b) => a + b);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final mtdFC = data
        .where(
          (e) => DateTime(
            e.date.year,
            e.date.month,
            e.date.day,
          ).isBefore(today.add(Duration(days: 1))),
        )
        .map((e) => e.stopHourTgtMtd)
        .fold(0.0, (a, b) => a + b);
    final ratio = mtdFC > 0 ? (mtdAct / mtdFC * 100).toStringAsFixed(0) : '0';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          children: [
            const TextSpan(text: 'MTD_Act: '),
            TextSpan(
              text: '${(mtdAct / 1000).toStringAsFixed(1)}K, ',
              style: TextStyle(color: Colors.blueAccent),
            ),
            const TextSpan(text: 'FC: '),
            TextSpan(
              text: '${(mtdFC / 1000).toStringAsFixed(1)}K, ',
              style: TextStyle(color: Colors.blue),
            ),
            const TextSpan(
              text: 'Ratio: ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$ratio%',
              style: TextStyle(
                fontSize: 18,
                color: int.parse(ratio) > 100 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
