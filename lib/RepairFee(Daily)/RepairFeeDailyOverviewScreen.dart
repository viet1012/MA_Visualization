import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/MtdDateText.dart';
import 'package:ma_visualization/RepairFee(Daily)/RepairFeeDailyOverviewChart.dart';
import 'package:provider/provider.dart';

import '../Common/NoDataWidget.dart';
import '../Common/TitleWithIndexBadge.dart';
import '../Provider/DateProvider.dart';
import '../Provider/RepairFeeDailyProvider.dart';

class RepairFeeDailyOverviewScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate; // 👈 Thêm dòng này
  const RepairFeeDailyOverviewScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
  });

  @override
  State<RepairFeeDailyOverviewScreen> createState() =>
      _RepairFeeDailyOverviewScreenState();
}

class _RepairFeeDailyOverviewScreenState
    extends State<RepairFeeDailyOverviewScreen> {
  @override
  void didUpdateWidget(covariant RepairFeeDailyOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateProvider = context.read<DateProvider>();
    if (oldWidget.selectedDate != dateProvider.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final repairFeeProvider = Provider.of<RepairFeeDailyProvider>(
          context,
          listen: false,
        );
        final newMonth =
            "${dateProvider.selectedDate.year}-${dateProvider.selectedDate.month.toString().padLeft(2, '0')}";
        print("newMonth: $newMonth");
        repairFeeProvider.fetchRepairFee(newMonth);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RepairFeeDailyProvider>(
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

  void _fetchData(RepairFeeDailyProvider provider) {
    final dateProvider = context.read<DateProvider>();
    final month =
        "${dateProvider.selectedDate.year}-${dateProvider.selectedDate.month.toString().padLeft(2, '0')}";
    provider.clearData(); // 👈 Reset trước khi fetch
    provider.fetchRepairFee(month);
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final selectedDate = dateProvider.selectedDate;

    return Scaffold(
      body: Consumer<RepairFeeDailyProvider>(
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Row(
                      children: [
                        TitleWithIndexBadge(
                          index: 2,
                          title: "Repair Fee [Daily]",
                        ),
                        SizedBox(width: 16),
                        MtdDateText(
                          selectedDate: selectedDate,
                          minusOneDayIfCurrentMonth:
                              false, // hoặc false nếu bạn muốn lấy ngày hiện tại
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: RepairFeeDailyOverviewChart(
                        data: provider.data,
                        month:
                            "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}",
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
}
