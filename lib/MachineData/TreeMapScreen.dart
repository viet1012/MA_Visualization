import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import '../API/ApiService.dart';
import '../Common/BlinkingText.dart';
import '../Model/MachineData.dart';

class TreeMapScreen extends StatefulWidget {
  final String dept;
  TreeMapScreen({required this.dept});

  @override
  _TreeMapScreenState createState() => _TreeMapScreenState();
}

enum TreeMapMode { group, cate }

TreeMapMode _treeMapMode = TreeMapMode.group;

List<dynamic> _treeMapData = [];
bool _isLoading = true;

class _TreeMapScreenState extends State<TreeMapScreen> {
  bool _showDataLabels = true;
  String? drilldownMacGrp; // lưu node cha được drill
  Rect? drilldownRect; // lưu vị trí + kích thước tile cha

  late double minAct;
  late double maxAct;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _treeMapMode = TreeMapMode.group;

    _initAsync();
  }

  Future<void> _initAsync() async {
    await _fetchData(); // load mặc định

    final acts = _treeMapData.map((e) => e.act).toList();
    if (acts.isNotEmpty) {
      minAct = acts.reduce((a, b) => a < b ? a : b);
      maxAct = acts.reduce((a, b) => a > b ? a : b);
    } else {
      minAct = maxAct = 0;
    }

    _generateColorMap();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final month = DateFormat('yyyy-MM').format(now);

    if (_treeMapMode == TreeMapMode.group) {
      _treeMapData = await ApiService().fetchMachineDataByGroup(
        month,
        widget.dept,
      );
    } else {
      _treeMapData = await ApiService().fetchMachineDataByCate(
        month,
        widget.dept,
      );
    }
    _generateColorMap();
    setState(() => _isLoading = false);
  }

  late Map<String, Color> macGrpColorMap;
  late Map<String, Color> cateColorMap;

  void _generateColorMap() {
    final colors = [
      Colors.blue.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
      Colors.indigo.shade700,
      Colors.brown.shade700,
      Colors.cyan.shade700,
      Colors.lime.shade700,
      Colors.amber.shade700,
      Colors.deepOrange.shade700,
      Colors.deepPurple.shade700,
      Colors.green.shade700,
      Colors.red.shade700,
      Colors.purple.shade700,
    ];

    if (_treeMapMode == TreeMapMode.group) {
      final uniqueGroups = _treeMapData.map((e) => e.macGrp).toSet().toList();
      macGrpColorMap = {
        for (int i = 0; i < uniqueGroups.length; i++)
          uniqueGroups[i]: colors[i % colors.length],
      };
    } else {
      final uniqueCategories = _treeMapData.map((e) => e.cate).toSet().toList();
      cateColorMap = {
        for (int i = 0; i < uniqueCategories.length; i++)
          uniqueCategories[i]: colors[i % colors.length],
      };
    }
  }

  Color getBlendedColor(String key, double act) {
    // Lấy màu base tùy theo mode
    final baseColor =
        _treeMapMode == TreeMapMode.group
            ? macGrpColorMap[key]!
            : cateColorMap[key]!;

    final t = ((act - minAct) / (maxAct - minAct)).clamp(0.4, 1.0);

    // Blend với trắng để làm nhạt khi act nhỏ
    return Color.lerp(Colors.white, baseColor.withOpacity(t), t)!;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);

    final totalRepairFee = _treeMapData.fold<double>(
      0.0,
      (sum, item) => sum + (item.act ?? 0),
    );

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildControlPanel(theme),
          _buildStatsCard(theme, totalRepairFee),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _buildTreemapCard(theme),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTreeMap(TreeMapMode mode) async {
    setState(() {
      _treeMapMode = mode;
      _isLoading = true;
    });

    await _fetchData();

    _generateColorMap();

    final acts = _treeMapData.map((e) => e.act).toList();
    if (acts.isNotEmpty) {
      minAct = acts.reduce((a, b) => a < b ? a : b);
      maxAct = acts.reduce((a, b) => a > b ? a : b);
    } else {
      minAct = maxAct = 0;
    }

    setState(() {
      _isLoading = false;
    });
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
          SizedBox(width: 32),

          // Radio buttons
          Text('View Mode:', style: TextStyle(fontSize: 14)),
          SizedBox(width: 8),
          Row(
            children: [
              Radio<TreeMapMode>(
                value: TreeMapMode.group,
                groupValue: _treeMapMode,
                onChanged: (value) {
                  _updateTreeMap(value!);
                },
              ),
              Text('Group'),

              Radio<TreeMapMode>(
                value: TreeMapMode.cate,
                groupValue: _treeMapMode,
                onChanged: (value) {
                  _updateTreeMap(value!);
                },
              ),
              Text('Category'),
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
            value: '${_treeMapData.length}',
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
                dataCount: _treeMapData.length,
                weightValueMapper: (int index) => _treeMapData[index].act,
                key: ValueKey(_showDataLabels),
                levels: [
                  TreemapLevel(
                    groupMapper:
                        (i) =>
                            _treeMapMode == TreeMapMode.group
                                ? _treeMapData[i].macGrp
                                : _treeMapData[i].cate,
                    labelBuilder: (BuildContext context, TreemapTile tile) {
                      final indices = tile.indices;
                      final totalAct = indices
                          .map((i) => _treeMapData[i].act)
                          .fold<double>(0, (prev, curr) => prev + curr);

                      final totalAll = _treeMapData
                          .map((e) => e.act)
                          .fold<double>(0, (prev, curr) => prev + curr);

                      final percent =
                          totalAll == 0 ? 0 : (totalAct / totalAll) * 100;
                      final formattedAct = NumberFormat(
                        '#,###',
                        'en_US',
                      ).format(totalAct);

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final canShowText =
                              constraints.maxWidth >= 120 &&
                              constraints.maxHeight >= 50;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // Có thể thêm màu nền, border nếu muốn
                              // color: Colors.black.withOpacity(0.05),
                            ),
                            child:
                                canShowText
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Tên nhóm máy
                                        Expanded(
                                          child: Text(
                                            tile.group,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
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
                                        // Số liệu
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$formattedAct \$',
                                              style: const TextStyle(
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
                                              style: const TextStyle(
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
                                    )
                                    : const SizedBox.shrink(), // Không hiện text nếu quá nhỏ
                          );
                        },
                      );
                    },

                    colorValueMapper: (TreemapTile tile) {
                      final index = tile.indices.first;
                      final key =
                          _treeMapMode == TreeMapMode.group
                              ? _treeMapData[index].macGrp
                              : _treeMapData[index].cate;

                      final colorMap =
                          _treeMapMode == TreeMapMode.group
                              ? macGrpColorMap
                              : cateColorMap;

                      return colorMap[key] ?? Colors.grey; // fallback tránh lỗi
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
                    groupMapper: (int index) => _treeMapData[index].macId,

                    labelBuilder: (BuildContext context, TreemapTile tile) {
                      // if (!_showDataLabels) return SizedBox.shrink();

                      final indices = tile.indices;

                      String macName = _treeMapData[indices.first].macName;
                      // Format số với dấu phân cách hàng nghìn cho dễ nhìn

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${tile.group}\n${macName}',
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
                    colorValueMapper: (TreemapTile tile) {
                      final index = tile.indices.first;
                      final key =
                          _treeMapMode == TreeMapMode.group
                              ? _treeMapData[index].macGrp
                              : _treeMapData[index].cate;

                      final act = _treeMapData[index].act;

                      return getBlendedColor(key, act);
                    },
                    padding: EdgeInsets.all(1),
                    border: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    tooltipBuilder: (BuildContext context, TreemapTile tile) {
                      final repairFee = _treeMapData[tile.indices.first].act;
                      return _buildDetailedTooltip(
                        'Machine ID',
                        tile.group,
                        repairFee,
                      );
                    },
                  ),
                ],

                enableDrilldown: !_showDataLabels, // ✅ bật drilldown
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

  Widget _buildLegend() {
    final colorMap =
        _treeMapMode == TreeMapMode.group ? macGrpColorMap : cateColorMap;

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children:
          colorMap.entries
              .map((entry) => _buildLegendItem(entry.key, entry.value))
              .toList(),
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
