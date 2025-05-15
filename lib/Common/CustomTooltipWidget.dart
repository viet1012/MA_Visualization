import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomTooltipWidget extends StatelessWidget {
  final dynamic item; // Có thể là bất kỳ object nào
  final NumberFormat numberFormat;
  final String seriesName;
  final Color? customColor;

  // Callback để lấy các giá trị từ `item` theo từng kiểu
  final double Function(dynamic item) getActual;
  final double Function(dynamic item) getTarget;
  final String Function(dynamic item)? getStatus;
  final Color Function(String status)? getStatusColor;

  const CustomTooltipWidget({
    super.key,
    required this.item,
    required this.numberFormat,
    required this.seriesName,
    this.customColor,
    required this.getActual,
    required this.getTarget,
    this.getStatus,
    this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActual = seriesName == 'Actual';

    final actual = getActual(item);
    final target = getTarget(item);
    final status = getStatus?.call(item) ?? '';
    final statusColor =
        isActual
            ? (getStatusColor?.call(status) ?? Colors.grey)
            : (customColor ?? Colors.grey);

    final percent = target > 0 ? (actual / target) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            isActual
                ? [
                  Text(
                    'Actual: ${numberFormat.format(actual)}K\$',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    'Rate: ${percent.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '👇 Click the bar to see details',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ]
                : [
                  Text(
                    'Target: ${numberFormat.format(target)}K\$',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
      ),
    );
  }
}
