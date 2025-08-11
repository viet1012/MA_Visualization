import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../API/ApiService.dart';
import '../Model/MachineAnalysisAve.dart';
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
    _loadData(); // Call once
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

            // Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedMode.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
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
                          period: const Duration(
                            milliseconds: 1800,
                          ), // tốc độ shimmer
                          child: Text(
                            'No data found for your search',
                            style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.black, // màu gốc vẫn cần để giữ shape
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
                                      dataList.first.keys
                                          .map(
                                            (key) => DataColumn(
                                              label: Text(
                                                key,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
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
