import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../Common/BlinkingText.dart';
import '../Common/WaterfallBackground.dart';

enum TreeMapMode { group, cate }

class TreeMapWidgets {
  static PreferredSizeWidget buildAppBar(ThemeData theme, String title) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 24),
          BlinkingText(text: title),
        ],
      ),
      backgroundColor: Colors.blueGrey[900],
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(height: 1, color: theme.dividerColor.withOpacity(0.2)),
      ),
    );
  }

  static Widget buildControlPanel({
    required ThemeData theme,
    required String dept,
    required TreeMapMode selectedMode,
    required Function(TreeMapMode?) onModeChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Shimmer(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.white.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Text('[ $dept ]', style: TextStyle(fontSize: 18)),
          ),
          Text('View Mode:', style: TextStyle(fontSize: 14)),
          _buildModeRadio(
            TreeMapMode.group,
            'Group',
            selectedMode,
            onModeChanged,
            theme,
          ),
          _buildModeRadio(
            TreeMapMode.cate,
            'Category',
            selectedMode,
            onModeChanged,
            theme,
          ),
        ],
      ),
    );
  }

  static Widget _buildModeRadio(
    TreeMapMode mode,
    String label,
    TreeMapMode selectedMode,
    Function(TreeMapMode?) onChanged,
    ThemeData theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<TreeMapMode>(
          value: mode,
          groupValue: selectedMode,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        Text(label),
      ],
    );
  }

  static Widget buildStatsCard({
    required ThemeData theme,
    required String totalRepairFee,
  }) {
    return WaterfallBackground(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'Repair Fee',
              value: totalRepairFee,
              color: Colors.green[700]!,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        Wrap(
          spacing: 8,
          children: [
            Text(label, style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildTooltip(String label, String value, double repairFee) {
    final formattedAct = NumberFormat('#,###', 'en_US').format(repairFee);
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Repair Fee: $formattedAct\$',
            style: TextStyle(
              color: Colors.amber[300],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildDetailedTooltip({
    required String label,
    required String value,
    required double repairFee,
    required String macName,
    required double percent,
  }) {
    final formattedAct = NumberFormat('#,###', 'en_US').format(repairFee);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mac Name: $macName',
            style: TextStyle(
              color: Colors.amber[300],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Repair Fee: $formattedAct\$',
            style: TextStyle(
              color: Colors.amber[300],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Percent: ${percent.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.amber[300],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
