import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysis.dart';
import 'ColumnFilterDialog.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';

class MachineTableDialogContent extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final NumberFormat numberFormat;
  final AnalysisMode selectedMode;
  final String? macName;
  const MachineTableDialogContent({
    super.key,
    required this.data,
    required this.numberFormat,
    required this.selectedMode,
    required this.macName,
  });

  @override
  State<MachineTableDialogContent> createState() =>
      _MachineTableDialogContentState();
}

class _MachineTableDialogContentState extends State<MachineTableDialogContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Map<String, Set<String>> _columnFilters = {};

  List<Map<String, dynamic>> _applyFilters() {
    return widget.data.where((row) {
      final matchesGlobal =
          _searchText.isEmpty ||
          row.values.any(
            (value) => value.toString().toLowerCase().contains(
              _searchText.toLowerCase(),
            ),
          );

      final matchesColumnFilters = _columnFilters.entries.every((entry) {
        final key = entry.key;
        final selectedValues = entry.value;
        if (selectedValues.isEmpty) return true;
        return selectedValues.contains(row[key]?.toString());
      });

      return matchesGlobal && matchesColumnFilters;
    }).toList();
  }

  Set<String> _getUniqueValuesForColumn(String columnName) {
    return widget.data
        .map((row) => row[columnName]?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  int _getActiveFiltersCount() {
    return _columnFilters.values.where((filters) => filters.isNotEmpty).length;
  }

  void _clearAllFilters() {
    setState(() {
      _columnFilters.clear();
      _searchText = '';
      _searchController.clear();
    });
  }

  void _showColumnFilterDialog(String columnName) async {
    final uniqueValues = _getUniqueValuesForColumn(columnName);
    final currentFilters = _columnFilters[columnName] ?? <String>{};

    final result = await showDialog<Set<String>>(
      context: context,
      builder:
          (_) => ColumnFilterDialog(
            columnName: columnName,
            uniqueValues: uniqueValues,
            selectedValues: currentFilters,
          ),
    );

    if (result != null) {
      setState(() {
        if (result.isEmpty) {
          _columnFilters.remove(columnName);
        } else {
          _columnFilters[columnName] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController verticalController = ScrollController();
    final ScrollController horizontalController = ScrollController();
    final dataList = _applyFilters();
    final activeFiltersCount = _getActiveFiltersCount();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Title + Filter Info + Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedMode.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (activeFiltersCount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.filter_alt,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$activeFiltersCount filter(s) active',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: _clearAllFilters,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.red[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.clear,
                                          size: 14,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Clear All',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Results count
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.table_rows,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Showing ${dataList.length} of ${widget.data.length} records',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child:
                      dataList.isEmpty
                          ? Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.blue,
                              period: const Duration(milliseconds: 1800),
                              child: const Text(
                                'No data found for your search',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                          : Scrollbar(
                            controller: verticalController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: verticalController,
                              scrollDirection: Axis.vertical,
                              child: Scrollbar(
                                controller: horizontalController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                          0.63,
                                    ),
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                            Colors.blueGrey.shade700,
                                          ),
                                      columns:
                                          dataList.first.keys.map((key) {
                                            final hasFilter =
                                                _columnFilters.containsKey(
                                                  key,
                                                ) &&
                                                _columnFilters[key]!.isNotEmpty;
                                            return DataColumn(
                                              label: InkWell(
                                                onTap:
                                                    () =>
                                                        _showColumnFilterDialog(
                                                          key,
                                                        ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        hasFilter
                                                            ? Colors.orange
                                                                .withOpacity(
                                                                  0.2,
                                                                )
                                                            : Colors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        key,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              hasFilter
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .white,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        hasFilter
                                                            ? Icons.filter_alt
                                                            : Icons
                                                                .filter_alt_outlined,
                                                        size: 16,
                                                        color:
                                                            hasFilter
                                                                ? Colors.orange
                                                                : Colors
                                                                    .white70,
                                                      ),
                                                      if (hasFilter)
                                                        Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                left: 4,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            '${_columnFilters[key]!.length}',
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      rows:
                                          dataList.map((dataRow) {
                                            final divValue =
                                                dataRow['Div']?.toString() ??
                                                '';
                                            final macName =
                                                dataRow['MacName']
                                                    ?.toString() ??
                                                '';

                                            Color rowColor =
                                                DepartmentUtils.getDepartmentColor(
                                                  divValue,
                                                ).withOpacity(0.2);

                                            // Nếu trùng lastClickedMachine -> highlight
                                            if (widget.macName != null &&
                                                macName == widget.macName) {
                                              rowColor = rowColor.withOpacity(
                                                0.5,
                                              ); // màu highlight
                                            }

                                            return DataRow(
                                              color: MaterialStateProperty.all(
                                                rowColor,
                                              ),
                                              cells:
                                                  dataRow.entries.map((entry) {
                                                    final isHighlighted =
                                                        entry.key ==
                                                        'AveRepairFee';
                                                    final text =
                                                        entry.value is num
                                                            ? widget
                                                                .numberFormat
                                                                .format(
                                                                  entry.value,
                                                                )
                                                            : entry.value
                                                                .toString();
                                                    return DataCell(
                                                      Text(
                                                        text,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              isHighlighted
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color:
                                                              isHighlighted
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hàm tiện ích show dialog và load dữ liệu trước
Future<void> showMachineTableDialog({
  required BuildContext context,
  required String div,
  required String month,
  required String monthBack,
  required int topLimit,
  required NumberFormat numberFormat,
  required AnalysisMode selectedMode,
  required String? lastClickedMachine,
}) async {
  // Show loading spinner
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  List<Map<String, dynamic>> dataList = [];
  try {
    if (selectedMode == AnalysisMode.Average) {
      final result = await ApiService().fetchMachineDataAnalysisAvg(
        month: month,
        monthBack: monthBack,
        topLimit: topLimit,
        div: div,
      );
      dataList = result.map((e) => e.toJson()).toList();
    } else if (selectedMode == AnalysisMode.MovAve) {
      final result = await ApiService().fetchMachineDataAnalysisAvg(
        month: month,
        monthBack: monthBack,
        topLimit: topLimit,
        div: div,
        macName: lastClickedMachine,
      );

      // 🔹 Lọc lại chỉ những machine có macName trùng với lastClickedMachine
      final filtered =
          result.where((e) => e.macName == lastClickedMachine).toList();

      // In ra số lượng
      print("Số lượng machine filtered: ${filtered.length}");

      // In chi tiết từng phần tử
      for (var item in filtered) {
        print(
          "macName: ${item.macName}, "
          "rank: ${item.rank}",
        );
      }

      // 🔹 Sắp xếp rank
      MachineAnalysis.sortByRank(filtered);

      // 🔹 Custom sort: Press → Mold → theo rank
      filtered.sort((a, b) {
        int getDivPriority(String div) {
          if (div.contains("PRESS")) return 1;
          if (div.contains("MOLD")) return 2;
          return 3;
        }

        final priA = getDivPriority(a.div ?? "");
        final priB = getDivPriority(b.div ?? "");

        return priA.compareTo(priB);
      });

      // In ra chi tiết
      for (var item in filtered) {
        print("macName: ${item.macName}, div: ${item.div}, rank: ${item.rank}");
      }

      dataList = filtered.map((e) => e.toJson()).toList();
    } else {
      final result = await ApiService().fetchMachineDataAnalysis(
        month: month,
        monthBack: monthBack,
        topLimit: topLimit,
        div: div,
      );
      dataList = result.map((e) => e.toJson()).toList();
    }
  } catch (e) {
    Navigator.of(context).pop(); // Close loading
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Load data lỗi: ${e.toString()}')));
    return;
  }

  Navigator.of(context).pop(); // Close loading

  // Show dialog chính với dữ liệu đã load
  showDialog(
    context: context,
    builder:
        (_) => MachineTableDialogContent(
          data: dataList,
          numberFormat: numberFormat,
          selectedMode: selectedMode,
          macName: lastClickedMachine,
        ),
  );
}
