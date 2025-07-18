import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import '../Common/BlinkingText.dart';
import '../Model/MachineData.dart';

class TreeMapScreen extends StatefulWidget {
  final List<MachineData> data;

  TreeMapScreen({required this.data});

  @override
  _TreeMapScreenState createState() => _TreeMapScreenState();
}

class _TreeMapScreenState extends State<TreeMapScreen> {
  bool _showDataLabels = true;
  String? drilldownMacGrp; // lưu node cha được drill
  Rect? drilldownRect; // lưu vị trí + kích thước tile cha

  final GlobalKey _treemapKey = GlobalKey();
  late double minAct;
  late double maxAct;

  @override
  void initState() {
    super.initState();
    _generateMacGrpColors();

    final acts = widget.data.map((e) => e.act).toList();
    minAct = acts.reduce((a, b) => a < b ? a : b);
    maxAct = acts.reduce((a, b) => a > b ? a : b);
  }

  late Map<String, Color> macGrpColorMap;

  void _generateMacGrpColors() {
    final uniqueGroups = widget.data.map((e) => e.macGrp).toSet().toList();
    final colors = [
      Colors.deepPurple.shade700,
      Colors.green.shade700,
      Colors.red.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      // Thêm bao nhiêu màu tùy số nhóm
    ];

    macGrpColorMap = {
      for (int i = 0; i < uniqueGroups.length; i++)
        uniqueGroups[i]: colors[i % colors.length],
    };
  }

  Color getBlendedColor(String macGrp, double act) {
    final baseColor = macGrpColorMap[macGrp]!;
    final t = ((act - minAct) / (maxAct - minAct)).clamp(0.1, 1.0);

    // Blend với trắng để làm nhạt khi act nhỏ
    return Color.lerp(Colors.white, baseColor.withOpacity(t), t)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRepairFee = widget.data.fold(0.0, (sum, item) => sum + item.act);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // _buildControlPanel(theme),
          _buildStatsCard(theme, totalRepairFee),
          Expanded(child: _buildTreemapCard(theme)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.analytics_outlined, size: 24),
          BlinkingText(text: 'Repair Fee Analytics'),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(height: 1, color: theme.dividerColor.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.tune, color: theme.colorScheme.primary),
          SizedBox(width: 12),
          Text(
            'Display Options',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Spacer(),
          Row(
            children: [
              Text('Show Labels', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Switch(
                value: _showDataLabels,
                onChanged: (value) {
                  setState(() {
                    _showDataLabels = value;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, double totalRepairFee) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.2),
            theme.colorScheme.secondary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            icon: Icons.memory,
            label: 'Machines',
            value: '${widget.data.length}',
            color: Colors.indigo.shade900,
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            label: 'Repair',
            value: totalRepairFee.toStringAsFixed(0),
            color: Colors.green[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTreemapCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.account_tree, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  'Hierarchical View',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                Spacer(),
                _buildLegend(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SfTreemap(
                dataCount: widget.data.length,
                weightValueMapper: (int index) => widget.data[index].act,
                levels: [
                  TreemapLevel(
                    groupMapper: (int index) => widget.data[index].macGrp,
                    labelBuilder: (BuildContext context, TreemapTile tile) {
                      if (!_showDataLabels) return SizedBox.shrink();

                      final indices = tile.indices;
                      final totalAct = indices
                          .map((i) => widget.data[i].act)
                          .fold<double>(0, (prev, curr) => prev + curr);

                      final totalAll = widget.data
                          .map((e) => e.act)
                          .fold<double>(0, (prev, curr) => prev + curr);

                      final percent =
                          totalAll == 0 ? 0 : (totalAct / totalAll) * 100;
                      final formattedAct = NumberFormat(
                        '#,###',
                        'en_US',
                      ).format(totalAct);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.black26,
                          period: Duration(seconds: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tên nhóm máy (bên trái)
                              Expanded(
                                child: Text(
                                  tile.group,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Số liệu (bên phải)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$formattedAct \$',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black87,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '(${percent.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black87,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },

                    colorValueMapper: (TreemapTile tile) {
                      final macGrp = widget.data[tile.indices.first].macGrp;
                      return macGrpColorMap[macGrp];
                    },

                    padding: EdgeInsets.all(3),
                    border: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tooltipBuilder: (BuildContext context, TreemapTile tile) {
                      return _buildTooltip('Machine Group', tile.group);
                    },
                  ),

                  TreemapLevel(
                    groupMapper: (int index) => widget.data[index].macId,
                    // labelBuilder: (BuildContext context, TreemapTile tile) {
                    //   return _showDataLabels
                    //       ? _buildLabel(tile.group, 12, Colors.white)
                    //       : Container();
                    // },
                    labelBuilder: (BuildContext context, TreemapTile tile) {
                      if (!_showDataLabels) return SizedBox.shrink();

                      final indices = tile.indices;
                      final totalAct = indices
                          .map((i) => widget.data[i].act)
                          .fold<double>(0, (prev, curr) => prev + curr);

                      // Format số với dấu phân cách hàng nghìn cho dễ nhìn

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tile.group,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },

                    color: Color(0xFFFF9800),
                    // colorValueMapper: (TreemapTile tile) {
                    //   final macGrp = widget.data[tile.indices.first].macGrp;
                    //   return macGrpColorMap[macGrp];
                    // },
                    colorValueMapper: (TreemapTile tile) {
                      final data = widget.data[tile.indices.first];
                      return getBlendedColor(data.macGrp, data.act);
                    },

                    padding: EdgeInsets.all(1),
                    border: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    tooltipBuilder: (BuildContext context, TreemapTile tile) {
                      final repairFee = widget.data[tile.indices.first].act;
                      return _buildDetailedTooltip(
                        'Machine ID',
                        tile.group,
                        repairFee,
                      );
                    },
                  ),
                ],

                // enableDrilldown: true, // ✅ bật drilldown
                breadcrumbs: TreemapBreadcrumbs(
                  builder: (
                    BuildContext context,
                    TreemapTile tile,
                    bool isCurrent,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        tile.group,
                        style: TextStyle(
                          color: isCurrent ? Colors.blue : Colors.blueAccent,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 22,
                        ),
                      ),
                    );
                  },
                  divider: Icon(Icons.chevron_right),
                ),

                tooltipSettings: TreemapTooltipSettings(hideDelay: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double fontSize, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children:
          macGrpColorMap.entries.map((entry) {
            return _buildLegendItem(entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTooltip(String label, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailedTooltip(String label, String value, double repairFee) {
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
            'Repair Fee: ${repairFee.toStringAsFixed(0)}\$',
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
