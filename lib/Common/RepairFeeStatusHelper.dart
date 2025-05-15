import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RepairFeeModel.dart';

class RepairFeeStatusHelper {
  static String getStatus(RepairFeeModel item) {
    if (item.actual > item.target) return 'Over Target';
    if (item.actual < item.target) return 'Under Target';
    return 'Target Achieved';
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Over Target':
        return Colors.red;
      case 'Target Achieved':
        return Colors.green;
      case 'Under Target':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Over Target':
        return Icons.trending_up;
      case 'Target Achieved':
        return Icons.check_circle;
      case 'Under Target':
        return Icons.trending_down;
      default:
        return Icons.help_outline;
    }
  }
}
