import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysisAve.dart';
import 'ColumnFilterDialog.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';

class MachineTableDialog extends StatefulWidget {
  final String div;
  final String month;
  final String monthBack;
  final int topLimit;
  final NumberFormat numberFormat;
  final AnalysisMode selectedMode;

  MachineTableDialog({
    super.key,
    required this.div,
    required this.month,
    required this.monthBack,
    required this.topLimit,
    required this.numberFormat,
    required this.selectedMode,
  });

  @override
  State<MachineTableDialog> createState() => _MachineTableDialogState();
}

class _MachineTableDialogState extends State<MachineTableDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Map<String, Set<String>> _columnFilters = {};
  List<Map<String, dynamic>> _originalData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data;
      if (widget.selectedMode == AnalysisMode.average) {
        final result = await ApiService()
            .fetchMachineDataAnalysisAvgFullResponse(
              month: widget.month,
              monthBack: widget.monthBack,
              topLimit: widget.topLimit,
              div: widget.div,
            );
        data = result.map((e) => e.toJson()).toList();
      } else {
        final result = await ApiService().fetchMachineDataAnalysis(
          month: widget.month,
          monthBack: widget.monthBack,
          topLimit: widget.topLimit,
          div: widget.div,
        );
        data = result.map((e) => e.toJson()).toList();
      }

      setState(() {
        _originalData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _applyFilters() {
    return _originalData.where((row) {
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

  // Lấy tất cả giá trị unique cho một cột
  Set<String> _getUniqueValuesForColumn(String columnName) {
    return _originalData
        .map((row) => row[columnName]?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  // Đếm số filter đang active
  int _getActiveFiltersCount() {
    return _columnFilters.values.where((filters) => filters.isNotEmpty).length;
  }

  // Reset tất cả filters
  void _clearAllFilters() {
    setState(() {
      _columnFilters.clear();
      _searchText = '';
      _searchController.clear();
    });
  }

  // Hiển thị dialog filter cho cột
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

  Future<List<Map<String, dynamic>>> getMachineDataAsMap() async {
    if (widget.selectedMode == AnalysisMode.average) {
      final result = await ApiService().fetchMachineDataAnalysisAvgFullResponse(
        month: widget.month,
        monthBack: widget.monthBack,
        topLimit: widget.topLimit,
        div: widget.div,
      );
      return result.map((e) => e.toJson()).toList();
    } else {
      final result = await ApiService().fetchMachineDataAnalysis(
        month: widget.month,
        monthBack: widget.monthBack,
        topLimit: widget.topLimit,
        div: widget.div,
      );
      return result.map((e) => e.toJson()).toList();
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
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.85,
        width: MediaQuery.of(context).size.width * 0.65,
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
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                        margin: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$activeFiltersCount filter(s) active',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            InkWell(
                              onTap: _clearAllFilters,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
            if (!_isLoading && _error == null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_rows, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Showing ${dataList.length} of ${_originalData.length} records',
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Lỗi: $_error'))
                      : dataList.isEmpty
                      ? Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.blue,
                          period: const Duration(milliseconds: 1800),
                          child: Text(
                            'No data found for your search',
                            style: TextStyle(
                              fontSize: 58,
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
                                      MediaQuery.of(context).size.width * 0.63,
                                ),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.blueGrey.shade700,
                                  ),
                                  columns:
                                      dataList.first.keys.map((key) {
                                        final hasFilter =
                                            _columnFilters.containsKey(key) &&
                                            _columnFilters[key]!.isNotEmpty;

                                        return DataColumn(
                                          label: InkWell(
                                            onTap:
                                                () => _showColumnFilterDialog(
                                                  key,
                                                ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    hasFilter
                                                        ? Colors.orange
                                                            .withOpacity(0.2)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    key,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          hasFilter
                                                              ? Colors.orange
                                                              : Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    hasFilter
                                                        ? Icons.filter_alt
                                                        : Icons
                                                            .filter_alt_outlined,
                                                    size: 16,
                                                    color:
                                                        hasFilter
                                                            ? Colors.orange
                                                            : Colors.white70,
                                                  ),
                                                  if (hasFilter)
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        left: 4,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${_columnFilters[key]!.length}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                            dataRow['Div']?.toString() ?? '';
                                        final rowColor =
                                            DepartmentUtils.getDepartmentColor(
                                              divValue,
                                            ).withOpacity(0.2);

                                        return DataRow(
                                          color: MaterialStateProperty.all(
                                            rowColor,
                                          ),
                                          cells:
                                              dataRow.entries.map((entry) {
                                                final isHighlighted =
                                                    entry.key == 'AveRepairFee';
                                                final text =
                                                    entry.value is num
                                                        ? widget.numberFormat
                                                            .format(entry.value)
                                                        : entry.value
                                                            .toString();

                                                return DataCell(
                                                  Text(
                                                    text,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          isHighlighted
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                      color:
                                                          isHighlighted
                                                              ? Colors.orange
                                                              : Colors.white,
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
    );
  }
}
