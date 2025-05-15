import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Provider/MachineStoppingProvider.dart';
import 'package:provider/provider.dart';

import '../Common/DesignedByText.dart';
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
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  Timer? _dailyTimer;
  final dayFormat = DateFormat('d-MMM-yyyy');

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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dailyTimer?.cancel(); // 🧹 Dọn dẹp khi màn hình bị hủy
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: MachineStoppingOverviewChart(
                        data: provider.data,
                        month:
                            "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}",
                      ),
                    ),
                    DesignedByText(),
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
