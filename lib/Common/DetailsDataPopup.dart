import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/DetailsDataModel.dart';
import 'package:universal_html/html.dart' as html;

class DetailsDataPopup extends StatefulWidget {
  final String title;
  final List<DetailsDataModel> data;
  final double totalActual;
  final String group;

  DetailsDataPopup({
    Key? key,
    required this.title,
    required this.data,
    required this.totalActual,
    required this.group,
  }) : super(key: key);

  @override
  State<DetailsDataPopup> createState() => _DetailsDataPopupState();
}

class _DetailsDataPopupState extends State<DetailsDataPopup> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  late List<DetailsDataModel> filteredData;
  late List<Map<String, dynamic>> rawJsonList; // bạn lưu từ response

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
    _filterController.addListener(_applyFilter);
    rawJsonList = widget.data.map((e) => e.toJson()).toList();
    for (var item in rawJsonList) {
      print('Item: $item');
    }
  }

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();

    setState(() {
      filteredData =
          widget.data.where((item) {
            // Kiểm tra các điều kiện tìm kiếm trong chuỗi
            final matchesSearch =
                item.dept.toLowerCase().contains(query) ||
                item.maktx.toLowerCase().contains(query) ||
                item.xblnr2.toLowerCase().contains(query) ||
                item.bktxt.toLowerCase().contains(query) ||
                item.matnr.toLowerCase().contains(query) ||
                item.useDate.toLowerCase().contains(query) ||
                item.unit.toLowerCase().contains(query) ||
                item.qty.toString().contains(query) ||
                item.amount.toString().contains(query);

            // Kiểm tra các bộ lọc theo điều kiện của từng dropdown
            final matchesFilters =
                (selectedDept == null || item.dept == selectedDept) &&
                (selectedMatnr == null || item.matnr == selectedMatnr) &&
                (selectedMaktx == null || item.maktx == selectedMaktx) &&
                (selectedXblnr2 == null || item.xblnr2 == selectedXblnr2) &&
                (selectedUnit == null || item.unit == selectedUnit) &&
                (selectedUsedDate == null ||
                    item.useDate == selectedUsedDate) &&
                (selectedBktxt == null || item.bktxt == selectedBktxt) &&
                (selectedKostl == null || item.kostl == selectedKostl) &&
                (selectedKonto == null || item.konto == selectedKonto);

            return matchesSearch &&
                matchesFilters; // Kết hợp cả hai điều kiện: tìm kiếm và lọc
          }).toList();
      print("Filtered Data Length: ${filteredData.length}");
    });
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();
      selectedXblnr2 = null;
      selectedMaktx = null;
      selectedMatnr = null;
      selectedDept = null;
      selectedUnit = null;
      selectedUsedDate = null;
      selectedBktxt = null;
      selectedNote = null;
      selectedKostl = null;
      selectedKonto = null;
      filteredData = widget.data;
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getUniqueValues(String Function(DetailsDataModel) selector) {
    return widget.data.map(selector).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              Expanded(child: _buildDataTable(context, theme)),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
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
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  "Total: ${(totalAmount / 1000).toStringAsFixed(1)}K\$",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  icon: Icon(Icons.cleaning_services_rounded),
                  label: Text('Clear'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
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
                    downloadExcel(excelBytes, 'details_data.xlsx');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: theme.dividerColor, thickness: 1),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: 'Search by Dept, Material No., Description, Note...',
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

  String? selectedDept;
  String? selectedMatnr;
  String? selectedMaktx;
  String? selectedXblnr2;
  String? selectedUnit;
  String? selectedUsedDate;
  String? selectedBktxt;
  String? selectedNote;
  String? selectedKostl;
  String? selectedKonto;

  Widget _buildDynamicDropdownHeader(String key) {
    final title = key.toUpperCase();
    List<String> values = _getUniqueValues(
      (item) => item.toJson()[key]?.toString() ?? '',
    );
    String? selectedValue;
    void Function(String?)? onChanged;

    switch (key) {
      case 'dept':
        selectedValue = selectedDept;
        onChanged = (value) {
          setState(() {
            selectedDept = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'matnr':
        selectedValue = selectedMatnr;
        onChanged = (value) {
          setState(() {
            selectedMatnr = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'maktx':
        selectedValue = selectedMaktx;
        onChanged = (value) {
          setState(() {
            selectedMaktx = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'xblnr2':
        selectedValue = selectedXblnr2;
        onChanged = (value) {
          setState(() {
            selectedXblnr2 = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'unit':
        selectedValue = selectedUnit;
        onChanged = (value) {
          setState(() {
            selectedUnit = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'useDate':
        selectedValue = selectedUsedDate;
        onChanged = (value) {
          setState(() {
            selectedUsedDate = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'bktxt':
        selectedValue = selectedBktxt;
        onChanged = (value) {
          setState(() {
            selectedBktxt = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'kostl':
        selectedValue = selectedKostl;
        onChanged = (value) {
          setState(() {
            selectedKostl = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      case 'konto':
        selectedValue = selectedKonto;
        onChanged = (value) {
          setState(() {
            selectedKonto = value == '__reset__' ? null : value;
            _applyFilter();
          });
        };
        break;
      default:
        // Không filter được -> render Text bình thường
        return _buildTableCell(title, isHeader: true, columnKey: key);
    }

    return _buildDropdownHeader(
      title: title,
      selectedValue: selectedValue,
      values: values,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownHeader({
    required String title,
    required String? selectedValue,
    required List<String> values,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          DropdownButton<String>(
            value: selectedValue ?? '__reset__',
            isExpanded: true,
            items: [
              DropdownMenuItem<String>(
                value: '__reset__',
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              ...values.map(
                (v) => DropdownMenuItem<String>(
                  value: v,
                  child: Center(
                    child: Text(
                      v,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ThemeData theme) {
    final columnKeys =
        rawJsonList.isNotEmpty ? rawJsonList.first.keys.toList() : [];

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header Table
            Table(
              border: TableBorder.all(
                color: theme.dividerColor.withOpacity(0.8),
              ),
              columnWidths: {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(130),
                2: FixedColumnWidth(410),
                3: FixedColumnWidth(150),
                4: FixedColumnWidth(150),
                5: FixedColumnWidth(120),
                6: FixedColumnWidth(190),
                7: FixedColumnWidth(220),
                8: FixedColumnWidth(110),
                9: FixedColumnWidth(110),
                10: FixedColumnWidth(120),
              },
              children: [
                TableRow(
                  children:
                      columnKeys
                          .map((key) => _buildDynamicDropdownHeader(key))
                          .toList(),
                ),
              ],
            ),

            // Table content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 10,
                radius: const Radius.circular(5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(
                        color: theme.dividerColor.withOpacity(0.8),
                      ),
                      columnWidths: {
                        0: FixedColumnWidth(120),
                        1: FixedColumnWidth(130),
                        2: FixedColumnWidth(410),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(150),
                        5: FixedColumnWidth(120),
                        6: FixedColumnWidth(190),
                        7: FixedColumnWidth(220),
                        8: FixedColumnWidth(110),
                        9: FixedColumnWidth(110),
                        10: FixedColumnWidth(120),
                      },
                      children:
                          filteredData.map((item) {
                            final jsonRow = item.toJson(); // convert về Map
                            return TableRow(
                              children:
                                  columnKeys.map((key) {
                                    final value = jsonRow[key];
                                    return _buildTableCell(
                                      value?.toString() ?? '',
                                      isNumber: value is num,
                                    );
                                  }).toList(),
                            );
                          }).toList(),
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

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool highlight = false,
    bool isNumber = false,
    String? columnKey, // thêm tham số để biết cột nào
  }) {
    final isActual =
        columnKey != null && columnKey.toLowerCase().contains('act');
    final displayText = (isActual && isHeader) ? '${text} \$' : text;

    return Container(
      padding: isHeader ? EdgeInsets.only(top: 8) : null,
      // color: Colors.green,
      alignment: isHeader ? Alignment.center : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          displayText,
          textAlign: isNumber ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
            color: highlight ? Colors.blue.shade700 : null,
            fontSize: isHeader ? 18 : 16,
          ),
        ),
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
      'dept',
      'matnr',
      'kostl',
      'konto',
      'bktxt',
      'qty',
      'act', // Nếu toJson không có 'act' mà có 'amount' thì bạn map lại
      'useDate',
      'maktx',
      'xblnr2',
      'unit',
    ]);

    // Dữ liệu theo đúng thứ tự như tiêu đề
    for (var item in data) {
      sheet.appendRow([
        item.dept,
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
