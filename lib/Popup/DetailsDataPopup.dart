import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/DetailsDataModel.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart'
    show MultiSelectDialogField;
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:universal_html/html.dart' as html;

import '../API/ApiService.dart';
import '../Common/DateDisplayWidget.dart';
import '../MachineAnalysis/MultiMonthSelector.dart';

class DetailsDataPopup extends StatefulWidget {
  final String nameChart;
  final String title;
  final List<DetailsDataModel> data;

  DetailsDataPopup({
    Key? key,
    required this.nameChart,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  State<DetailsDataPopup> createState() => _DetailsDataPopupState();
}

class _DetailsDataPopupState extends State<DetailsDataPopup> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  bool _hasInput = false;
  late List<Map<String, dynamic>> rawJsonList; // bạn lưu từ response

  List<DetailsDataModel> allData = []; // dữ liệu gốc từ API/cache
  List<DetailsDataModel> filteredData = []; // dữ liệu sau khi lọc

  @override
  void initState() {
    super.initState();
    if (allData.isEmpty) {
      allData = widget.data;
    }
    filteredData = widget.data;
    _filterController.addListener(() {
      setState(() {
        _hasInput = _filterController.text.trim().isNotEmpty;
      });
    });
    _filterController.addListener(_applyFilter);
    rawJsonList = widget.data.map((e) => e.toJson()).toList();
  }

  Map<String, List<DetailsDataModel>> _cache = {};

  Future<void> _loadData(List<String> months, String div) async {
    final monthParam = months.join(","); // "2025-04,2025-05"

    // check cache theo combo tháng + div
    if (_cache.containsKey("$monthParam-$div")) {
      setState(() {
        filteredData = _cache["$monthParam-$div"]!;
        rawJsonList = filteredData.map((e) => e.toJson()).toList();
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final data = await ApiService().fetchDetailsDataRF(monthParam, div);

    Navigator.of(context).pop();

    setState(() {
      filteredData = data;
      allData = data;
      rawJsonList = data.map((e) => e.toJson()).toList();
      _cache["$monthParam-$div"] = data; // cache lại
    });
    print("filtered Data: ${filteredData.length}");
  }

  @override
  void dispose() {
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _checkHasInput() {
    return selectedDept != null ||
        selectedMatnr != null ||
        selectedMacName != null ||
        selectedCate != null ||
        selectedMaktx != null ||
        selectedXblnr2 != null ||
        selectedUnit != null ||
        selectedUsedDate != null ||
        selectedBktxt != null ||
        selectedKostl != null ||
        selectedKonto != null;
  }

  void _applyFilter() {
    final query = _filterController.text.trim().toLowerCase();
    print("raw query: $query");

    bool matchesItem(dynamic item, String keyword) {
      final searchable = [
        item.dept,
        item.macId,
        item.macName,
        item.cate,
        item.maktx,
        item.xblnr2,
        item.bktxt,
        item.matnr,
        item.useDate,
        item.kostl?.toString(),
        item.konto?.toString(),
        item.unit,
        item.qty?.toString(),
        item.amount?.toString(),
      ].whereType<String>().map((e) => e.toLowerCase()).join(' ');

      return searchable.contains(keyword);
    }

    final tokens =
        query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    setState(() {
      filteredData =
          allData.where((item) {
            bool? currentResult; // null = chưa có keyword nào
            String? lastOp;

            for (var token in tokens) {
              if (token == "and" || token == "or") {
                lastOp = token;
              } else {
                bool match = matchesItem(item, token);

                if (currentResult == null) {
                  currentResult = match;
                } else if (lastOp == "and") {
                  currentResult = currentResult && match;
                } else if (lastOp == "or") {
                  currentResult = currentResult || match;
                }
              }
            }

            // Nếu không có keyword nào, mặc định match = true
            currentResult ??= true;

            final matchesFilters =
                (selectedDept == null || selectedDept!.contains(item.dept)) &&
                (selectedMacId == null ||
                    selectedMacId!.contains(item.macId)) &&
                (selectedMacName == null ||
                    selectedMacName!.contains(item.macName)) &&
                (selectedMatnr == null ||
                    selectedMatnr!.contains(item.matnr)) &&
                (selectedMaktx == null ||
                    selectedMaktx!.contains(item.maktx)) &&
                (selectedXblnr2 == null ||
                    selectedXblnr2!.contains(item.xblnr2)) &&
                (selectedUnit == null || selectedUnit!.contains(item.unit)) &&
                (selectedUsedDate == null ||
                    selectedUsedDate!.contains(item.useDate)) &&
                (selectedBktxt == null ||
                    selectedBktxt!.contains(item.bktxt)) &&
                (selectedKostl == null ||
                    selectedKostl!.contains(item.kostl.toString())) &&
                (selectedKonto == null ||
                    selectedKonto!.contains(item.konto.toString()));

            return currentResult && matchesFilters;
          }).toList();

      print("Filtered Data Length: ${filteredData.length}");
    });
  }

  void _applyFilter1() {
    final query = _filterController.text.trim().toLowerCase();
    print("raw query: $query");

    // Gom tất cả field thành chuỗi searchable
    bool matchesItem(dynamic item, String keyword) {
      final searchable = [
        item.dept,
        item.macId,
        item.macName,
        item.cate,
        item.maktx,
        item.xblnr2,
        item.bktxt,
        item.matnr,
        item.useDate,
        item.kostl?.toString(),
        item.konto?.toString(),
        item.unit,
        item.qty?.toString(),
        item.amount?.toString(),
      ].whereType<String>().map((e) => e.toLowerCase()).join(' ');

      return searchable.contains(keyword);
    }

    // Tokenize: giữ lại "and" và "or"
    final tokens =
        query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    setState(() {
      filteredData =
          allData.where((item) {
            bool currentResult = false;
            String? lastOp; // "and" hoặc "or"

            for (var token in tokens) {
              if (token == "and" || token == "or") {
                lastOp = token;
              } else {
                bool match = matchesItem(item, token);

                if (lastOp == null) {
                  // keyword đầu tiên
                  currentResult = match;
                } else if (lastOp == "and") {
                  currentResult = currentResult && match;
                } else if (lastOp == "or") {
                  currentResult = currentResult || match;
                }
              }
            }

            // Thêm điều kiện filter dropdown
            final matchesFilters =
                (selectedDept == null || item.dept == selectedDept) &&
                (selectedMacId == null || item.macId == selectedMacId) &&
                (selectedMacName == null ||
                    (selectedMacName?.contains(item.macName) ?? true)) &&
                (selectedCate == null ||
                    (selectedCate?.contains(item.cate) ?? true)) &&
                (selectedMatnr == null || item.matnr == selectedMatnr) &&
                (selectedMaktx == null || item.maktx == selectedMaktx) &&
                (selectedXblnr2 == null || item.xblnr2 == selectedXblnr2) &&
                (selectedUnit == null ||
                    (selectedUnit?.contains(item.unit) ?? true)) &&
                (selectedUsedDate == null ||
                    item.useDate == selectedUsedDate) &&
                (selectedBktxt == null || item.bktxt == selectedBktxt) &&
                (selectedKostl == null ||
                    item.kostl.toString() == selectedKostl) &&
                (selectedKonto == null ||
                    item.konto.toString() == selectedKonto);

            return currentResult && matchesFilters;
          }).toList();

      print("Filtered Data Length: ${filteredData.length}");
    });
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();
      selectedXblnr2 = null;
      selectedMacId = null;
      selectedMacName = null;
      selectedCate = null;
      selectedMaktx = null;
      selectedMatnr = null;
      selectedDept = null;
      selectedUnit = null;
      selectedUsedDate = null;
      selectedBktxt = null;
      selectedNote = null;
      selectedKostl = null;
      selectedKonto = null;
      // filteredData = widget.data;
      filteredData = allData;
      _hasInput = false; // ✅ reset trạng thái
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                Expanded(child: _buildDataTable(context, theme)),
                const SizedBox(height: 16),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    // Tính tổng amount
    final totalAmount = filteredData.fold<double>(
      0,
      (sum, item) => (sum + item.amount),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.nameChart,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '[Details Data]',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blueAccent.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  DateDisplayWidget(
                    selectedDate: DateTime.now(),
                    monthYearDropDown: MultiMonthSelector(
                      initialSelectedMonths: [
                        DateTime(DateTime.now().year, DateTime.now().month),
                      ], // mặc định chọn tháng hiện tại
                      onSelectionChanged: (months) {
                        final formatted =
                            months
                                .map((m) => DateFormat("yyyy-MM").format(m))
                                .toList();

                        if (formatted.isNotEmpty) {
                          _loadData(formatted, widget.title);
                        } else {
                          setState(() {
                            allData = widget.data;
                            filteredData = widget.data;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Items: ${filteredData.length}", // 👈 hiện số lượng item
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 24),

                    Text(
                      "Total: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${(totalAmount / 1000).toStringAsFixed(1)}K\$",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  icon: Icon(Icons.cleaning_services_rounded),
                  label: Text('Clear'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _hasInput ? Colors.red.shade600 : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  onPressed: _resetFilter,
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  icon: Icon(Icons.download_rounded, size: 20),
                  label: Text('Export Excel'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    final excelBytes = createExcel(filteredData);
                    downloadExcel(
                      excelBytes,
                      '${widget.title}_${widget.nameChart}_details_data.xlsx',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Divider(color: theme.dividerColor, thickness: 1),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: 'Search by Dept, MacID, MacName, Cate...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              filled: true,
              fillColor: theme.cardColor.withOpacity(.5),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  List<String>? selectedDept;
  List<String>? selectedMacId;
  List<String>? selectedMacName;
  List<String>? selectedCate;
  List<String>? selectedMatnr;
  List<String>? selectedMaktx;
  List<String>? selectedXblnr2;
  List<String>? selectedUnit;
  List<String>? selectedUsedDate;
  List<String>? selectedBktxt;
  List<String>? selectedNote;
  List<String>? selectedKostl;
  List<String>? selectedKonto;

  List<String> _getUniqueValuesFromList(
    List<dynamic> list,
    String Function(dynamic) extractor,
  ) {
    final set = <String>{};
    for (var item in list) {
      final value = extractor(item);
      if (value.isNotEmpty) {
        set.add(value);
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  Widget _buildDropdownHeader({
    required String title,
    required List<String> selectedValues,
    required List<String> values,
    required Function(List<String>) onConfirm,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: MultiSelectDialogField<String>(
        buttonText: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        searchable: true, // Cho phép search trong dropdown
        items: values.map((v) => MultiSelectItem(v, v)).toList(),
        initialValue: selectedValues,
        itemsTextStyle: const TextStyle(color: Colors.white),
        selectedItemsTextStyle: const TextStyle(color: Colors.blueAccent),
        buttonIcon: const Icon(
          Icons.keyboard_arrow_down_outlined, // đổi thành icon bạn muốn
          color: Colors.blueAccent,
        ),
        cancelText: const Text(
          "CANCEL",
          style: TextStyle(
            fontSize: 18,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        confirmText: const Text(
          "OK",
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        chipDisplay: MultiSelectChipDisplay.none(),
        onConfirm: (results) {
          onConfirm(results);
        },
      ),
    );
  }

  Widget _buildDynamicDropdownHeader(String key) {
    final title = key.toUpperCase();

    // Lọc data tạm theo điều kiện filter hiện tại
    final tempFilteredData =
        allData.where((item) {
          return (selectedDept == null || selectedDept!.contains(item.dept)) &&
              (selectedMacId == null || selectedMacId!.contains(item.macId)) &&
              (selectedMacName == null ||
                  selectedMacName!.contains(item.macName)) &&
              (selectedMatnr == null || selectedMatnr!.contains(item.matnr)) &&
              (selectedMaktx == null || selectedMaktx!.contains(item.maktx)) &&
              (selectedXblnr2 == null ||
                  selectedXblnr2!.contains(item.xblnr2)) &&
              (selectedUnit == null || selectedUnit!.contains(item.unit)) &&
              (selectedUsedDate == null ||
                  selectedUsedDate!.contains(item.useDate)) &&
              (selectedBktxt == null || selectedBktxt!.contains(item.bktxt)) &&
              (selectedKostl == null ||
                  selectedKostl!.contains(item.kostl.toString())) &&
              (selectedKonto == null ||
                  selectedKonto!.contains(item.konto.toString()));
        }).toList();

    // Lấy danh sách unique value theo key
    List<String> values = _getUniqueValuesFromList(
      tempFilteredData,
      (item) => item.toJson()[key]?.toString() ?? '',
    );

    // Cấu hình từng key
    final Map<String, dynamic> config = {
      "dept": {
        "getter": () => selectedDept ?? [],
        "setter": (results) => selectedDept = results.isEmpty ? null : results,
      },
      "macId": {
        "getter": () => selectedMacId ?? [],
        "setter": (results) => selectedMacId = results.isEmpty ? null : results,
      },
      "macName": {
        "getter": () => selectedMacName ?? [],
        "setter":
            (results) => selectedMacName = results.isEmpty ? null : results,
      },
      "cate": {
        "getter": () => selectedCate ?? [],
        "setter": (results) => selectedCate = results.isEmpty ? null : results,
      },
      "matnr": {
        "getter": () => selectedMatnr ?? [],
        "setter": (results) => selectedMatnr = results.isEmpty ? null : results,
      },
      "maktx": {
        "getter": () => selectedMaktx ?? [],
        "setter": (results) => selectedMaktx = results.isEmpty ? null : results,
      },
      "xblnr2": {
        "getter": () => selectedXblnr2 ?? [],
        "setter":
            (results) => selectedXblnr2 = results.isEmpty ? null : results,
      },
      "unit": {
        "getter": () => selectedUnit ?? [],
        "setter": (results) => selectedUnit = results.isEmpty ? null : results,
      },
      "useDate": {
        "getter": () => selectedUsedDate ?? [],
        "setter":
            (results) => selectedUsedDate = results.isEmpty ? null : results,
      },
      "bktxt": {
        "getter": () => selectedBktxt ?? [],
        "setter": (results) => selectedBktxt = results.isEmpty ? null : results,
      },
      "note": {
        "getter": () => selectedNote ?? [],
        "setter": (results) => selectedNote = results.isEmpty ? null : results,
      },
      "kostl": {
        "getter": () => selectedKostl ?? [],
        "setter": (results) => selectedKostl = results.isEmpty ? null : results,
      },
      "konto": {
        "getter": () => selectedKonto ?? [],
        "setter": (results) => selectedKonto = results.isEmpty ? null : results,
      },
    };

    if (config.containsKey(key)) {
      List<String> selectedValues = List<String>.from(config[key]["getter"]());

      return _buildDropdownHeader(
        title: title,
        selectedValues: selectedValues,
        values: values,
        onConfirm: (results) {
          setState(() {
            config[key]["setter"](results);
            _applyFilter();
            _hasInput = _checkHasInput();
          });
        },
      );
    }

    // Nếu không match key thì render Text header bình thường
    return _buildTableCell(title, isHeader: true, columnKey: key);
  }

  double _getColumnWidth(String key) {
    switch (key.toLowerCase()) {
      case "dept":
        return 94; // rộng hơn
      case "macid":
        return 105; // nhỏ hơn
      case "macname":
        return 140;
      case "cate":
        return 100;
      case "matnr":
        return 110;
      case "maktx":
        return 220;
      case "usedate":
        return 125;
      case "kostl":
        return 120;
      case "konto":
        return 120;
      case "xblnr2":
        return 140;
      case "bktxt":
        return 150;
      case "unit":
        return 90;
      case "qty":
        return 90;

      default:
        return 125; // mặc định
    }
  }

  _buildDataTable(BuildContext context, ThemeData theme) {
    final columnKeys =
        rawJsonList.isNotEmpty ? rawJsonList.first.keys.toList() : [];

    final Map<String, double> columnMax = {};

    // Tính max cho từng cột số
    for (var key in columnKeys) {
      columnMax[key] = 0.0;
    }

    for (var item in filteredData) {
      final row = item.toJson();
      for (var key in columnKeys) {
        final v = row[key];
        if (v is num) {
          final d = v.toDouble();
          if (d > (columnMax[key] ?? 0)) {
            columnMax[key] = d;
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              // Header
              Table(
                border: TableBorder.all(
                  color: theme.dividerColor.withOpacity(0.8),
                ),
                columnWidths: {
                  for (int i = 0; i < columnKeys.length; i++)
                    i: FixedColumnWidth(_getColumnWidth(columnKeys[i])),
                },
                children: [
                  TableRow(
                    children:
                        columnKeys.map((key) {
                          return _buildDynamicDropdownHeader(key);
                        }).toList(),
                  ),
                ],
              ),

              // Nội dung cuộn theo chiều dọc
              SizedBox(
                height: 700,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SizedBox(
                    width: columnKeys.fold<double>(
                      0,
                      (sum, key) => sum + _getColumnWidth(key),
                    ), // 👈 tổng width theo từng cột
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, rowIndex) {
                        final jsonRow = filteredData[rowIndex].toJson();

                        return Row(
                          children:
                              columnKeys.map((key) {
                                final value = jsonRow[key];
                                final isNumber = value is num;
                                final txt = value?.toString() ?? '';
                                return Container(
                                  width: _getColumnWidth(key),
                                  decoration: BoxDecoration(
                                    border: BoxBorder.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCell(
                                    txt,
                                    isHeader: false,
                                    isNumber: isNumber,
                                    columnKey: key,
                                    numValue:
                                        isNumber ? value.toDouble() : null,
                                    columnMaxValue: columnMax[key],
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isNumber = false,
    String? columnKey,
    double? numValue,
    double? columnMaxValue,
  }) {
    final fraction =
        (isNumber &&
                numValue != null &&
                columnMaxValue != null &&
                columnMaxValue > 0)
            ? (numValue / columnMaxValue).clamp(0.0, 1.0)
            : 0.0;

    final isActColumn = columnKey?.trim().toLowerCase() == 'act';

    final barColor =
        Color.lerp(Colors.red.shade800, Colors.red.shade800, fraction)!;

    var displayText = (isActColumn && isHeader) ? '$text \$' : text;

    return Container(
      height: isHeader ? 40 : 90,
      padding: isHeader ? EdgeInsets.only(top: 9) : null,
      alignment:
          isHeader
              ? Alignment.center
              : (isNumber ? Alignment.centerRight : Alignment.centerLeft),
      child: Stack(
        children: [
          // Bar bên phải, không ảnh hưởng layout chữ
          if (!isHeader && isActColumn)
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: Container(height: double.infinity, color: barColor),
              ),
            ),
          // Text phía trên
          Container(
            alignment:
                isHeader
                    ? Alignment.center
                    : (isNumber ? Alignment.centerRight : Alignment.centerLeft),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SelectableText(
              displayText,
              textAlign: isNumber ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
                fontSize: isHeader ? 18 : 16,
                color: isActColumn ? Colors.white : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = Colors.deepOrange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton.icon(
          label: Text('Close'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered)) {
                return errorColor.withOpacity(0.8); // Hover
              } else if (states.contains(MaterialState.pressed)) {
                return errorColor.withOpacity(1); // Pressed
              } else if (states.contains(MaterialState.focused)) {
                return errorColor.withOpacity(0.95); // Focused
              }
              return errorColor; // Default
            }),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            elevation: MaterialStateProperty.all(2),
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.05), // Hiệu ứng ripple
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void downloadExcel(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Uint8List createExcel(List<DetailsDataModel> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Thêm tiêu đề đúng thứ tự
    sheet.appendRow([
      'DEPT',
      'MACID',
      'MACNAME',
      'CATE',
      'MATNR',
      'KOSTL',
      'KONTO',
      'BKTXT',
      'QTY',
      'ACT', // Nếu toJson không có 'act' mà có 'amount' thì bạn map lại
      'USEDATE',
      'MAKTX',
      'XBLNR2',
      'UNIT',
    ]);

    // Dữ liệu theo đúng thứ tự như tiêu đề
    for (var item in data) {
      sheet.appendRow([
        item.dept,
        item.macId,
        item.macName,
        item.cate,
        item.matnr,
        item.kostl,
        item.konto,
        item.bktxt,
        item.qty,
        item.amount,
        item.useDate,
        item.maktx,
        item.xblnr2,
        item.unit,
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }
}
