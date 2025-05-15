import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/DesignedByText.dart';
import 'package:ma_visualization/Provider/DateProvider.dart';
import 'package:ma_visualization/Provider/RepairFeeProvider.dart';
import 'package:provider/provider.dart';

import 'Common/CustomAppBar.dart';
import 'RepairFee/RepairFeeOverviewScreen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DashboardScreen({super.key, required this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  String _selectedDivision = 'KVH'; // hoặc '' nếu chưa chọn

  @override
  Widget build(BuildContext context) {
    final dateProvider =
        context.watch<DateProvider>(); // 👈 lấy ngày từ Provider
    final RepairFeeProvider repairFeeProvider =
        context.watch<RepairFeeProvider>(); // 👈 lấy ngày từ Provider
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "MA Dashboard",
        selectedDate: dateProvider.selectedDate,
        onDateChanged: (newDate) {
          context.read<DateProvider>().updateDate(newDate);
        },
        currentDate: repairFeeProvider.lastFetchedDate,
        onToggleTheme: widget.onToggleTheme,
        selectedDivision: _selectedDivision,
        onDivisionChanged: (value) {
          setState(() {
            _selectedDivision = value ?? '';
          });
        },
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2 - 50,
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RepairFeeOverviewScreen(
                      onToggleTheme: widget.onToggleTheme,
                      selectedDate: dateProvider.selectedDate,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2 - 50,
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
              ),
              DesignedByText(),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2 - 50,
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2 - 50,
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                  // child: MachineStoppingOverviewScreen(
                  //   onToggleTheme: widget.onToggleTheme,
                  //   selectedDate: dateProvider.selectedDate,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
