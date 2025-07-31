// widgets/pie_chart_detail.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';

class PieChartDetail extends StatelessWidget {
  final MachineAnalysis machine;
  final NumberFormat numberFormat;
  final VoidCallback onClose;

  const PieChartDetail({
    super.key,
    required this.machine,
    required this.numberFormat,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        ),

        // Close Button
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onClose,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPieChart(),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DepartmentUtils.getDepartmentColor(machine.div).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DepartmentUtils.getDepartmentColor(
            machine.div,
          ).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DepartmentUtils.getDepartmentColor(machine.div),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.precision_manufacturing,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.macName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DepartmentUtils.getDepartmentColor(machine.div),
                  ),
                ),
                Text(
                  'Department: ${machine.div}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DepartmentUtils.getDepartmentColor(machine.div),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rank #${machine.rank}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Expanded(
      child: SfCircularChart(
        title: ChartTitle(
          text: 'Machine Analysis Breakdown',
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          PieSeries<_PieData, String>(
            dataSource: [
              _PieData(
                'Repair Fee (\$${numberFormat.format(machine.repairFee)})',
                machine.repairFee,
                Colors.green[600]!,
              ),
              _PieData(
                'Stop Hour (${machine.stopHour}h)',
                machine.stopHour,
                Colors.red[600]!,
              ),
              _PieData(
                'Stop Case (${machine.stopCase})',
                machine.stopCase.toDouble(),
                Colors.orange[600]!,
              ),
            ],
            xValueMapper: (_PieData data, _) => data.label,
            yValueMapper: (_PieData data, _) => data.value,
            pointColorMapper: (_PieData data, _) => data.color,
            explode: true,
            explodeIndex: 0,
            explodeOffset: '10%',
            radius: '80%',
            animationDuration: 800,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            Icons.attach_money,
            'Total Cost',
            '\$${numberFormat.format(machine.repairFee)}',
            Colors.green[600]!,
          ),
          _buildStat(
            Icons.access_time,
            'Downtime',
            '${machine.stopHour}h',
            Colors.red[600]!,
          ),
          _buildStat(
            Icons.warning_amber,
            'Incidents',
            '${machine.stopCase}',
            Colors.orange[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;

  _PieData(this.label, this.value, this.color);
}
