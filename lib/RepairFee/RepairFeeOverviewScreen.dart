import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/MtdDateText.dart';
import 'package:ma_visualization/Model/RepairFeeModel.dart';
import 'package:provider/provider.dart';

import '../Common/NoDataWidget.dart';
import '../Common/TitleWithIndexBadge.dart';
import '../Provider/DateProvider.dart';
import '../Provider/RepairFeeProvider.dart';
import 'RepairFeeOverviewChart.dart';

class RepairFeeOverviewScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate; // 👈 Thêm dòng này
  const RepairFeeOverviewScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
  });

  @override
  State<RepairFeeOverviewScreen> createState() =>
      _RepairFeeOverviewScreenState();
}

class _RepairFeeOverviewScreenState extends State<RepairFeeOverviewScreen> {
  @override
  void didUpdateWidget(covariant RepairFeeOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateProvider = context.read<DateProvider>();
    if (oldWidget.selectedDate != dateProvider.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final repairFeeProvider = Provider.of<RepairFeeProvider>(
          context,
          listen: false,
        );

        // final newMonth =
        //     "${dateProvider.selectedDate.year}-${dateProvider.selectedDate.month.toString().padLeft(2, '0')}";

        final newAdjustedDate = adjustedDateForDataFetch(
          dateProvider.selectedDate,
        );

        final newMonth =
            "${newAdjustedDate.year}-${newAdjustedDate.month.toString().padLeft(2, '0')}";
        repairFeeProvider.fetchRepairFee(newMonth);

        print("newMonth: $newMonth");
        repairFeeProvider.fetchRepairFee(newMonth);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RepairFeeProvider>(context, listen: false);
      _fetchData(provider);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime adjustedDateForDataFetch(DateTime date) {
    final now = DateTime.now();
    final isSameMonth =
        date.year == now.year && date.month == now.month && now.day == date.day;
    if (isSameMonth && date.day == 1) {
      return date.subtract(const Duration(days: 1));
    }
    return date;
  }

  void _fetchData(RepairFeeProvider provider) {
    final dateProvider = context.read<DateProvider>();
    final adjustedDate = adjustedDateForDataFetch(dateProvider.selectedDate);
    final month =
        "${adjustedDate.year}-${adjustedDate.month.toString().padLeft(2, '0')}";
    print("month of overview: $month");

    provider.clearData(); // 👈 Reset trước khi fetch
    provider.fetchRepairFee(month);
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final selectedDate = dateProvider.selectedDate;
    final nameChart = 'Repair Fee';

    return Scaffold(
      body: Consumer<RepairFeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.data.isEmpty) {
            return NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
              onRetry: () {
                _fetchData(provider);
              },
            );
          }

          final adjustedDate = adjustedDateForDataFetch(selectedDate);
          final newMonth =
              "${adjustedDate.year}-${adjustedDate.month.toString().padLeft(2, '0')}";

          return SingleChildScrollView(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TitleWithIndexBadge(index: 1, title: nameChart),
                            SizedBox(width: 16),
                            MtdDateText(
                              selectedDate: selectedDate,
                              minusOneDayIfCurrentMonth:
                                  true, // hoặc false nếu bạn muốn lấy ngày hiện tại
                            ),
                          ],
                        ),
                        _buildMTDInfo(provider.data),
                      ],
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: RepairFeeOverviewChart(
                        data: provider.data,
                        // month:
                        //     "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}",
                        month: newMonth,
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

  Widget _buildMTDInfo(List<RepairFeeModel> data) {
    final mtdAct = data.map((e) => e.actual).fold(0.0, (a, b) => a + b);
    final mtdFC = data.map((e) => e.target).fold(0.0, (a, b) => a + b);
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
              text: '${(mtdAct).toStringAsFixed(1)}K, ',
              style: TextStyle(color: Colors.blueAccent),
            ),
            const TextSpan(text: 'FC: '),
            TextSpan(
              text: '${(mtdFC).toStringAsFixed(1)}K, ',
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
