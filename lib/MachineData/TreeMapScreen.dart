import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Common/WaterfallBackground.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import '../API/ApiService.dart';
import '../Common/BlinkingText.dart';
import '../Model/MachineData.dart';
import 'TreeMapWidgets.dart';

class TreeMapScreen extends StatefulWidget {
  final String dept;
  final String month;

  const TreeMapScreen({super.key, required this.dept, required this.month});

  @override
  _TreeMapScreenState createState() => _TreeMapScreenState();
}

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

    // final acts = _treeMapData.where((e) => e.act > 0).toList();

    if (acts.isNotEmpty) {
      minAct = acts.reduce((a, b) => a < b ? a : b);
      maxAct = acts.reduce((a, b) => a > b ? a : b);
    } else {
      minAct = maxAct = 0;
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    if (_treeMapMode == TreeMapMode.group) {
      _treeMapData = await ApiService().fetchMachineDataByGroup(
        widget.month,
        widget.dept,
      );
    } else {
      _treeMapData = await ApiService().fetchMachineDataByCate(
        widget.month,
        widget.dept,
      );
    }
    _generateColorMap();
    calculateGroupTotals();
    _generateIndexRankMap();

    setState(() => _isLoading = false);
  }

  late Map<String, Color> macGrpColorMap;
  late Map<String, Color> cateColorMap;

  void _generateColorMap() {
    final colors = [
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo.shade600,
      Colors.cyan,
      Colors.lime.shade600,
      Colors.amber,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.green,
      Colors.red,
      Colors.purple,
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

  late Map<String, List<int>> groupMap = {};
  late Map<int, int> indexRankMap = {};
  late Map<String, int> groupSizeMap = {};

  Map<int, int> get _currentIndexRankMap => indexRankMap;

  Map<String, double> get _currentGroupTotalMap {
    final map = <String, double>{};
    for (final entry in groupMap.entries) {
      final key = entry.key;
      final total = entry.value.fold<double>(
        0,
        (sum, idx) => sum + (_treeMapData[idx].act ?? 0),
      );
      map[key] = total;
    }
    return map;
  }

  void _generateIndexRankMap() {
    groupMap.clear();
    for (int i = 0; i < _treeMapData.length; i++) {
      final key =
          _treeMapMode == TreeMapMode.group
              ? _treeMapData[i].macGrp ?? 'Unknown'
              : _treeMapData[i].cate ?? 'Unknown';
      groupMap.putIfAbsent(key, () => []).add(i);
    }

    // Tính rank trong từng group
    indexRankMap.clear();
    for (final entry in groupMap.entries) {
      final indices = entry.value;
      indices.sort((a, b) {
        final actA = _treeMapData[a].act ?? 0;
        final actB = _treeMapData[b].act ?? 0;
        return actB.compareTo(actA); // sắp giảm dần theo act
      });

      for (int rank = 0; rank < indices.length; rank++) {
        indexRankMap[indices[rank]] = rank;
      }
    }

    // Tổng số item trong mỗi group
    groupSizeMap = {for (var e in groupMap.entries) e.key: e.value.length};
  }

  Color getBlendedColorByRank(String key, int rank, int totalItems) {
    final baseColor =
        _treeMapMode == TreeMapMode.group
            ? macGrpColorMap[key]!
            : cateColorMap[key]!;

    final t = (1 - (rank / (totalItems - 1))).clamp(0.1, 1.0);

    return Color.lerp(
      Colors.white.withOpacity(.8),
      baseColor.withOpacity(t),
      t,
    )!;
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
    final formattedAct = NumberFormat('#,###', 'en_US').format(totalRepairFee);

    return Scaffold(
      appBar: TreeMapWidgets.buildAppBar(theme, 'Repair Fee Analytics'),
      body: SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width * .5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_selectedGroup == null)
                    TreeMapWidgets.buildControlPanel(
                      theme: theme,
                      dept: widget.dept,
                      selectedMode: _treeMapMode,
                      onModeChanged: (mode) {
                        if (mode != null) _updateTreeMap(mode);
                      },
                    ),
                  Spacer(),
                  TreeMapWidgets.buildStatsCard(
                    theme: theme,
                    totalRepairFee: formattedAct,
                  ),
                ],
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    .86, // hoặc đặt theo kích thước mong muốn
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _buildTreemapCard(theme),
              ),
            ],
          ),
        ),
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

  // Tạo trước (sau khi fetch data hoặc trong initState)
  Map<String, double> groupTotalMap = {};

  void calculateGroupTotals() {
    groupTotalMap.clear();

    for (final item in _treeMapData) {
      final groupKey =
          _treeMapMode == TreeMapMode.group ? item.macGrp : item.cate;
      groupTotalMap[groupKey] = (groupTotalMap[groupKey] ?? 0) + item.act;
    }

    // In ra thông tin
    print('📊 Tổng act theo group:');
    groupTotalMap.forEach((key, totalAct) {
      print('🔹 Group: $key | Tổng act: ${totalAct.toStringAsFixed(2)}');
    });
  }

  // Thêm state variable để điều khiển drilldown
  String? _selectedGroup; // group đang được focus
  String? _justDrilledGroup;
  String? _justTappedGroup;

  List<dynamic> _getFilteredData() {
    if (_selectedGroup == null) {
      return _treeMapData; // Hiển thị tất cả
    }

    // Lọc chỉ items thuộc group được chọn
    return _treeMapData.where((item) {
      final groupKey =
          _treeMapMode == TreeMapMode.group ? item.macGrp : item.cate;
      return groupKey == _selectedGroup;
    }).toList();
  }

  Widget _buildTreemapCard(ThemeData theme) {
    final filteredData = _getFilteredData();

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
          if (_selectedGroup != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedGroup = null;
                      });
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text('Back to Overview'),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Focused: $_selectedGroup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 0.08), // trượt nhẹ từ dưới
                        end: Offset.zero,
                      ).animate(animation),
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },

                child: SfTreemap(
                  dataCount: filteredData.length,
                  weightValueMapper: (int index) => filteredData[index].act,
                  key: ValueKey(_selectedGroup ?? 'overview'),
                  levels: [
                    TreemapLevel(
                      groupMapper: (i) {
                        final data = filteredData;
                        return _treeMapMode == TreeMapMode.group
                            ? data[i].macGrp ?? 'Unknown'
                            : data[i].cate ?? 'Unknown';
                      },
                      labelBuilder: (BuildContext context, TreemapTile tile) {
                        // final data = _getFilteredData();
                        final data = filteredData;

                        final indices = tile.indices;
                        final totalAct = indices
                            .map((i) => data[i].act)
                            .fold<double>(0, (prev, curr) => prev + curr);

                        final totalAll = data
                            .map((e) => e.act)
                            .fold<double>(0, (prev, curr) => prev + curr);

                        final percent =
                            totalAll == 0 ? 0 : (totalAct / totalAll) * 100;

                        final formattedAct = NumberFormat(
                          '#,###',
                          'en_US',
                        ).format(totalAct);

                        return GestureDetector(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _selectedGroup = tile.group;
                                  _justDrilledGroup = tile.group;
                                });
                              }
                            });
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Điều kiện hiển thị text nghiêm ngặt hơn
                              final canShowText =
                                  constraints.maxWidth >= 300 &&
                                  constraints.maxHeight >= 50;

                              final canShowFullInfo =
                                  constraints.maxWidth >= 300 &&
                                  constraints.maxHeight >= 70;

                              if (!canShowText) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                child:
                                    canShowFullInfo
                                        ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween, // 👉 đẩy 2 đầu
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Tên nhóm máy
                                            Expanded(
                                              child: Text(
                                                tile.group,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize:
                                                      (constraints.maxWidth / 8)
                                                          .clamp(12, 20),
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  shadows: const [
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
                                            Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min, // 👉 chỉ chiếm đúng độ rộng nội dung
                                              children: [
                                                Text(
                                                  '$formattedAct \$',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: (constraints
                                                                .maxWidth /
                                                            10)
                                                        .clamp(10, 16),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black87,
                                                        offset: Offset(0, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 4),

                                                Text(
                                                  '(${percent.toStringAsFixed(1)}%)',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: (constraints
                                                                .maxWidth /
                                                            12)
                                                        .clamp(8, 16),
                                                    color: Colors.white70,
                                                    shadows: const [
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
                                        : // Hiển thị đơn giản khi không gian nhỏ
                                        Text(
                                          tile.group,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth / 8)
                                                .clamp(10, 14),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            shadows: const [
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
                          ),
                        );
                      },

                      colorValueMapper: (TreemapTile tile) {
                        // final data = _getFilteredData();
                        final data = filteredData;

                        final index = tile.indices.first;
                        final key =
                            _treeMapMode == TreeMapMode.group
                                ? data[index].macGrp
                                : data[index].cate;
                        final colorMap =
                            _treeMapMode == TreeMapMode.group
                                ? macGrpColorMap
                                : cateColorMap;

                        return colorMap[key] ??
                            Colors.grey; // fallback tránh lỗi
                      },
                      padding: EdgeInsets.all(3),
                      border: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tooltipBuilder: (BuildContext context, TreemapTile tile) {
                        final indices = tile.indices;
                        final data = _getFilteredData();
                        final totalAct = indices
                            .map((i) => data[i].act)
                            .fold<double>(0, (prev, curr) => prev + curr);

                        return TreeMapWidgets.buildTooltip(
                          'Machine Group',
                          tile.group,
                          totalAct,
                        );
                      },
                    ),

                    TreemapLevel(
                      groupMapper: (int index) {
                        // final data = _getFilteredData();
                        final data = filteredData;

                        return data[index].macId;
                      },
                      labelBuilder: (BuildContext context, TreemapTile tile) {
                        // final data = _getFilteredData();

                        final data = filteredData;
                        final index = tile.indices.first;
                        final act = data[index].act;

                        // Dựa vào group hiện tại để lấy tổng act
                        final groupKey =
                            _treeMapMode == TreeMapMode.group
                                ? data[index].macGrp
                                : data[index].cate;
                        final totalOfGroup = groupTotalMap[groupKey] ?? 1;

                        final percent = (act / totalOfGroup) * 100;

                        final rank = indexRankMap[index]!;

                        // Chỉ hiển thị nếu phần trăm đủ lớn
                        // if (percent < 2) return const SizedBox.shrink();

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Tính toán font size động dựa trên kích thước container
                            final dynamicFontSize =
                                (constraints.maxWidth / 8)
                                    .clamp(8, 16)
                                    .toDouble();

                            // Kiểm tra có đủ không gian để hiển thị text
                            final canShowFullInfo =
                                constraints.maxWidth >= 80 &&
                                constraints.maxHeight >= 100;

                            final canShowBasicInfo =
                                constraints.maxWidth >= 40 &&
                                constraints.maxHeight >= 80;

                            if (!canShowBasicInfo) {
                              return const SizedBox.shrink();
                            }

                            // Tạo text widget với thông tin phù hợp
                            String displayText;
                            if (canShowFullInfo) {
                              displayText =
                                  '${tile.group}\n${data[index].macName}\n${percent.toStringAsFixed(1)}%';
                            } else {
                              displayText =
                                  '${tile.group}\n${percent.toStringAsFixed(1)}%';
                            }

                            Widget titleWidget = Text(
                              displayText,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: canShowFullInfo ? 3 : 2,
                              style: TextStyle(
                                fontSize: dynamicFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height:
                                    1.1, // Giảm line height để tiết kiệm không gian
                              ),
                            );

                            final parentGroup =
                                _treeMapMode == TreeMapMode.group
                                    ? data[index].macGrp
                                    : data[index].cate;

                            if (parentGroup == _justDrilledGroup) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(
                                  milliseconds: 300 + (index * 30),
                                ),

                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scaleX: value,
                                    alignment: Alignment.centerLeft,
                                    child: Opacity(
                                      opacity: value,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        alignment: Alignment.center,
                                        child: titleWidget,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                child: titleWidget,
                              );
                            }
                          },
                        );
                      },

                      color: Color(0xFFFF9800),
                      colorValueMapper: (TreemapTile tile) {
                        final data =
                            _getFilteredData(); // hoặc _treeMapData nếu không dùng filter
                        final index = tile.indices.first;

                        final item = data[index];

                        final originalIndex = _treeMapData.indexWhere((e) {
                          final matchMacId = e.macId == item.macId;
                          if (_treeMapMode == TreeMapMode.group) {
                            return matchMacId && e.macGrp == item.macGrp;
                          } else {
                            return matchMacId && e.cate == item.cate;
                          }
                        });

                        final rank = _currentIndexRankMap[originalIndex] ?? 0;

                        final groupKey =
                            _treeMapMode == TreeMapMode.group
                                ? item.macGrp
                                : item.cate;

                        final totalItemsInGroup = groupSizeMap[groupKey] ?? 1;

                        final color = getBlendedColorByRank(
                          groupKey!,
                          rank,
                          totalItemsInGroup,
                        );

                        return color;
                      },

                      padding: EdgeInsets.all(1),
                      border: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tooltipBuilder: (BuildContext context, TreemapTile tile) {
                        final data = _getFilteredData();

                        final repairFee = data[tile.indices.first].act;
                        final macName = data[tile.indices.first].macName;
                        final index = tile.indices.first;
                        final act = data[index].act;

                        // Dựa vào group hiện tại để lấy tổng act
                        final groupKey =
                            _treeMapMode == TreeMapMode.group
                                ? data[index].macGrp
                                : data[index].cate;
                        final totalOfGroup = groupTotalMap[groupKey] ?? 1;

                        final percent = (act / totalOfGroup) * 100;
                        return TreeMapWidgets.buildDetailedTooltip(
                          label: 'Machine ID',
                          value: tile.group,
                          repairFee: repairFee,
                          macName: macName,
                          percent: percent,
                        );
                      },
                    ),
                  ],

                  tooltipSettings: TreemapTooltipSettings(hideDelay: 3),
                ),
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

  Widget _buildDetailedTooltip(
    String label,
    String value,
    double repairFee,
    String macName,
    double percent,
  ) {
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
